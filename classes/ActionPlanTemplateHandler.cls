public class ActionPlanTemplateHandler {

    public static void handleAfterInsert( Map<Id,ActionPlanTemplate__c> newMapATM, Map<Id,ActionPlanTemplate__c> oldMapATM){
        KAMApexSharing.shareAPTRecords(newMapATM,oldMapATM);
        
        KAMCreateAlertAndNotifications.checkConditionsToCreateAlert(newMapATM, null);
        //ActionPlanTemplateHandler.actionPlanTemplateValidations(newMapATM, null);
    }
    public static void handleAfterUpdate( Map<Id,ActionPlanTemplate__c> newMapATM, Map<Id,ActionPlanTemplate__c> oldMapATM){
            List<ActionPlanTemplate__c> aptList = new List<ActionPlanTemplate__c>();

        for(Id apt: newMapATM.keyset()){
            if(oldMapATM.get(apt).AccountId__c != null && newMapATM.get(apt).AccountId__c != oldMapATM.get(apt).AccountId__c ){
               KAMApexSharing.removeAPTAccess(newMapATM,oldMapATM);
            }
            if(newMapATM.get(apt).AccountId__c != oldMapATM.get(apt).AccountId__c){
                KAMApexSharing.shareAPTRecords(newMapATM,oldMapATM);
            }
             if(newMapATM.get(apt).Status__c=='Recalled' && newMapATM.get(apt).Status__c != oldMapATM.get(apt).Status__c){
                 KAMBatchPurgeDataISA k = new KAMBatchPurgeDataISA(apt);
                 Database.executeBatch(k,100);

                //  ActionPlanTemplate__c aptObj = new ActionPlanTemplate__c(
                //     id=newMapATM.get(apt).id,
                //     Last_Recall_Executed__c=DateTime.now()
                //  );
                // update aptObj;
             }
            
            /*Below code is commented and implemented the logic in KAMBatchPurgeDataISA batch class.
            //Logic to delete the records of the Objects when APT Status is changed to Recalled
              if(newMapATM.get(apt).Status__c=='Recalled' && newMapATM.get(apt).Status__c != oldMapATM.get(apt).Status__c){   
                List<id> idsToBeDeleted = new List<id>();
                List<id> idsToBeDeleted1 = new List<id>();
                List<id> idsToBeDeleted2 = new List<id>();
                List<id> idsToBeDeleted3 = new List<id>();
                List<id> idsToBeDeleted4 = new List<id>();

                Set<id> accIdSet = new Set<Id>();
                //Query all the Retail Store Groups on APT
                List<RetailLocationGroup__c> rsList = [select id from RetailLocationGroup__c where AccountId__c =:newMapATM.get(apt).AccountId__c];  
                //Query all the Store Locations on the respective Retail Store Groups
                List<AccountRetailStoreGroup__c> arsgList = [select AccountId__c from AccountRetailStoreGroup__c where RetailStoreGroupId__c IN: rsList];
                system.debug('@@arsgList : '+arsgList.size()+''+arsgList);
                  for(Integer i=0;i<arsgList.size();i++){
                  	accIdSet.add(arsgList[i].AccountId__c); 
                  }
 
                  system.debug('@@accIdSet : '+accIdSet);
               
                  //Query all Store Locations corresponding to the Store Locations of all Retail Store Groups of APT    
                  for(InStoreLocation__c isl : [select id,StartDate__c,EndDate__c from InStoreLocation__c where RetailLocationId__c IN: accIdSet  ]){
                          if(isl.StartDate__c == newMapATM.get(apt).RequestedStartDate__c && isl.EndDate__c == newMapATM.get(apt).RequestedEndDate__c){
                          	idsToBeDeleted.add(isl.Id);
                          }
                      }
                  System.debug('** test idsToBeDeleted'+idsToBeDeleted.size());
                 //Query all Store Products corresponding to the Store Locations of all Retail Store Groups of APT      
                      for(StoreProduct__c sp : [select id,Mission_Start_Date__c,Mission_End_Date__c from StoreProduct__c where RetailStoreId__c IN: accIdSet]){
                          if(sp.Mission_Start_Date__c == newMapATM.get(apt).RequestedStartDate__c && sp.Mission_End_Date__c == newMapATM.get(apt).RequestedEndDate__c){
                              idsToBeDeleted1.add(sp.Id);
                          }
                      }
                      
                  //Query all Assets corresponding to the Store Locations of all Retail Store Groups of APT 
                      for(Asset ast : [select id,Mission_Start_Date__c,Mission_End_Date__c from Asset where AccountId IN: accIdSet]){
                          if(ast.Mission_Start_Date__c == newMapATM.get(apt).RequestedStartDate__c && ast.Mission_End_Date__c == newMapATM.get(apt).RequestedEndDate__c){
                            idsToBeDeleted2.add(ast.Id);
                          }
                      }

				//Query all Action Plans corresponding to the Store Locations of all Retail Store Groups of APT                       
                      for(ActionPlan__c ap : [select id,ActionPlanTemplateId__r.Name from ActionPlan__c where Mission__r.AccountId__c IN: accIdSet]){
                          if(ap.ActionPlanTemplateId__r.Name==newMapATM.get(apt).Name){
                          	idsToBeDeleted3.add(ap.Id);
                          }
                      }
                      
                  //Query all Missions corresponding to the Store Locations of all Retail Store Groups of APT 
                      for(Mission__c msn : [select id,StartDate__c,EndDate__c from Mission__c where AccountId__c IN: accIdSet]){
                        if(msn.StartDate__c == newMapATM.get(apt).RequestedStartDate__c && msn.EndDate__c == newMapATM.get(apt).RequestedEndDate__c){
                          idsToBeDeleted4.add(msn.Id);
                      	}
                      }
                      
                      /*for(MissionTask__c mst : [select id from MissionTask__c where AccountId__c IN: accIdSet AND CreatedDate=TODAY]){
                        idsToBeDeleted.add(mst.Id);
                      }
                      system.debug('@@idsToBeDeleted 6: '+idsToBeDeleted.size()+''+idsToBeDeleted); 

                  //Delete all the object's records fetched from the above queries
					  if(idsToBeDeleted.size()>0 ){
                		database.delete(idsToBeDeleted,false);
                        database.delete(idsToBeDeleted1,false);
                        database.delete(idsToBeDeleted2,false);
                        database.delete(idsToBeDeleted3,false);
                        database.delete(idsToBeDeleted4,false);
                        system.debug('@@Data found for deletion !');
                      }
                  	  

                	 else{
                		system.debug('@@No data found!');
                	 } 
          } */
               
        }
        
        KAMCreateAlertAndNotifications.checkConditionsToCreateAlert(newMapATM,oldMapATM);
        //ActionPlanTemplateHandler.actionPlanTemplateValidations(newMapATM, oldMapATM);
        
       
    }
    
    public static void handleBeforeInsert( List<ActionPlanTemplate__c> newATMs){
        	UpdateActionPlanTemplateFundingRate.updateFundingRateonUpdate(newATMs);
        	
    }
    
    public static void handleBeforeUpdate(List<ActionPlanTemplate__c> newATMs, Map<Id,ActionPlanTemplate__c> oldMapATM){
       UpdateCurrentApprover(newATMs, oldMapATM);
       //UpdateMassCascadeActiveFlagDate(newATMs, oldMapATM);
    }
    
   /* Public static void UpdateMassCascadeActiveFlagDate(List<ActionPlanTemplate__c> newATMs, Map<Id,ActionPlanTemplate__c> oldMapATM)
    {
        //Start - For JTP-177
        for(ActionPlanTemplate__c apt : newATMs)
        {
            ActionPlanTemplate__c oldApt =  oldMapATM.get(apt.Id);
            if(apt.Mass_Cascade_Flag__c != oldApt.Mass_Cascade_Flag__c && apt.Mass_Cascade_Flag__c == true)
                {
                    apt.Mass_Cascade_Active_Flag_Date__c = System.today();
                    System.debug('apt.Mass_Cascade_Active_Flag_Date__c-'+apt.Mass_Cascade_Active_Flag_Date__c);
                }
        }//End - For JTP-177
    }*/
    //Update Current Approver based on CurrentApproverList's role selected
    public static void UpdateCurrentApprover(List<ActionPlanTemplate__c> newActionPlanTemplateList, Map<Id,ActionPlanTemplate__c> mapOldActionPlanTemplate){
        //adding to prevent ownership issues on clone
        Id newOwnerId = UserInfo.getUserId();
        
        Set<Id> accountIds = new Set<Id>();         
        for(ActionPlanTemplate__c apt: newActionPlanTemplateList){
            //adding to prevent ownership issues on clone
            //if(mapOldActionPlanTemplate != null && apt.OwnerId != null && apt.OwnerId != mapOldActionPlanTemplate.get(apt.Id).OwnerId)
            //apt.OwnerId = UserInfo.getUserId();
            //added above
            
            if(mapOldActionPlanTemplate != null && apt.CurrentApproverList__c != null && apt.CurrentApproverList__c != mapOldActionPlanTemplate.get(apt.Id).CurrentApproverList__c)
                accountIds.add(apt.AccountId__c);
                
        }
        System.debug('Test123 accountIds'+accountIds);
        if(accountIds !=null && accountIds.size()>0){
            Map<Id,Account> mapaccts = new Map<Id,Account>([Select id, ownerId,owner.ManagerId from Account where Id in :accountIds]);
            Map<Id,List<AccountTeamMember>> mapAccTeam = new Map<Id,List<AccountTeamMember>>();
            for(AccountTeamMember atm : [Select id, TeamMemberRole,UserId,AccountId from AccountTeamMember where AccountId in :accountIds]){
                if(!mapAccTeam.containsKey(atm.AccountId))
                    mapAccTeam.put(atm.AccountId, new List<AccountTeamMember>());
                mapAccTeam.get(atm.AccountId).add(atm);
            }
            
            for(ActionPlanTemplate__c apt: newActionPlanTemplateList){
                if(mapAccTeam.containsKey(apt.AccountId__c)){
                    Boolean userFpound = false;
                    if(apt.CurrentApproverList__c == 'Manager'){
                        apt.CurrentApprover__c = mapaccts.get(apt.AccountId__c).owner.ManagerId;
                        userFpound = true;
                    }
                    for(AccountTeamMember at : mapAccTeam.get(apt.AccountId__c)){
                        if(at.TeamMemberRole == apt.CurrentApproverList__c){
                            apt.CurrentApprover__c = at.UserId;
                            userFpound = true;
                        }
                    }
                    if(!userFpound)
                        apt.CurrentApprover__c = null;
                }
            }
        }
    }

    
    
  /**  public static void actionPlanTemplateValidations( Map<Id,ActionPlanTemplate__c> newActionPlanTemplateList, Map<Id,ActionPlanTemplate__c> mapOldActionPlanTemplate){
        List<Id> accountIds = new List<Id>();
        List<Account> accountList = new List<Account>();
        Map<Id, List<ActionPlanTemplate__c>> accountStoreMap = new Map<Id, List<ActionPlanTemplate__c>>();
        for(ActionPlanTemplate__c newAPT : newActionPlanTemplateList.values()){
            accountIds.add(newAPT.AccountId__c); 
        }
        Set<Id> alreadyAssociatedAPT = new Set<Id>();
        Map<Id, List<ActionPlanTemplate__c>> accountIDandAPTMap = new  Map<Id, List<ActionPlanTemplate__c>>();
        List<ActionPlanTemplate__c> alreadyAddedAPT = [SELECT Id, Name, AccountId__c,RequestedStartDate__c ,RequestedEndDate__c, RecordTypeID FROM ActionPlanTemplate__c 
                                                       WHERE AccountId__c=:accountIds];
        for(ActionPlanTemplate__c addedAPT : alreadyAddedAPT){
            if(accountIDandAPTMap.get(addedAPT.AccountId__c)== null){
                accountIDandAPTMap.put(addedAPT.AccountId__c, new list<ActionPlanTemplate__c>());
            }
            accountIDandAPTMap.get(addedAPT.AccountId__c).add(addedAPT);
        }
        System.debug('--- added APT '+ accountIDandAPTMap);
        for(ActionPlanTemplate__c newAPT : newActionPlanTemplateList.values()){
            for(ActionPlanTemplate__c addedAPT : accountIDandAPTMap.get(newAPT.AccountId__c)){
                if(newAPT.RequestedStartDate__c >= addedAPT.RequestedStartDate__c && newAPT.RequestedStartDate__c < addedAPT.RequestedEndDate__c
                        && newAPT.RecordTypeID == addedAPT.RecordTypeID){
                    alreadyAssociatedAPT.add(newAPT.AccountId__c);
                }
            }
        }
        
        //Show valdation message if second active assortment is being added
        for(ActionPlanTemplate__c actionPlanTemplate: newActionPlanTemplateList.values()){
            if(alreadyAssociatedAPT.contains(actionPlanTemplate.AccountId__c))
                actionPlanTemplate.addError('An Action Plan Template with this date range is already exist on this account.');                    
        } 
    }
 */

}