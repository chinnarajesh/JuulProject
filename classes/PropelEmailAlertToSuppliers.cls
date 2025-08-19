global with sharing class PropelEmailAlertToSuppliers {
    global class GetRequestsfromPB{
        @InvocableVariable(label='Change ID' required=true) global Id changeID;
        @InvocableVariable(label='Accessible By' required=true) global String accessibleBy;
        @InvocableVariable(label='Email Template API Name' required=true) global String emailTemplate;
    }

    @testVisible static Integer num_of_emails_sent = 0;
    @InvocableMethod

    global static void PropelEmailAlertToSuppliers(List<GetRequestsfromPB> pbs) {
        Set<Id> changeIDs = new Set<Id>();
        Map<Id,Set<Id>> changeUserIdsMap = new Map<Id, Set<Id>>();
        Map<Id,Set<Id>> groupToGroupMembersMap = new Map<Id,Set<Id>>();
        Map<Id, String> changeAccessibleByGroupsMap = new Map<Id, String>();
        Map<String,Id> EmailTempAPINameToRecordMap = new Map<String,Id>();
        Map<Id, EmailTemplate> recordToEmailTempMap = new Map<Id, EmailTemplate>();
        String[] groupNames = new String[]{};

        //Loop through records that trigger the Process Builder
        for (GetRequestsfromPB pb : pbs){
            changeIDs.add(pb.changeID);
            changeAccessibleByGroupsMap.put(pb.changeID, pb.accessibleBy);
            EmailTempAPINameToRecordMap.put(pb.emailTemplate, pb.changeID);
            String[] tempGroupNames = pb.accessibleBy.split(';');
            groupNames.addAll(tempGroupNames);
        }
        system.debug('Group List: ' + groupNames);

        if (groupNames.size()==0){return; }

        //Query Email Template
        List<EmailTemplate> emailTemps = new List<EmailTemplate>([SELECT Id, Body, HtmlValue, DeveloperName FROM EmailTemplate 
                                                                  WHERE DeveloperName in :EmailTempAPINameToRecordMap.keySet()]);
        if (emailTemps.size()==0){return;}

        for (EmailTemplate temp : emailTemps){
            recordToEmailTempMap.put(EmailTempAPINameToRecordMap.get(temp.DeveloperName), temp);
        }

        //Query Group based on Accessible By groups passed in
        Map<String, Id> groupNameIdMap = new Map<String, Id>();
        for (Group g : [select Id, Name, DeveloperName from Group where Name in :groupNames or DeveloperName in :groupNames]) { // NOPMD not a pemissionable table
            groupNameIdMap.put(g.DeveloperName, g.Id);
            groupNameIdMap.put(g.Name, g.Id);
        }
        
        if (groupNameIdMap.size()==0){return; }

        //Get GroupMember results
        List<GroupMember> groupMembers = new List<GroupMember>([SELECT GroupId, UserOrGroupId FROM GroupMember 
                                                                WHERE Group.Name in :groupNames or Group.DeveloperName in : groupNames]);
        
        //Ignore if the user is not active
        Set<Id> allUserList = new Set<Id>();
        for (GroupMember member: groupMembers){
            if(member.userOrGroupID.getSobjectType() == User.SObjectType){
                allUserList.add(member.userOrGroupID);
            }
        }

        Map<Id, User> activeUserList = new Map<Id, User>([SELECT Id FROM User WHERE id in :allUserList and isActive = true]);

        //Query GroupMember based on Accessible By groups passed in
        for (GroupMember member: groupMembers){
            if(member.userOrGroupID.getSobjectType() == User.SObjectType){
                if(!groupToGroupMembersMap.containsKey(member.GroupId)){
                    groupToGroupMembersMap.put(member.GroupId, new Set<Id>());
                }

                if(activeUserList.containsKey(member.userOrGroupID)){
                    groupToGroupMembersMap.get(member.GroupId).add(member.UserOrGroupId);
                }
            }
        }
        system.debug('GroupToGroupMemberMap: ' + groupToGroupMembersMap);

        //Looped through parsed Accessible By
        for (Id key : changeAccessibleByGroupsMap.keySet()){
            changeUserIdsMap.put(key, new Set<Id>());
            String[] tempGroupNames = changeAccessibleByGroupsMap.get(key).split(';');
            for (String tempGroup : tempGroupNames){
                Id groupId = groupNameIdMap.get(tempGroup);
                changeUserIdsMap.get(key).addAll(new List<Id> (groupToGroupMembersMap.get(groupId)));
            }
        }
        system.debug('ChangeUserIDsMap: ' + changeUserIdsMap);

        // //Create Change to ChangeName Map and Change to ChangeURL Map
        // Map<Id, String> changeChangeNameMap = new Map<Id, String> ();
        // Map<Id, String> changeChangeURLMap = new Map<Id, String> ();
        // Map<Id, String> changeTitleMap = new Map<Id, String>();
        // List<PDLM__Change__c> changes = [select Id, Name, PDLM__Title__c, Change_URL__c from PDLM__Change__c where id in: changeIDs];

        // //Check the list is not null
        // if (changes.size() == 0) {return; }

        // for (PDLM__Change__c ch : changes) {   
        //     changeChangeNameMap.put(ch.id, ch.Name);
        //     changeChangeURLMap.put(ch.id, ch.Change_URL__c);
        //     changeTitleMap.put(ch.id, ch.PDLM__Title__c);
        // }

        //Send Emails
        //Now create a new single email message object that will send out a single email to the addresses in the To, CC & BCC list.
        // Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
        Messaging.SingleEmailMessage [] mails = new List<Messaging.SingleEmailMessage> {};
        //Query the OrgWide
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'PLM Admin' limit 1];

        for (Id change: changeUserIdsMap.keySet())
        {
            List<Id> emailUserIDList = new List<Id>(changeUserIdsMap.get(change));

            if (emailUserIDList.size() != 0) {
                Id templateId = recordToEmailTempMap.get(change).Id;
    
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, null, change); //Set recipents in the next line
                mail.setBccAddresses(emailUserIDList); 
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                else {
                    mail.setSenderDisplayName(userInfo.getName());
                }
                mails.add(mail);

                // // mail.setToAddresses(emailUserIDList);
                // mail.setBccAddresses(emailUserIDList);
                // mail.setSaveAsActivity(false);
                // mail.setUseSignature(false);
                // //If statement here
                // if (owea.size() > 0) {
                //     mail.setOrgWideEmailAddressId(owea.get(0).Id);
                // }
                // else {
                //     mail.setSenderDisplayName(userInfo.getName());
                // }
                // mail.setSubject(ChangeChangeNameMap.get(change) + ' has been shared with you');
                // mail.setHtmlBody(changeChangeNameMap.get(change) + ' - ' + changeTitleMap.get(change)
                //                  + '<br>' + changeChangeNameMap.get(change) + ' has been shared with you.'
                //                  + '<br>Click on this link to go to the object: ' + changeChangeURLMap.get(change)
                //                  + '<br><br>Thank you,<br>PLM Admin');

                // //Add the individual email to the list
                // mails.add(mail);
            }
        }
        
        //Email the outstanding Approvers and Originator
        Messaging.sendEmail(mails);
        num_of_emails_sent = mails.size();
    }
}