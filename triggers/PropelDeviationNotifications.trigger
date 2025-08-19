trigger PropelDeviationNotifications on PDLM__Change__c (after update) {
    static Integer num_of_emails_sent = 0;

    Set<PDLM__Change__c> changeIDs = new Set<PDLM__Change__c>();
    Map<PDLM__Change__c,Set<Id>> changeUserIdsMap = new Map<PDLM__Change__c, Set<Id>>();
    Map<Id,Set<Id>> groupToGroupMembersMap = new Map<Id,Set<Id>>();
    String[] groupNames = new String[]{};

    if(Trigger.isAfter && Trigger.isUpdate){
        //Check Criteria
        for(PDLM__Change__c ch : Trigger.New){
            PDLM__Change__c oldCh = Trigger.oldMap.get(ch.id);
            if(ch.Name.startsWith('DEV-') && ch.Accessible_By__c != null && ch.PDLM__Status_lk__c != oldCh.PDLM__Status_lk__c
               && (ch.Change_Status_Name__c == 'Commitment Review' ||ch.Change_Status_Name__c == 'Active' 
               || ch.Change_Status_Name__c == 'Extension Active' || ch.Change_Status_Name__c == 'Closed')){
                    changeIDs.add(ch);
                    String[] tempGroupNames = ch.Accessible_By__c.split(';');
                    groupNames.addAll(tempGroupNames);
            }
        }
        system.debug('Group List: ' + groupNames);

        //Create AllActiveUserMap
        Map<Id, String> activeAllUserMap = new Map<Id, String>();
        for (User user: [SELECT Id, Name FROM User WHERE isActive = true]){
            activeAllUserMap.put(user.Id, user.Name);
        }
        

        if (groupNames.size()==0){return; }

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

        Map<Id, User> activeUserList = new Map<Id, User>([SELECT Id, Name FROM User WHERE id in :allUserList and isActive = true]);

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
        for (PDLM__Change__c key : changeIDs){
            changeUserIdsMap.put(key, new Set<Id>());
            String[] tempGroupNames = key.Accessible_By__c.split(';');

            for (String tempGroup : tempGroupNames){
                Id groupId = groupNameIdMap.get(tempGroup);
                changeUserIdsMap.get(key).addAll(new List<Id> (groupToGroupMembersMap.get(groupId)));
            }
        }
        system.debug('ChangeUserIDsMap: ' + changeUserIdsMap);

        //Send Emails
        //Now create a new single email message object that will send out a single email to the addresses in the To, CC & BCC list.
        Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
        Messaging.SingleEmailMessage [] mails = new List<Messaging.SingleEmailMessage> {};
        //Query the OrgWide
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'PLM Admin' limit 1];

        for (PDLM__Change__c change: changeUserIdsMap.keySet())
        {
            List<Id> emailUserIDList = new List<Id>(changeUserIdsMap.get(change));

            if (emailUserIDList.size() != 0) {
                // mail.setToAddresses(emailUserIDList);
                mail.setBccAddresses(emailUserIDList);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                //If statement here
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                else {
                    mail.setSenderDisplayName(userInfo.getName());
                }
                mail.setSubject('DEVIATION ALERT - ' + change.Name + ' is now in ' + change.Change_Status_Name__c + ' phase');
                mail.setHtmlBody(change.Name + ' - ' + change.PDLM__Title__c
                                 + '<br>' + change.Name + ' is now in ' + change.Change_Status_Name__c + ' phase'
                                 + '<br>The DRI for this Deviation is ' + activeAllUserMap.get(change.DRI__c)
                                 + '<br>Click on this link to go to the record:  ' + change.Change_URL__c
                                 + '<br><br>Thank you,<br>Propel');
                //Add the individual email to the list
                mails.add(mail);
            }
        }

        // Messaging.sendEmail(mails);
        //Try...Catch...
        try {
            // Send email
            Messaging.reserveSingleEmailCapacity(mails.size());
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
            system.debug(LoggingLevel.warn, result);
        } catch (Exception e) {
            // deal with failure to send
            System.debug(LoggingLevel.WARN, 'Exception: ' + e);
        }

        num_of_emails_sent = mails.size();
    }
}