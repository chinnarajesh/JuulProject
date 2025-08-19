/*************************************************************************************************
Trigger Name        : AccountTrigger
Version             : 1.0
Date Created        : 25-March2015
Function            : Trigger to clean phonenumber 
Author              : Andrew
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* ---------------       -----------             ----------------------------------------------
**************************************************************************************************/
trigger AccountTrigger on Account (before insert,after insert, before update,after update,after delete) {
    Bypass_NAM_Update_Logic__mdt byPassNAMLogic                = [SELECT Id,DeveloperName, BypassLogic__c FROM Bypass_NAM_Update_Logic__mdt where DeveloperName = 'Bypass_NAM_Logic'];
    Bypass_NAM_Update_Logic__mdt byPassChildAccountAccessLogic = [SELECT Id,DeveloperName, BypassLogic__c FROM Bypass_NAM_Update_Logic__mdt where DeveloperName = 'Bypass_ChildAccountAccess_Logic'];
    
   //  Bypass_NAM_Update_Logic__mdt byPassNAMLogic   = Bypass_NAM_Update_Logic__mdt.getInstance('Bypass_NAM_Logic');
   //  Bypass_NAM_Update_Logic__mdt byPassChildAccountAccessLogic = Bypass_NAM_Update_Logic__mdt.getInstance('Bypass_ChildAccountAccess_Logic');
  
  
    Id muleSoftAPIUserId = Label.Mulesoft_Api_User_Id;
   
    
     //if (!AccountTriggerHandler.isTriggerExecuted) {

      
   
    if(Trigger.isBefore)
        for(Account acc: Trigger.New){
            Account oldRecord = Trigger.isInsert ? new Account() : Trigger.oldMap.get(acc.id);
            if(! String.isBlank(acc.phone)){
                acc.Phone_Unformatted__c = acc.phone.replaceAll('[^0-9]+', '');
                if(acc.Phone_Unformatted__c.length() > 10){
                    acc.Phone_Unformatted__c = acc.Phone_Unformatted__c.right(10);
                }
            }
            
            if(acc.BirthdateText__c != oldRecord.BirthdateText__c){
                if(! String.isBlank(acc.BirthdateText__c)){
                    String dateValue = acc.BirthdateText__c.substring(0,10);
                   if(acc.BirthdateText__c.contains('/')){
                        acc.PersonBirthDate = Date.newInstance(
                                                    Integer.valueOf(
                                                        dateValue.split('/')[2]
                                                    )
                                                    ,Integer.valueOf(
                                                        dateValue.split('/')[0]
                                                    ),Integer.valueOf(
                                                        dateValue.split('/')[1]
                                                    ));
                   }else{
                        acc.PersonBirthDate = Date.newInstance(
                                                    Integer.valueOf(
                                                        dateValue.split('-')[0]
                                                    )
                                                    ,Integer.valueOf(
                                                        dateValue.split('-')[1]
                                                    ),Integer.valueOf(
                                                        dateValue.split('-')[2]
                                                    ));
                   }
                }else{
                    acc.PersonBirthDate = null;
                }
            }
        }
    if(Trigger.isAfter)
 //MarketingSegmentManager.manageChange(trigger.newMap,trigger.oldMap);
    
 Trigger_Controller__c AccountTriggerControl = Trigger_Controller__c.getInstance('AccountTrigger'); //Get Trigger Controller Setting
    

   // if((AccountTriggerControl != null && AccountTriggerControl.Enabled__c) || Test.isRunningTest())
       // if( Test.isRunningTest())
        //{
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                System.debug('Trigger**********');
                  //Ticket : SFDC - 0000003191 and Business Requirement: BREQ - 0000000521 and Added By : Shreya Raut 
                AccountTriggerHandler.updateTerritoryAssigner(Trigger.New); //sr01
                AccountTriggerHandler.handleBeforeInsert( Trigger.New );
                if(UserInfo.getUserId() == muleSoftAPIUserId || Test.isRunningTest()) {
                    AccountTriggerHandler.populateRecordTypeId(Trigger.New, null, false);
                }
                if(!byPassNAMLogic.BypassLogic__c){
                    AccountTriggerHandler.updateNAMFieldonAccount(Trigger.New, Trigger.oldMap, Trigger.operationType);
                 }  
                //Added by Ramya- SFDC - 0000004010 
                AccountTriggerHandler.accountMasterCreateEditInsert(Trigger.New);
                 AccountTriggerHandler.UpdateNSLEffectiveDate(Trigger.new);
                //Added by shreya for SFDC 
                //AccountTriggerHandler.UpdateSubTypes(Trigger.new);
                 //Added by pooja for JTP-164
                AccountTriggerHandler.UpdateDateStampDate(Trigger.new, Trigger.oldMap,Trigger.operationType);
                //----- Start---Added by Pooja G for JTP-274---------
               AccountTriggerHandler.SMTfieldUpdate(Trigger.new);
               //----- End ----Added by Pooja G for JTP-274---------
               //Added bye pooja for JTP- 287 enhancement of JTP-164
               AccountTriggerHandler.updateChainExpansion(Trigger.newmap,Trigger.New, Trigger.oldMap,Trigger.operationType);
                                
            } 
            if (Trigger.isUpdate) {
                System.debug('Trigger**********1*********');
                  //Ticket : SFDC - 0000003191 and Business Requirement: BREQ - 0000000521 and Added By : Shreya Raut 
                 AccountTriggerHandler.updateTerritoryAssigner(Trigger.New); //sr01
                AccountTriggerHandler.handleBeforeUpdate( Trigger.Old, Trigger.New );
                if(UserInfo.getUserId() == muleSoftAPIUserId) {
                    AccountTriggerHandler.populateRecordTypeId(Trigger.New, Trigger.oldMap, true);                    
                }                
                if(CommonUtilities.AccountTriggerUpdateBeforeFlag && UserInfo.getUserId() != muleSoftAPIUserId){
                    CommonUtilities.AccountTriggerUpdateBeforeFlag = FALSE;
                    AccountTriggerHandler.updateResultCodeonAccount(Trigger.New, Trigger.oldMap, Trigger.operationType);
                }
                //Added by Ramya Ganeshkar  - SFDC - 0000004010 
                AccountTriggerHandler.updateLatitudeLogitudeAccount(Trigger.oldmap,Trigger.new);
                //Added by Pooja Gite - SFDC - 0000004010 
                AccountTriggerHandler.updateComplianceMechanism(Trigger.newmap,trigger.oldmap);
                //Added by Ramya Ganeshkar - SFDC - 0000004010 
                AccountTriggerHandler.accountMasterCreateEditUpdate(Trigger.oldMap, Trigger.new);
                 AccountTriggerHandler.UpdateNSLEffectiveDate(Trigger.new);
               // AccountTriggerHandler.updateAcccountandgroupAlert();
               //Added by shreya for SFDC 
               //AccountTriggerHandler.UpdateSubTypes(Trigger.new);
               //Added by shreya - SFDC - 0000005599
               AccountTriggerHandler.updateEACStatus(Trigger.new, Trigger.oldmap);
               //Added by JC - SFDC - 0000005660 and SFDC - 0000005661 
               //AccountTriggerHandler.UpdateEffectiveDates(Trigger.new, Trigger.oldMap);
               //Added by JC - JTP-122
               AccountTriggerHandler.UpdateDateStampDate(Trigger.new, Trigger.oldMap,Trigger.operationType);
                //----- Start---Added by Pooja G for JTP-232---------
               AccountTriggerHandler.nullifyEACField(Trigger.new,Trigger.oldMap);
               //----- End ----Added by Pooja G for JTP-232---------
               //----- Start---Added by Pooja G for JTP-274---------
              AccountTriggerHandler.SMTfieldUpdate(Trigger.new);
               //----- End ----Added by Pooja G for JTP-274---------
               //Added bye pooja for JTP- 287 enhancement of JTP-164
               AccountTriggerHandler.updateChainExpansion(Trigger.newmap,Trigger.New,Trigger.oldMap, Trigger.operationType);
                //-----Start----Added for JTP-156--------------------
             //  UpdateAccountRetailerSellingStatus.UpdateRetailerSellingStatus(Trigger.new);
               //-----  End  ----Added for JTP-156--------------------

            }
           
        }
        
        if (Trigger.IsAfter) {
            if (Trigger.isInsert) { 
                if(!byPassChildAccountAccessLogic.BypassLogic__c){
                  AccountTriggerHandler.EnableChildAccountAccess(Trigger.New, Trigger.oldMap, Trigger.operationType);
                }
                AccountTriggerHandler.createSubtractionOrAddtionAlertforAccounts(Trigger.operationType, Trigger.newMap, Trigger.oldMap);
                
                //Sharing records with parent account Team members
                KAMApexSharing.shareAccountRecords(Trigger.new, Trigger.OldMap);
                //AccountTriggerHandler.updateAcccountandgroupAlert();
                //Ticket SFDC - 0000005443
                //AccountTriggerHandler.createARSG(Trigger.new);
               // AccountTriggerHandler.UpdateNSLEffectiveDate(Trigger.new);

               //New Code Added By Santhosh to create Customer Org Units and Store Assortments
               User userData =[SELECT Id, Name, cgcloud__Sales_Org__c,cgcloud__Mobility_Sales_Org__c FROM User WHERE Id =: UserInfo.getUserId() limit 1 ];
               if(userData.cgcloud__Sales_Org__c == '0001' && userData.cgcloud__Mobility_Sales_Org__c == '0001'){
                AccountTriggerHandler.handleCustomerOrgUnitsAssign(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
                AccountTriggerHandler.handleStoreAssortmentsAssign(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
               }
               
               //end
                
            } 
            if (Trigger.isUpdate) {
                //Add Future Logic Here  
                System.debug('inside after update');
                if(!byPassNAMLogic.BypassLogic__c){
                    AccountTriggerHandler.updateNAMFieldonAccount(Trigger.New, Trigger.oldMap, Trigger.operationType);
                }
                if(!byPassChildAccountAccessLogic.BypassLogic__c){
                    AccountTriggerHandler.EnableChildAccountAccess(Trigger.New, Trigger.oldMap, Trigger.operationType);
                }
                AccountTriggerHandler.createSubtractionOrAddtionAlertforAccounts(Trigger.operationType,Trigger.newMap, Trigger.oldMap);
               
                //Sharing records with parent account Team members
                Map<Id, Account> filteredNewMap = new Map<Id, Account>();
                for(Account ac: Trigger.oldMap.values()){
                    if(ac.ParentId != null && Trigger.NewMap.get(ac.ID).ParentId != ac.ParentId)
                    {
                        filteredNewMap.put(ac.Id, ac);
                    }
                }
                if(filteredNewMap.size()> 0){
                    KAMApexSharing.removeAccessAccountRecords(Trigger.newMap, Trigger.oldMap);
                }
                KAMApexSharing.shareAccountRecords(Trigger.new,  Trigger.oldMap);
                //Added by Pooja- SFDC - 0000004010 
                AccountTriggerHandler.AccountContractTrigger(Trigger.new,  Trigger.oldMap);
                //Added by Ramya- SFDC - 0000004010
               // AccountTriggerHandler.accountMasterCreateEditAfterUpdate(Trigger.New);
              
                // ----- Added to Ramya SFDC - 0000005225 ------
               AccountTriggerHandler.automaticCaseCreation(Trigger.new, Trigger.oldMap);
                // ---------End--- Added by Ramya---- SFDC - 0000005225
                //Ticket SFDC - 0000005443 added by Shreya -- Commented out on 9/10 as we have seen issues in prod.
               //AccountTriggerHandler.updateARSG(Trigger.new,Trigger.oldMap);


               //New Code Added By Santhosh to create Customer Org Units and Store Assortments
               User userData =[SELECT Id, Name, cgcloud__Sales_Org__c,cgcloud__Mobility_Sales_Org__c FROM User WHERE Id =: UserInfo.getUserId() limit 1 ];
                if(userData.cgcloud__Sales_Org__c == '0001' && userData.cgcloud__Mobility_Sales_Org__c == '0001'){
                    AccountTriggerHandler.handleCustomerOrgUnitsAssign(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
                    AccountTriggerHandler.handleStoreAssortmentsAssign(Trigger.newMap, Trigger.oldMap, Trigger.operationType);
                }
            }
         

        }
   //}

        //AccountTriggerHandler.isTriggerExecuted = true;
    //}  //isTriggerExecuted if close
        
}