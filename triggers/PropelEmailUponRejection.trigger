trigger PropelEmailUponRejection on PDLM__Change_Phase__c (after update) {
    if(PDLM__Configuration__c.getInstance('EmailUponRejection') != null &&
       PDLM__Configuration__c.getInstance('EmailUponRejection').PDLM__Value__c == 'false'){return;}

    if(Trigger.isAfter && Trigger.isUpdate){
        //Check if the Parent Change Phase is rejected
        for(PDLM__Change_Phase__c phase : Trigger.New){
            PDLM__Change_Phase__c oldPhase = Trigger.oldMap.get(phase.id);

            Set<Id> userIds = new Set<Id>();
            Set<Id> changePhaseIds = new Set<Id>();

            if(phase.PDLM__Parent_Change_Phase__c == null && oldPhase.Rejected__c != true && phase.Rejected__c == true){
                    //Add Approvers
                    for (PDLM__Change_Phase__c phaseToLoop : [SELECT Id, PDLM__Approver_1__c, PDLM__Approver_2__c, PDLM__Approver_3__c,  PDLM__Approver_4__c,
                                                              PDLM__Approver_5__c, PDLM__Approver_6__c, PDLM__Approver_7__c,  PDLM__Approver_8__c,
                                                              PDLM__Approver_9__c, PDLM__Approver_10__c, PDLM__Approver_11__c,  PDLM__Approver_12__c,
                                                              PDLM__Approver_13__c, PDLM__Approver_14__c, PDLM__Approver_15__c,  PDLM__Approver_16__c,
                                                              PDLM__Approver_17__c, PDLM__Approver_18__c, PDLM__Approver_19__c,  PDLM__Approver_20__c
                                                              FROM PDLM__Change_Phase__c WHERE (PDLM__Parent_Change_Phase__c = :phase.Id or Id = :phase.Id)
                                                              and PDLM__Approver_1__c != null]){
                        userIDs.add(phaseToLoop.PDLM__Approver_1__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_2__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_3__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_4__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_5__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_6__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_7__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_8__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_9__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_10__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_11__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_12__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_13__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_14__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_15__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_16__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_17__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_18__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_19__c);
                        userIDs.add(phaseToLoop.PDLM__Approver_20__c);
                        changePhaseIds.add(phaseToLoop.Id);
                }

                system.debug('userIds before adding Change Analysts: ' + userIds);

                //DRI User
                PDLM__Change__c change = [SELECT Id, DRI__c, Name FROM PDLM__Change__c WHERE Id = :phase.PDLM__Change_lk__c];
                if (change.DRI__c != null){
                    userIds.add(change.DRI__c);
                }

                //Query Change Analyst Group and add the members to the userIDs set
                List<GroupMember> changeAnalysts = [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'Change Analyst Group'];

                if (changeAnalysts.size() != 0){
                    for (GroupMember ca : changeAnalysts){
                        if (ca.UserOrGroupId.getSobjectType() == User.SObjectType){
                            userIds.add(ca.UserOrGroupId);
                        }
                    }
                }
                
                userIds.remove(null);
                system.debug('userIds: ' + userIds);
                system.debug('changePhaseIds: ' + changePhaseIds);

                if (userIdS.size()==0){return; }

                //Query for the latest rejection Commenets
                DateTime dateTimeToCompare = system.now().addMinutes(-1);
                ProcessInstanceStep[] approvalComments = [SELECT Id, ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId, 
                                                                ActorId, Actor.Name, Comments FROM ProcessInstanceStep 
                                                                WHERE ProcessInstance.Status = 'Rejected' and Comments != null
                                                                and (NOT Comments like 'Auto submitted by entry into%')
                                                                and (NOT Comments like 'Submitted for approval')
                                                                and (ActorId = :UserInfo.getUserId() or OriginalActorId = :UserInfo.getUserId())
                                                                and ProcessInstance.TargetObjectId in :changePhaseIds
                                                                and CreatedDate >= :dateTimeToCompare  //Grab the one that is within one minute of the trigger time
                                                                Order By CreatedDate Desc LIMIT 1];

                System.debug('ProcessInstanceStep record: ' + approvalComments);

                //Send Emails
                //Now create a new single email message object that will send out a single email to the addresses in the To, CC & BCC list.
                Messaging.SingleEmailMessage  mail = new Messaging.SingleEmailMessage ();
                
                //Query the OrgWide
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'PLM Admin' limit 1];

                //Get the Rejection Comments and Change Title
                String comments = (approvalComments.size() != 0) ? approvalComments[0].Comments : '';
                String title = (phase.PDLM__Parent_Title__c != null) ? phase.PDLM__Parent_Title__c : '';

                //Get RejectedBy
                ProcessInstanceStep[] rejectedAction = [SELECT Id, ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId, 
                                                                ActorId, Actor.Name, Comments, CreatedById FROM ProcessInstanceStep 
                                                                WHERE ProcessInstance.Status = 'Rejected' 
                                                                and (ActorId = :UserInfo.getUserId() or OriginalActorId = :UserInfo.getUserId())
                                                                and ProcessInstance.TargetObjectId in :changePhaseIds
                                                                and CreatedDate >= :dateTimeToCompare  //Grab the one that is within one minute of the trigger time
                                                                Order By CreatedDate Desc LIMIT 1];

                String rejectedBy = '';
                if (rejectedAction.size() != 0){
                    rejectedBy = [SELECT Id, Name FROM User WHERE Id = :rejectedAction[0].CreatedById].Name;
                }

                //Convert userIds set to a list
                List<Id> userIdsList = new List<Id>();
                userIdsList.addAll(userIds);

                mail.setToAddresses(userIdsList);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                //If statement here
                if (owea.size() > 0) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                else {
                    mail.setSenderDisplayName(userInfo.getName());
                }
                mail.setSubject(change.Name + ' has been REJECTED');
                mail.setHtmlBody('Hello Propel User,'
                                + '<br><br>' + change.Name + ' has been rejected. Please use the link to review: ' 
                                + URL.getSalesforceBaseUrl().toExternalForm() + '/' + phase.Id
                                + '<br>Title: ' + title
                                + '<br>Rejected By: ' + rejectedBy
                                + '<br>Comments: ' + comments
                                + '<br><strong>Next Steps</strong>:' 
                                + '<br><ul>' 
                                        + '<li>A CMG representative will reassign the corresponding Jira ticket back to the DRI. The DRI is to review the rejection comment and work with stakeholders to address the issue(s)</li>'
                                        + '<li>Determine if this change needs to be reworked or cancelled.</li>'
                                        + '<li>Contact your CMG representative to either re-open your Jira ticket for rework or to cancel your change order.</li>'
                                        + '<li>Once the change is ready for resubmission, provide the list of changes and justification in your Jira ticket comment section along with updated content (ie. Documents, drawings, etc)</li>'
                                        + '<li>This rework will re-enter the Jira ticket queue. <strong>To expedite processing time</strong>, submit an SVP approval letter.</li></ul>'
                                + '<br>Thank you,<br>PLM Admin');
                
                //Try...Catch...
                try {
                    // Send email
                    Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
                    system.debug(LoggingLevel.warn, result);
                } catch (Exception e) {
                    // deal with failure to send
                    System.debug(LoggingLevel.WARN, 'Exception: ' + e);
                }
            }
        }
    }
}