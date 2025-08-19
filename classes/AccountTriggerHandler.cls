public class AccountTriggerHandler {
    public static boolean runningOnce = True;
    public static Boolean INSERT_TRIGGER_BYPASS = false;
    public static Boolean UPDATE_TRIGGER_BYPASS = false;
    public static Id recTypeAccPerson; 
    public static boolean firstRun = false; 
    public static Boolean isExecuting = false;

    //public static Boolean isTriggerExecuted = false;

    public static Boolean skipTriggerMethodFromTestClass =true;
  // public  static Map<String,String> countryBasedMap=new Map<String,String>() ;
     
    public AccountTriggerHandler(){
        Map<String,Schema.RecordTypeInfo> rtMapAcc = Schema.SObjectType.Account.getRecordTypeInfosByName();
        recTypeAccPerson = rtMapAcc.get('Person Account').getRecordTypeId();  
             //     countryBasedMap = getIsoBasedCountry();

    }
    public static void handleBeforeInsert( List<Account> triggerObjects ) {
        if(INSERT_TRIGGER_BYPASS!=true){
        
      //  System.debug('countryBasedMap::'+countryBasedMap);
            //Get the CountryBasedMap from IsoObject
           Map<String,String> countryBasedMap = getIsoBasedCountry(); 
         //   Id personAccountsRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Person Account' LIMIT 1].Id;     //.......commented by Archana for SOQL limit
                List<Account> nonPersonAccounts = new List<Account>();

            for(Account obj: triggerObjects){ 
             //   if(obj.RecordTypeId != personAccountsRecordTypeId){
                  if(obj.RecordTypeId != recTypeAccPerson){
             
                    nonPersonAccounts.add(obj);
                }
                if(countryBasedMap.containsKey(obj.ShippingCountry)){
                    obj.ShippingState = '';
                }
                if(countryBasedMap.containsKey(obj.BillingCountry)){
                    obj.BillingState = '';
                }
               //  if( obj.RACS_Status__c != null){
                     obj.RACS_Status__c = 'Not Contacted';
                 //}
            }

            TerritoryUtility.standardizeField( 'State', 'BillingState', new Map<String,Object>(), nonPersonAccounts );
            TerritoryUtility.standardizeField( 'Country', 'BillingCountry', new Map<String,Object>(), nonPersonAccounts );
            TerritoryUtility.standardizeField( 'State', 'ShippingState', new Map<String,Object>(), nonPersonAccounts );
            TerritoryUtility.standardizeField( 'Country', 'ShippingCountry', new Map<String,Object>(), nonPersonAccounts );
        }
    }
    
    public static void handleBeforeUpdate( List<Account> oldTriggerObjects, List<Account> newTriggerObjects ) {
        if(UPDATE_TRIGGER_BYPASS!=true){
              //  System.debug('countryBasedMap::'+countryBasedMap);

            //Get the CountryBasedMap from IsoObject
           Map<String,String> countryBasedMap = getIsoBasedCountry();
         ///   Id personAccountsRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Person Account' LIMIT 1].Id;   ////...........Commented by Archana for SOQL limit
            List<Account> nonPersonAccounts = new List<Account>();
            List<Id> newAccountIdList = new List<Id>();
            
            
            for(Account obj: newTriggerObjects){
              //  if(obj.RecordTypeId != personAccountsRecordTypeId){   /// commented by Archana
                 if(obj.RecordTypeId != recTypeAccPerson){
                
                    nonPersonAccounts.add(obj);
                }
                if(countryBasedMap.containsKey(obj.ShippingCountry)){
                    obj.ShippingState = '';
                }
                if(countryBasedMap.containsKey(obj.BillingCountry)){
                    obj.BillingState = '';
                }
               newAccountIdList.add(obj.Id);
            }
/*
            List<Account> childAccountList=[select id, Child_Count__c,parentId from account where parentid in :newAccountIdList];
         
           integer count =0;
        for(Account obj: newTriggerObjects){
              count=0;
              for(Account chlAcc: childAccountList){
                 if(obj.id == chlAcc.parentId){
                  count +=1;
                  
                    if(chlAcc.Child_Count__c != null &&  chlAcc.Child_Count__c >0)
                      count += Integer.valueOf(chlAcc.Child_Count__c);
              
                     }
                  
           }
           obj.Child_Count__c=count;
      }
*/

            TerritoryUtility.standardizeField( 'State', 'BillingState', new Map<String,Object>(), nonPersonAccounts );
            TerritoryUtility.standardizeField( 'Country', 'BillingCountry', new Map<String,Object>(), nonPersonAccounts );
            TerritoryUtility.standardizeField( 'State', 'ShippingState', new Map<String,Object>(), nonPersonAccounts );
            TerritoryUtility.standardizeField( 'Country', 'ShippingCountry', new Map<String,Object>(), nonPersonAccounts );
        }
    }
    
    public static Map<String,String> getIsoBasedCountry(){
        Map<String,String> countryBasedMap = new Map<String,String>();
        List<ISO2_Country__c> isoStateCountryList = [select id,Name,State_Province__c,Country__c,TargetID__c,TargetID__r.State_Province__c,TargetID__r.Country__c,recordType.Name from ISO2_Country__c where TargetID__c != null AND recordType.Name =: 'Country Based'];
        System.debug('!!!!isoStateCountryList::::'+isoStateCountryList);
        System.debug('!!!!isoStateCountryListSize::::'+isoStateCountryList.size());             
        //State map form
        if(isoStateCountryList != null && isoStateCountryList.size() > 0){
            for(ISO2_Country__c echIso : isoStateCountryList){
                if(echIso.recordType.Name == 'Country Based'){                       
                   countryBasedMap.put(echIso.Country__c,echIso.TargetID__r.Country__c);
                }
               
               
            }
        }
        return countryBasedMap;
    }
    /*************
    JIRA Ticket Reference: SO-1589
    Description: This method will update NAM field on childs from the parent below the hierarchy.
    *************/
    public static void updateNAMFieldonAccount(List<Account> newAccountList, Map<Id,Account> oldMapTrigger, System.TriggerOperation triggerEvent){
       Map<Id,Id> mapAccountIdToNAM = new Map<Id,Id>();
       Map<Id,Account> fetchParentAccount;
       Set<Id> parentIds = new Set<Id>();
       switch on triggerEvent {
            when AFTER_UPDATE {
               for(Account accRec : newAccountList){
                   if(accRec.National_Account_Manager__c != oldMapTrigger.get(accRec.id).National_Account_Manager__c && accRec.Type == 'HQ'){ //accRec.National_Account_Manager__c <> NULL && 
                       mapAccountIdToNAM.put(accRec.id, accRec.National_Account_Manager__c);
                   }
               }
              if(mapAccountIdToNAM != null && mapAccountIdToNAM.size()>0){ 
               if(!System.IsBatch()){
                   Database.executeBatch(new Batch_Cascading_NAMAccounts(mapAccountIdToNAM));
               }
            } 
       }
        when BEFORE_INSERT{
            for(Account accRec : newAccountList){
                if(accRec.ParentId <> NULL && accRec.National_Account_Manager__c == null ){
                     parentIds.add(accRec.ParentId);
                 }    
            }
         if(parentIds != null && parentIds.size()>0){    
             fetchParentAccount = new Map<Id,Account>([Select Id, National_Account_Manager__c from Account where ID IN: parentIds]);
         }
         for(Account accRec : newAccountList){
             if(fetchParentAccount != null && fetchParentAccount.containsKey(accRec.ParentId)){
                 accRec.National_Account_Manager__c = fetchParentAccount.get(accRec.ParentId).National_Account_Manager__c;
             }
           }
        }
    }
 }
 /*
  Added by Anil. Used for Melissa Data Integration. 
  This method will update ResultCode to Null whenever shipping address got updated for Canada and US accounts.
 */
 public static void updateResultCodeonAccount(List<Account> newAccountList, Map<Id,Account> oldMapTrigger, System.TriggerOperation triggerEvent){
      switch on triggerEvent {
          when BEFORE_UPDATE {
              for(Account accRec : newAccountList){
              // ('US','United States','USA','Canada','CAD')
                  if(accRec.ResultCode__c <> NULL && accRec.RecordTypeId != recTypeAccPerson
                     && (accRec.shippingCountry == 'US' || accRec.shippingCountry == 'United States' || accRec.shippingCountry == 'USA' || accRec.shippingCountry == 'CAN' || accRec.shippingCountry == 'CAD' || accRec.shippingCountry == 'CA')
                     && (accRec.ShippingStreet <> oldMapTrigger.get(accRec.id).ShippingStreet ||
                         accRec.ShippingState <> oldMapTrigger.get(accRec.id).ShippingState ||
                         accRec.ShippingCountry <> oldMapTrigger.get(accRec.id).ShippingCountry||
                         accRec.ShippingCity <> oldMapTrigger.get(accRec.id).ShippingCity ||
                         accRec.ShippingPostalCode <> oldMapTrigger.get(accRec.id).ShippingPostalCode)){
                             accRec.ResultCode__c ='';
                   }
               }        
           }
       }         
    }
    public static void EnableChildAccountAccess(List<Account> newAccountList, Map<Id,Account> oldMapTrigger, System.TriggerOperation triggerEvent){
         Map<Id,Id> mapAccIdToNewOwnerId = new Map<Id,Id>();
         Map<Id,Id> mapAccIdToOldOwnerId = new Map<Id,Id>();
         Map<Id,Id> mapAccIdToNewParentId = new Map<Id,Id>();
         Map<Id,Id> mapAccIdToOldParentId = new Map<Id,Id>();
         String operationType;
         ChildAccountShare__c settingsConst = ChildAccountShare__c.getinstance('ChidlAccountShare');
         List<String> shippingCountryList = String.valueOf(settingsConst.Shipping_Country_List__c).split(',');
         set<ID> parentIDs = new set<ID>();
          switch on triggerEvent {
              when AFTER_INSERT {
                for(Account accRec : newAccountList){
                   System.debug('1 accRec.ParentId'+accRec);
                   System.debug('1 shippingCountryList.Contains(accRec.ShippingCountry)'+shippingCountryList.Contains(accRec.ShippingCountry));
                   if(accRec.ParentId != null && shippingCountryList.Contains(accRec.ShippingCountry)) { 
                       mapAccIdToNewParentId.put(accRec.id, accRec.ParentId);
                   }
                    if(accRec.parentID!=null){
                       //System.debug('acc.Ultimate_Parent_Account__c == acc.ParentId'+acc.Ultimate_Parent_Account__c == acc.ParentId);
                       System.debug('acc.Ultimate_Parent_Account__c create'+accRec.Ultimate_Parent_Account__c);
                       System.debug('create acc.ParentId'+ accRec.ParentId);
                        parentIDs.add(accRec.ParentId);
                   }
                   System.debug('1 parentIDs'+parentIDs);
                   operationType = 'insert';
                }
               if(mapAccIdToNewParentId != null && mapAccIdToNewParentId.size()>0 ){ 
                   if(!System.IsBatch()){
                       mapAccIdToOldParentId = new Map<Id,Id>();
                       Database.executeBatch(new BatchAddChildAccountsAccessParentId(mapAccIdToNewParentId, mapAccIdToOldParentId, oldMapTrigger,parentIDs,OperationType));
                   }
               } 
            }
            when AFTER_UPDATE {
               for(Account accRec : newAccountList){
                   operationType = 'update';
                    if(oldMapTrigger.size()>0 && !oldMapTrigger.isEmpty()){
                           
                           Account oldAcc =  oldMapTrigger.get(accRec.Id);
                           System.debug('22 inside accRec.ParentId'+accRec.ParentId);
                           System.debug('22 Inside oldAcc.ParentId'+oldAcc.ParentId);
                           if(accRec.ParentId != oldAcc.ParentId || Test.isRunningTest())
                           {
                               parentIDs.add(accRec.ParentId); 
                           }
                       }
                   
                   System.debug('22 inside account handler'+parentIDs);
                   if(shippingCountryList.Contains(accRec.ShippingCountry)) {
                       if(accRec.OwnerId != oldMapTrigger.get(accRec.id).OwnerId) { 
                           mapAccIdToNewOwnerId.put(accRec.id, accRec.OwnerId);
                           mapAccIdToOldOwnerId.put(accRec.id, oldMapTrigger.get(accRec.id).OwnerId);
                       }
                       system.debug('2 accRec'+accRec.name);
                       if(accRec.ParentId != oldMapTrigger.get(accRec.id).ParentId){ 
                           mapAccIdToNewParentId.put(accRec.id, accRec.ParentId);
                           mapAccIdToOldParentId.put(accRec.id, oldMapTrigger.get(accRec.id).ParentId);
                       }
                   }
               }
               if(mapAccIdToNewOwnerId != null && mapAccIdToNewOwnerId.size()>0 && mapAccIdToOldOwnerId != null){ 
                   if(!System.IsBatch()){
                       Database.executeBatch(new BatchAddChildAccountsAccessOwnerId(mapAccIdToNewOwnerId, mapAccIdToOldOwnerId));
                   }
               }
               system.debug('mapAccIdToNewParentId'+mapAccIdToNewParentId);
               if((mapAccIdToNewParentId != null && mapAccIdToNewParentId.size()>0) || (mapAccIdToOldParentId != null && mapAccIdToOldParentId.size()>0)){ 
                   if(!System.IsBatch()){
                       Database.executeBatch(new BatchAddChildAccountsAccessParentId(mapAccIdToNewParentId, mapAccIdToOldParentId,oldMapTrigger,parentIDs, operationType));
                   }
               } 
            }
         }
    }
    
    /*****************************************************************************************************/
    /* Method Name  : createSubtractionOrAddtionAlertforAccounts
     * Author       : Pushkar
    /* Description  : Creating Alert and Account Group Alert Records
    /****************************************************************************************************/
    public static void createSubtractionOrAddtionAlertforAccounts(System.TriggerOperation triggerEvent, map<Id, Account> newMap, map<Id, Account> oldMap ){
        if(runningOnce){
            String triggerEventStr = String.valueOf(triggerEvent);
            Map<Id, List<Account>> hirarchyAdditionMap = new Map<Id, List<Account>>();
            Map<Id, List<Account>> hirarchySubtractionMap = new Map<Id, List<Account>>(); 
            for(Account ac : newMap.values()){
                if( triggerEventStr == 'AFTER_INSERT' || (triggerEventStr == 'AFTER_UPDATE' && ac.parentId != oldMap.get(ac.Id).parentId)){
                    if(ac.parentId != null ){
                        if(hirarchyAdditionMap.get(ac.ParentId) == null){
                            hirarchyAdditionMap.put(ac.ParentId, new List<Account>());
                        }
                        hirarchyAdditionMap.get(ac.ParentId).add(newMap.get(ac.Id));
                    }
                }
                if( triggerEventStr == 'AFTER_UPDATE' && oldMap.get(ac.Id).parentId != null && ac.parentId != oldMap.get(ac.Id).parentId){
                    if(hirarchySubtractionMap.get(oldMap.get(ac.Id).ParentId) == null){
                        hirarchySubtractionMap.put(oldMap.get(ac.Id).ParentId, new List<Account>());
                    }
                    hirarchySubtractionMap.get(oldMap.get(ac.Id).ParentId).add(oldMap.get(ac.Id));                    
                }
            }
            if(triggerEventStr == 'AFTER_INSERT'){
                createHirarchyAlert(hirarchyAdditionMap, 'Addition');
            }else if(triggerEventStr == 'AFTER_UPDATE'){
                createHirarchyAlert(hirarchyAdditionMap, 'Addition');
                createHirarchyAlert(hirarchySubtractionMap, 'Subtraction');
            }
              runningOnce = false;
        }
     }
       
    /*****************************************************************************************************/
    /* Mehod Name : createHirarchyAlert
    /* Description : Creating "Hirarchy Addition" and "Hirarchy Subtraction" Alert and Account Group Alert Records
    /****************************************************************************************************/
    public static void createHirarchyAlert(Map<Id, List<Account>> ParentChildAccountMap , String alertType){
        Map<AccountOrGroupAlert__c, Alert__c > alertAndGroupALertMap = new Map<AccountOrGroupAlert__c, Alert__c>();
        List<Alert__c> newAlertList = new List<Alert__c>();
        for(Id parentAccountID : ParentChildAccountMap.keySet()){
            ////// Creating Alert //////
            Alert__c alertItem = new Alert__c();
            String alertBody = '';
            if(alertType == 'Addition' ){
                alertItem.Subject__c = 'Account(s) Added to Account Hierarchy.';
                alertBody = ParentChildAccountMap.get(parentAccountID).size()+' Account(s) added to hierarchy. \n';
            }else if(alertType == 'Subtraction'){
                alertItem.Subject__c = 'Account(s) Removed from Account Hierarchy.';
                alertBody = ParentChildAccountMap.get(parentAccountID).size()+' Account(s) Removed from hierarchy. \n';
            }
            for(Account addedAccount : ParentChildAccountMap.get(parentAccountID)){
                alertBody += '\n '+addedAccount.Name;
            }
            alertItem.Body__c = alertBody;
            if(alertType == 'Addition'){
                alertItem.AlertType__c = 'Hierarchy Addition';
            }else  if(alertType == 'Subtraction'){
                 alertItem.AlertType__c = 'Hierarchy Subtraction';
            }
            ////// Creating Account Or Group Alert //////
            AccountOrGroupAlert__c AG = new AccountOrGroupAlert__c();
            AG.AccountId__c = parentAccountID;
            alertAndGroupALertMap.put(AG, alertItem);
        }
        //database.insert(alertAndGroupALertMap.values());
        if (alertAndGroupALertMap.values() != null && alertAndGroupALertMap.values().size() > 0) {
                List < Database.SaveResult > insertActionPlanResults = Database.Insert(alertAndGroupALertMap.values(), false);
                List < Database.Error > listError = new List <Database.Error> ();
                for (Integer index = 0, size = insertActionPlanResults.size(); index < size; index++) {
                    if (!insertActionPlanResults[index].isSuccess()) {
                        listError.addAll(insertActionPlanResults[index].getErrors());
                    }
                }
                if (listError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(listError, 'AccountTriggerHandler', 'createHirarchyAlert', 'Alert__c', 'Database.Insert_Failed');
                }
        } 
       //Updating AlertId in GroupAlerts
        List<AccountOrGroupAlert__c> groupList = new List<AccountOrGroupAlert__c>();
        for(AccountOrGroupAlert__c groupAlert : alertAndGroupALertMap.Keyset()){
            groupAlert.AlertId__c = alertAndGroupALertMap.get(groupAlert).Id;
            groupList.add(groupAlert);
        }
        //Database.insert(groupList, false) ;
        if (groupList != null && groupList.size() > 0) {
                List < Database.SaveResult > insertActionPlanResults = Database.Insert(groupList, false);
                List < Database.Error > listError = new List <Database.Error> ();
                for (Integer index = 0, size = insertActionPlanResults.size(); index < size; index++) {
                    if (!insertActionPlanResults[index].isSuccess()) {
                        listError.addAll(insertActionPlanResults[index].getErrors());
                    }
                }
                if (listError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(listError, 'AccountTriggerHandler', 'createHirarchyAlert', 'AccountOrGroupAlert__c', 'Database.Insert_Failed');
                }
        }
        System.debug('--Group Alert--'+groupList);
    }
    // This Method is used to populate Account Record Type Id based on the MDM Record Type value when Account is created/updated by MDM Integration users  
    public static void populateRecordTypeId(List<Account> accList, Map<Id,Account> oldMap, Boolean isupdate) {  
        Map<String,Schema.RecordTypeInfo> rtAccMap = Account.sobjectType.getDescribe().getRecordTypeInfosByDeveloperName();
        for(Account acc: accList) {
            if(acc.MDM_RecordType__c != null) {
                if((oldMap !=null && (acc.MDM_RecordType__c != oldMap.get(acc.Id).MDM_RecordType__c)) || isupdate == false) {                    
                    acc.RecordTypeId = rtAccMap.get(acc.MDM_RecordType__c).getRecordTypeId(); 
                }                                   
                
            }
        }
    }
      /*****************************************************************************************************/
    /* Mehod Name : updateTerritoryAssigner
    /* Description : Populate Territory Assigner field when shipping code is not null and country is US
    /* Ticket : SFDC - 0000003191 and Business Requirement: BREQ - 0000000521
    /* Added By : Shreya Raut
    /****************************************************************************************************/
    
    public static void updateTerritoryAssigner(List<Account> accList)
    {
        Set<String> AccZipCode = new Set<String>();
        for (Account azip : accList) {
            AccZipCode.add(azip.ShippingPostalCode);
        }
        /*Map<String,Territory_Assigner__c> TAZipcode = new Map<String,Territory_Assigner__c>();
        if(AccZipCode.size()>0){
            for(Territory_Assigner__c TAZ : [Select id,Zip_Code__c from Territory_Assigner__c WHERE Zip_Code__c IN : AccZipCode])
            {
                TAZipcode.put(TAZ.Zip_Code__c,TAZ);
            }
        }
        for(Account acc : accList){
            Id id = null;
            if(TAZipcode != Null && TAZipcode.size()>0){
                if(TAZipcode.keyset().contains(acc.ShippingPostalCode) && (acc.ShippingCountry =='US'|| acc.ShippingCountry =='United States' ||acc.ShippingCountry == 'USA')){
                    acc.Territory_Assigner__c =TAZipcode.get(acc.ShippingPostalCode).id;
                }
                else{
                     acc.Territory_Assigner__c =id ; 
                }
            }else{
                acc.Territory_Assigner__c =id ; 
            }
        }*/
    }
    
    /*****************************************************************************************************/
    /* Mehod Name : updateTerritoryAssigner
    /* Description : Update Contact owner same as account owner when account owner get updated.
    /* Ticket : Process builder to trigger conversion.
    /* Added By : Pooja Gite
    /*****************************************************************************************************/
    //trigger AccountContractTrigger on Account (after update) {
    public static void AccountContractTrigger(List<Account> accList,Map<Id,Account> accoldMap){
    Set<Id> accountIds = new Set<Id>();
    Map<Id, String> oldOwnerIds = new Map<Id, String>();
    Map<Id, String> newOwnerIds = new Map<Id, String>();
    List<Contact> contactUpdates = new List<Contact>();
    //Id personAccountsRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND Name = 'Person Account' LIMIT 1].Id;
    for (Account a : accList)
    {
        if (a.OwnerId != accoldMap.get(a.Id).OwnerId)
        {
            oldOwnerIds.put(a.Id, accoldMap.get(a.Id).OwnerId);
            newOwnerIds.put(a.Id, a.OwnerId);
            accountIds.add(a.Id);
        }
    }
        System.debug('accountIds-->'+accountIds);
    if (!accountIds.isEmpty()) {
        for (Account acc : [SELECT Id,RecordTypeId, (SELECT Id, OwnerId FROM Contacts) FROM Account WHERE Id in :accountIds])
        {
            String newOwnerId = newOwnerIds.get(acc.Id);
            String oldOwnerId = oldOwnerIds.get(acc.Id);
               System.debug('acc-->'+acc);
            //If(newOwnerId != oldOwnerId && personAccountsRecordTypeId !=acc.RecordTypeId ){
                If(newOwnerId != oldOwnerId && recTypeAccPerson !=acc.RecordTypeId ){
                for (Contact c : acc.Contacts)
                {
                    System.debug('Inside innser loop-->');
                        Contact updatedContact = new Contact(OwnerId = newOwnerId, Id = c.Id);
                        contactUpdates.add(updatedContact);
                   
                }
            }
        }
    }
    if(contactUpdates.size()>0)
        update contactUpdates;
}   
    
    /*****************************************************************************************************/
    /* Mehod Name : updateLatitudeLogitudeAccount
    /* Description : updateLatitudeLogitudeAccount
    /* Ticket : Process builder to trigger conversion - SFDC - 0000004010
    /* Added By : Ramya Ganeshkar
    /*****************************************************************************************************/
     public static void updateLatitudeLogitudeAccount(Map<Id,Account> oldMap, List<Account> newMap){
        System.debug('oldMap-->'+oldMap);
        System.debug('newMap-->'+newMap);
        
        for(Account acc:newMap){
            if(acc.MAVerifiedLatitude__c  != oldMap.get(acc.id).MAVerifiedLatitude__c ){
                System.debug('inside if');
                acc.MALatitude__c= acc.MAVerifiedLatitude__c;
                acc.MAVerifiedLatitude__c=null;
            }
            if(acc.MAVerifiedLongitude__c  != oldMap.get(acc.id).MAVerifiedLongitude__c){
                System.debug('inside longi');
                acc.MALongitude__c = acc.MAVerifiedLongitude__c;
                acc.MAVerifiedLongitude__c = null;
                
            }
        }        
    }
    
     /*****************************************************************************************************/
    /* Method Name : updateComplianceMechanism
    /* Description : Update Compliance Mechanism.
    /* Ticket : Process builder to trigger conversion.
    /* Added By : Pooja Gite
    /*****************************************************************************************************/
    public static void updateComplianceMechanism(Map<Id,Account> newMap,Map<Id,Account> oldMap){
        Map<Id,Id> mapUser =new Map<Id,Id>();
        
        for(Account acc:newMap.values()){
            mapUser.put(acc.id,acc.MapAnythingComplianceMechanism__c);
             }
        Map<Id,User> userMap= new Map<Id,User>([Select LastName,Id,Name FROM User where ID IN:mapUser.values()]);
        
        for(Account acc:newMap.values()){
            if(acc.MapAnythingComplianceMechanism__c  != oldMap.get(acc.id).MapAnythingComplianceMechanism__c && acc.MapAnythingComplianceMechanism__c!=null){
                
                if(oldMap.get(acc.id).ComplianceMechanism__c ==null){
                    acc.ComplianceMechanism__c= userMap.get(mapUser.get(acc.id)).LastName;
                }
                else{
                    if(!oldMap.get(acc.id).ComplianceMechanism__c.contains(userMap.get(mapUser.get(acc.id)).LastName))
                       acc.ComplianceMechanism__c=oldMap.get(acc.id).ComplianceMechanism__c  + ';' + userMap.get(mapUser.get(acc.id)).LastName;
                    else
                    {
                         acc.ComplianceMechanism__c=oldMap.get(acc.id).ComplianceMechanism__c ;  
                    }
                }
                
            }
        }
    }
    
    /*****************************************************************************************************/
    /* Mehod Name : accountMasterCreateEditUpdate
    /* Description : accountMasterCreateEditUpdate
    /* Ticket : Process builder to trigger conversion - SFDC - 0000004010
    /* Added By : Ramya Ganeshkar
    /*****************************************************************************************************/
     
    public static void accountMasterCreateEditUpdate(Map<Id, Account> oldMap, List<Account> newMap){
       // System.debug('oldMap--> ' +oldMap);
        //System.debug('newMap--> ' +newMap);
        //Decimal syncId; 
        for(Account acc : newMap){
            
        /*    if(((acc.JUUL_on_Store_Locator__c == true) && (acc.JUUL_on_Store_Locator__c != oldMap.get(acc.Id).JUUL_on_Store_Locator__c )) || 
               ((acc.Request_for_account_to_be_on_locator__c !=oldMap.get(acc.Id).Request_for_account_to_be_on_locator__c) && (acc.Does_Business_As_DBA__c == null))){
                   acc.addError('Please fill "Does Business As (DBA)" with the store name that will appear on the store locator.');
               }            */    
               
            //  If Resync Locator is true --> before update
            if((acc.Resync_to_Locator__c != oldMap.get(acc.id).Resync_to_Locator__c) && (acc.Resync_to_Locator__c == true) 
               && (acc.Locator_Request_Receipt__c == oldMap.get(acc.id).Locator_Request_Receipt__c) && (acc.Locator_Request_Receipt__c != null) ){
                    acc.Locator_Request_Receipt__c = null;
            }
            
            //  If Sync ID is populated
            if((acc.Locator_Request_Receipt__c != oldMap.get(acc.Id).Locator_Request_Receipt__c) && (acc.Locator_Request_Receipt__c != null) && 
               (acc.Resync_to_Locator__c == oldMap.get(acc.Id).Resync_to_Locator__c) && (acc.Resync_to_Locator__c == true)){
                   acc.Resync_to_Locator__c = false;
               }
            
           
             // If Sync Id is populated 
          //  System.debug('If Sync Id is populated-->' +acc);
            if((acc.Locator_Request_Receipt__c != null) && (acc.Request_for_account_to_be_on_locator__c  == true) && 
            
               (acc.Locator_Request_Receipt__c != oldMap.get(acc.Id).Locator_Request_Receipt__c) && (acc.Deactivate_on_Locator__c == true)){ // (acc.Locator_Request_Receipt__c == acc.Locator_Request_Receipt__c) &&
                   System.debug('inside Sync condition==>' );
                   acc.Deactivate_on_Locator__c = false;
                  acc.Locator_Request_Receipt__c = acc.Locator_Request_Receipt__c ;
                   acc.Request_for_account_to_be_on_locator__c = false;
                   acc.Activated_On_Locator__c = false; // checking
                   //acc.Resync_to_Locator__c = true;//checking
               }          
            
             // If Deactivate on Locator is true
            if((acc.Deactivate_on_Locator__c ==true) && ((acc.Activated_On_Locator__c == true) || (acc.Locator_Request_Receipt__c != null) || 
                                                      (acc.Request_for_account_to_be_on_locator__c == false))){
                                                          acc.Activated_On_Locator__c = false;
                                                          acc.Deactivate_on_Locator__c = true;
                                                         // syncId = acc.Locator_Request_Receipt__c;
                                                          acc.Locator_Request_Receipt__c = null;
                                                      } 
            
                                                    
            //  If Request for account to be on locator is TRUE            
            if(acc.Date_of_Newest_Sales_Order__c == oldMap.get(acc.Id).Date_of_Newest_Sales_Order__c){
            //    System.debug('Inside date ');
            if((acc.Request_for_account_to_be_on_locator__c == true) && (acc.Deactivate_on_Locator__c == false) && ((acc.ShippingCountry == 'US') || (acc.ShippingCountry == 'CA'))){
             
                acc.Activated_On_Locator__c = true;
            } 
            }
            
            //  Deactivate Locator Based on Account Status
            if(((acc.Status__c == 'Blacklisted') || (acc.Status__c == 'Disqualified') || (acc.Status__c == 'Business Closed') || (acc.Status__c == 'Recycle')) && 
               (acc.Status__c != oldMap.get(acc.Id).Status__c) && (acc.Activated_On_Locator__c == true)){
                   acc.Activated_On_Locator__c = false;
                   acc.Deactivate_on_Locator__c = true;
                   acc.Locator_Request_Receipt__c = null;
               }
            //System.debug('1.acc.Resync_to_Locator__c -'+acc.Resync_to_Locator__c);
            //  If Request for account to be on locator and Activated on locator is True
            if(((acc.Request_for_account_to_be_on_locator__c ==true) && (acc.Activated_On_Locator__c == true)) &&
               ((acc.Does_Business_As_DBA__c != oldMap.get(acc.Id).Does_Business_As_DBA__c) || (acc.MALatitude__c != oldMap.get(acc.Id).MALatitude__c) || 
               (acc.MALongitude__c != oldMap.get(acc.Id).MALongitude__c) || (acc.ShippingStreet != oldMap.get(acc.Id).ShippingStreet) || 
                (acc.ShippingCity != oldMap.get(acc.Id).ShippingCity) || (acc.ShippingPostalCode != oldMap.get(acc.Id).ShippingPostalCode))){
                    if(acc.Locator_Request_Receipt__c != null && acc.Resync_to_Locator__c == false){
                        acc.Locator_Request_Receipt__c = null;
                        acc.Resync_to_Locator__c = true;
                    }
                }
            System.debug('2.acc.Resync_to_Locator__c -'+acc.Resync_to_Locator__c);
            
            //  US / CA - If active on Store Locator and account status moves to Blacklisted/Suspended, remove from store locator
            if(((acc.Status__c == 'Blacklisted') || (acc.Status__c == 'Suspended')) && (acc.Activated_On_Locator__c == true) && 
               ((acc.ShippingCountry == 'US') || (acc.ShippingCountry == 'CA'))){
             
                   acc.Account_On_Store_Locator__c = false;
                   acc.Resync_to_Locator__c = true;
                    //System.debug('Resync_to_Locator__c 537-->' +acc.Resync_to_Locator__c);
               }
            
            if(acc.Date_of_Newest_Sales_Order__c != null){
            Date greaterDate = Date.Today().addDays(-120);
            //System.debug('greater Date --->' +greaterDate);

             Date salesDate = acc.Date_of_Newest_Sales_Order__c;
            
            
             if((salesDate >= greaterDate) && (acc.Status__c == 'Customer (Reporting)') && (acc.ShippingCountry == 'CA') && 
               (acc.Activated_On_Locator__c == false) && (acc.Does_Business_As_DBA__c != null)){
                 // System.debug('inside-if condn -->' +(d3 >= 120));
                   if(acc.Request_for_account_to_be_on_locator__c == false){
                       //System.debug('inside request acc==>');
                       acc.Request_for_account_to_be_on_locator__c = true;
                   }
               }
            }
            
             //US - Remove from store locator if Active but no depletion data last 120 days
            if(acc.Date_of_Newest_Sales_Order__c != null){
            Date lesserDate = Date.Today().addDays(-120);
           // System.debug('lesser Date --->' +lesserDate);
            
            Date salesOrderDate = acc.Date_of_Newest_Sales_Order__c;
           
            
            if((salesOrderDate < lesserDate) && (acc.Status__c == 'Customer (Reporting)') && (acc.ShippingCountry == 'US') && 
               (acc.Activated_On_Locator__c == true)){
                   acc.Account_On_Store_Locator__c = false;
                            acc.Resync_to_Locator__c = true;
               } 
              //  System.debug('4.acc.Resync_to_Locator__c -'+acc.Resync_to_Locator__c);
            }     
            
            //JTP-133
            if((acc.Does_Business_As_DBA__c !=oldMap.get(acc.Id).Does_Business_As_DBA__c) ||(acc.RACS_Status__c !=oldMap.get(acc.Id).RACS_Status__c) ||
            (acc.Retailer_Community_Claimed__c !=oldMap.get(acc.Id).Retailer_Community_Claimed__c) ||(acc.ShippingStreet != oldMap.get(acc.Id).ShippingStreet) || 
               (acc.ShippingCity != oldMap.get(acc.Id).ShippingCity) || (acc.ShippingPostalCode != oldMap.get(acc.Id).ShippingPostalCode) ||
               (acc.ShippingState  != oldMap.get(acc.Id).ShippingState ) ||(acc.ShippingCountry != oldMap.get(acc.Id).ShippingCountry) ||
               (acc.Does_Business_As_DBA__c !=oldMap.get(acc.Id).Does_Business_As_DBA__c) || (acc.Status__c !=oldMap.get(acc.Id).Status__c))
            {
            acc.Resync_to_Locator__c = true;
            }
            //System.debug('5.acc.Resync_to_Locator__c -'+acc.Resync_to_Locator__c);
        }
    }
    
    /*****************************************************************************************************/
    /* Mehod Name : accountMasterCreateEditInsert
    /* Description : accountMasterCreateEditInsert
    /* Ticket : Process builder to trigger conversion - SFDC - 0000004010
    /* Added By : Ramya Ganeshkar
    /*****************************************************************************************************/
    public static void accountMasterCreateEditInsert(List<Account> newMap){
        for(Account a : newMap){
            //  If Deactivate on Locator is true
           if((a.Deactivate_on_Locator__c ==true) && ((a.Activated_On_Locator__c == true) || (a.Locator_Request_Receipt__c != null) || 
                                                      (a.Request_for_account_to_be_on_locator__c == false))){
                                                          a.Activated_On_Locator__c = false;
                                                          a.Deactivate_on_Locator__c = true;
                                                          a.Locator_Request_Receipt__c = null;
                                                      }
            
            //  If Request for account to be on locator is TRUE
            if((a.Request_for_account_to_be_on_locator__c == true) && (a.Deactivate_on_Locator__c == false) && ((a.ShippingCountry == 'US') || (a.ShippingCountry == 'CA'))){
             
                a.Activated_On_Locator__c = true;
            }
            
          
            
            //  US / CA - If active on Store Locator and account status moves to Blacklisted/Suspended, remove from store locator
            if(((a.Status__c == 'Blacklisted') || (a.Status__c == 'Suspended')) && (a.Activated_On_Locator__c == true) && 
               ((a.ShippingCountry == 'US') || (a.ShippingCountry == 'CA'))){
                   a.Account_On_Store_Locator__c = false;
                   a.Resync_to_Locator__c = true;
               }
        }
    }
    
 /*****************************************************************************************************/
    /* Mehod Name : automaticCaseCreation
    /* Description : This method is used to create case based on conditions
    /* Ticket : Case automation creation -- SFDC - 0000005225
    /* Added By : Ramya Ganeshkar
    /*****************************************************************************************************/
    public static void automaticCaseCreation(List<Account> newAccLst, Map<Id,Account> oldAccMap){
      System.debug('Inside automaticCaseCreation');
       if(skipTriggerMethodFromTestClass ==true){
         Set<Id> accId = new Set<Id>();
       
        Id recTypeCase;
        Map<String,Schema.RecordTypeInfo> rtMapCase = Schema.SObjectType.Case.getRecordTypeInfosByName();
        recTypeCase = rtMapCase.get('EAC Certification').getRecordTypeId(); 
        System.debug('recTypeCase-->' +recTypeCase); 
        Id fId;
        Id Contactid;
        List<Case> caseLst = new List<Case>();   
        Id IndeRetailerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
     
       /* set<ID> accParentIDs = new set<ID>();
        for(Account a : newAccLst)
        {
            accParentIDs.add(a.ParentId);
        }
        system.debug('accParentIDs'+accParentIDs);*/
        Group grpId = [SELECT Id, Name  FROM Group where Type = 'Queue' AND Name = 'EAC Certification' LIMIT 1];
        //for(Account ac : oldAccMap.values()){
        //List<disco__Form__c> lstForm = new List<disco__Form__c>([SELECT id, Name From disco__Form__c WHERE disco__Form_Account__c IN: newAccLst  Order By CreatedDate DESC LIMIT 1]);
        List<Contact> lstCont = new List<Contact>([SELECT id, Name From Contact WHERE AccountId IN: newAccLst Order By CreatedDate DESC LIMIT 1]);
       
       System.debug('newAccLst::'+newAccLst);
        for(Account ac : newAccLst){
        System.debug('ac.X2D_Bar_Scanner__c::'+ac.X2D_Bar_Scanner__c);
         System.debug('ac.RACS_Status__c ::'+ac.RACS_Status__c  +  '::: Old Map ::'+oldAccMap.get(ac.Id).RACS_Status__c );
          System.debug('ac.EAC_Certification_Pathway_Status__c::'+ac.EAC_Certification_Pathway_Status__c);
           System.debug('ac.Type::'+ac.Type);
           
            //if(ac.EAC_Certification_Status__c != oldAccMap.get(ac.Id).EAC_Certification_Status__c && ac.EAC_Certification_Status__c == 'Certification Pending' ){ //newAccLst.EAC_Certification_Status__c == 'Certification Pending'
             //  if( (ac.X2D_Bar_Scanner__c == true || ac.Mag_Strip_Reader__c== true) && ac.Pathway_Status__c != oldAccMap.get(ac.Id).Pathway_Status__c && ac.Pathway_Status__c == 'Certification Pending' && ac.EAC_Certification_Status__c == 'Further Evidence Needed' ){
            if( (ac.X2D_Bar_Scanner__c == true || ac.Mag_Strip_Reader__c== true) && ac.RACS_Status__c != oldAccMap.get(ac.Id).RACS_Status__c && ac.RACS_Status__c == 'Ready' && ac.PA_EAC_Cert_Pathway_Status__c=='Door Level' &&  ac.Type != 'HQ'  ){
              /* if(lstForm != null && lstForm.size() > 0 && ac.Update_via_SelfCert__c  == false){
                    for(disco__Form__c dis :lstForm ){ 
                        fId= dis.id;
                    }                     
                }*/
                
                if(lstCont != null && lstCont.size() >0){
                    for(contact cnt :lstCont ){
                        Contactid= cnt.id; 
                    }                     
                }
                
                //for(ID  f : fId ){
                Case c = new Case();
                c.RecordTypeId = recTypeCase;
                c.AccountId = ac.Id;
                c.Status = 'New';
                c.OwnerId = grpId.Id;                
                c.Market__c = 'United States';
                
               if(fId!=null && ac.Update_Via_EAC_Process__c==false){
                  //  c.Form__c = fId;
                    c.Origin='EAC Certification';
                }  
                if(contactid!=null){
                    c.ContactId=contactid;
                }
                if(ac.Chain_Expansion__c == 'New Construction'&& ac.Update_Via_EAC_Process__c==true ){
                     c.Origin = 'EAC Certification New Construction';
                }
                if(ac.Chain_Expansion__c == 'M&A'&& ac.Update_Via_EAC_Process__c==true){
                     c.Origin = 'EAC Certification M&A';
                }
                caseLst.add(c);
            }
        }
        insert caseLst;
    }
    }
    

    public static void updateEACStatus(List<Account> accList, Map<Id,Account> oldAccount){
        
        for(Account acc : accList)
        {
            if(oldAccount.size()>0 && !oldAccount.isEmpty()){
                
                Account oldAcc =  oldAccount.get(acc.Id);
                if(oldAcc.Pathway_Status__c != acc.Pathway_Status__c && acc.Pathway_Status__c!=null){
                    if(acc.Pathway_Status__c=='Certification Pending')
                    {
                        acc.RACS_Status__c ='Certification Pending';
                    }
                    else if(acc.Pathway_Status__c=='EAC Ready')
                    {
                        acc.RACS_Status__c ='Ready';
                    }
                    else if(acc.Pathway_Status__c=='Declined EAC')
                    {
                        acc.RACS_Status__c ='Not Committed';
                    }
                    else if(acc.Pathway_Status__c=='Committed - Not EAC Ready')
                    {
                        acc.RACS_Status__c ='Committed';
                    }
                     else if(acc.Pathway_Status__c=='KDM Not Contacted')
                    {
                        acc.RACS_Status__c ='Not Contacted';
                    }
                    
                }
            }
        }
        
    }
    
   
    public static void UpdateDateStampDate(List<Account> accList, Map<Id,Account> oldAccount, System.TriggerOperation triggerEvent){
       switch on triggerEvent{
        when BEFORE_UPDATE {
    for(Account acc : accList)
        {
            if(oldAccount.size()>0 && !oldAccount.isEmpty())
            {
                Account oldAcc =  oldAccount.get(acc.Id);
                if(oldAcc.ParentId <> acc.ParentId)
                {
                    acc.Last_Parent_Account_Update__c = System.today();
                    System.debug('acc.Last_Parent_Account_Update__c-'+acc.Last_Parent_Account_Update__c + acc.Name);
                }
            }
        }
       }
        //Start-Added by Pooja G for JTP-164
        when BEFORE_INSERT{
        for(Account acc : accList)
            {
                if(acc.ParentId != null){   
                     acc.Last_Parent_Account_Update__c = System.today(); 
                }
            } 
        }
        //End-Added by Pooja G for JTP-164
    }
 }
    
    /**************************************************************************************************************************/ 
    /*Description: Method to update the NSL Effective date On Account                 */
    /* Ticket : JTP-183                                                                      */
    /* Added By : Subodh Shukla                                                                                             */
    /**************************************************************************************************************************/
    public static void UpdateNSLEffectiveDate(List<Account> accList)
    {
        for(Account acc : accList)
        {
            if(acc.NSL_Effective_Date2__c!= Null){
                acc.NSL_Effective_Date__c=acc.NSL_Effective_Date2__c;
               
            }
            
            if(acc.NSL_Effective_Date2__c== Null){
                acc.NSL_Effective_Date__c=Null;
               
            }
        }
    }
    
    /**************************************************************************************************************************/ 
    /*Description: This method to nullify EAC fields on record type update to distributor.                 */
    /* Ticket : JTP-232                                                                      */
    /* Added By : Pooja Gite                                                                                            */
    /**************************************************************************************************************************/
  public static void nullifyEACField(List<Account> newAccLst, Map<Id,Account> oldAccount){
      Id recTypeAccount;
        Map<String,Schema.RecordTypeInfo> rtMapAccount = Schema.SObjectType.Account.getRecordTypeInfosByName();
        recTypeAccount = rtMapAccount.get('Distributor').getRecordTypeId(); 
        System.debug('recTypeCase-->' +recTypeAccount); 

        for(Account ac : newAccLst){
            if(ac.RecordTypeId == recTypeAccount || ac.RecordType.Name == 'Distributor'){
                ac.RACS_Status__c = null;
                ac.EAC_Certification_Status__c= null;
            }
        }
  }
    
    /**************************************************************************************************************************/ 
    /*Description: This method to update EAC Certification Status fields on POS Provider value update.                 */
    /* Ticket : JTP-274 (Sub Task JTP-286)                                                                    */
    /* Added By : Pooja Gite                                                                                            */
    /**************************************************************************************************************************/
    public static void SMTfieldUpdate(List<Account> newAccLst){
        System.debug('Inside SMTfieldUpdate');
         for(Account acc : newAccLst)
         {
             if(acc.CurrentPOSProvider__c == 'Smart Trade Fixture' && acc.RACS_Status__c != 'Certified'){
                 //acc.EAC_Certification_Status__c = 'Certification Pending';
                 acc.AV_Capable__c = true;
                 acc.QPL_Capable__c = true;
             }
         }
    }

    /**************************************************************************************************************************/ 
    /*Description: This method to update Chain Expansion field on the basis of criteria.                 */
    /* Ticket : JTP-287                                                                     */
    /* Added By : Pooja Gite                                                                                            */
    /**************************************************************************************************************************/    
    public static void updateChainExpansion( Map<Id,Account>newaccMap , List<Account>accList , Map<Id,Account> oldAccount , System.TriggerOperation triggerEvent){
       if(skipTriggerMethodFromTestClass==true){
       Id IndeRetailerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Independent Retailer').getRecordTypeId();
     Id ChainAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Chain Retail').getRecordTypeId();
    Set<Id>parentAccId= new Set<Id>();
     switch on triggerEvent{
      when BEFORE_INSERT{
        for(Account acc : accList)
        {
              if(acc.ParentId != null && acc.RecordTypeId == ChainAccountRecordTypeId){   
                     acc.Chain_Expansion__c = 'New Construction'; 
                }
              if(acc.ParentId != null && acc.RecordTypeId == IndeRetailerAccountRecordTypeId){
                    acc.Chain_Expansion__c = 'M&A';
               }
              //Start-Added by PoojaG for Ticket JTP-288
                 if(acc.ParentId != Null){
                    acc.EAC_Certification_Status__c = 'Further Evidence Needed';
                }
        //Stop-Added by PoojaG for Ticket JTP-288
       } 
        }
        when BEFORE_UPDATE {
        
        for(Account ac1:accList)
        {
             if(ac1.ParentId != Null){
                   parentAccId.add(ac1.ParentId);
                }
        
           }
        
    List<Account>parentacc=new List<Account>([select id,RACS_Status__c from account where id IN: parentAccId]);
  //  System.debug('****************************Parent Account ID '+parentacc);
    
  For(Account ACparent : parentacc) { 
    for(Account acc : accList)
        {
            if(oldAccount.size()>0 && !oldAccount.isEmpty())
            {
                Account oldAcc = oldAccount.get(acc.Id);
                if(oldAcc.ParentId <> acc.ParentId && acc.RecordTypeId == IndeRetailerAccountRecordTypeId ){
                    acc.Chain_Expansion__c = 'M&A';
                }
                if(oldAcc.ParentId <> acc.ParentId && acc.RecordTypeId == ChainAccountRecordTypeId){
                    acc.Chain_Expansion__c = 'M&A'; 
                }
                //Start-Added by PoojaG for Ticket JTP-288
                 if(acc.RACS_Status__c!=null && ACParent.RACS_Status__c!=null && oldAcc.ParentId <> acc.ParentId ){
                 //added by Subodh for JTP-423
                  if(ACParent.RACS_Status__c.equals('Ready')|| ACParent.RACS_Status__c.equals('Certified')){    
                  //System.debug( '############################889##########'+ACParent.RACS_Status__c);
                  //System.debug( '############################889##########'+acc.RACS_Status__c);
  
                     
                       If(!acc.RACS_Status__c.equals('Ready') || !acc.RACS_Status__c.equals('Certified') ){   
                                                     
                               //System.debug( '############################Line Number 894 ##########'+acc.RACS_Status__c);
                                     acc.EAC_Certification_Status__c = 'Further Evidence Needed';
                                      // System.debug( '############################906##########'+acc.EAC_Certification_Status__c);
                 
                          }                
                     
                     
                     
                     
                     
                     
                     
                        
                     If(acc.RACS_Status__c.equals('Ready') || acc.RACS_Status__c.equals('Certified') )
                     {     

                        acc.EAC_Certification_Status__c = 'Certification Passed';
                         


                      }
                            
                            //If(acc.Chain_Expansion__c=='New Construction' ||acc.RACS_Status__c!='Ready' || acc.RACS_Status__c!='Certified' ){
                          
                            
                             }
                             
                   
                  }
                 
                 // acc.EAC_Certification_Status__c = 'Further Evidence Needed';
                 //Commented by Subodh For Ticket JTP-423
                 
                 
                }
        //Stop-Added by PoojaG for Ticket JTP-288
            }
        }
        }
       }
    }
    }

    public static void handleCustomerOrgUnitsAssign(Map<Id,Account> newMap,Map<Id,Account> oldMap,System.TriggerOperation triggerEvent){
        Map<Id,String> postalCodeHavingActIds = new Map<Id,String>();
        Map<Id,String> salesOrgHavingActIds = new Map<Id,String>();
        Map<String,Id> actMatchingPostalCodeOrgUnitIds = new Map<String,Id>();

        Map<Id,String> updatedPostalCodeActIds = new Map<Id,String>();
        Set<Id> deletedPostalCodeActIds = new Set<Id>();    
        
        Set<Id> allowedRecordTypeIds = new Set<Id>();

        Set<String> recordTypesForAutomation = new Set<String>();

        recordTypesForAutomation.add('Independent Retailer');
        recordTypesForAutomation.add('Chain Retail');
        recordTypesForAutomation.add('Regional Chain Retailer');

        //note : the record type criteria will change when the business is ready to move forward with a streamlined model, for now this automation allowing for all record types by commenting record type filter code in all areas , need to open commented code once the record types are finalised to filter in this automation
        for(RecordType recordTypeRec : [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Account' AND Name IN : recordTypesForAutomation]){
             allowedRecordTypeIds.add(recordTypeRec.Id);
         }


        switch on triggerEvent {
            when AFTER_INSERT {   
               
                for(Account actRec:newMap.values()){      
                    
                    if(allowedRecordTypeIds.contains(actRec.RecordTypeId)){
                        if(!(string.isBlank(actRec.ShippingPostalCode)) && !(string.isBlank(actRec.cgcloud__Sales_Org__c))){
                            postalCodeHavingActIds.put(actRec.Id,actRec.ShippingPostalCode);
                            salesOrgHavingActIds.put(actRec.Id,actRec.cgcloud__Sales_Org__c);
                            
                        }
                    }    
                }   
                System.debug('final '+postalCodeHavingActIds+' '+salesOrgHavingActIds);
                if(postalCodeHavingActIds.size()>0 && !postalCodeHavingActIds.isEmpty()){
                    //System.debug('final '+postalCodeHavingActIds.values()+' '+salesOrgHavingActIds.values());
                    for(cgcloud__Org_Unit__c orgUnitRec : [SELECT Id,Zip_Code__c FROM cgcloud__Org_Unit__c WHERE Zip_Code__c IN : postalCodeHavingActIds.values() and cgcloud__Sales_Org__c IN : salesOrgHavingActIds.values()]){
                        System.debug('final '+orgUnitRec);
                        actMatchingPostalCodeOrgUnitIds.put(orgUnitRec.Zip_Code__c,orgUnitRec.Id);                 
                    }
                    
                    List<cgcloud__Account_Org_Unit__c> customerOrgUnitsList = New List<cgcloud__Account_Org_Unit__c>();
                    for(Id key: postalCodeHavingActIds.keySet()){

                        
                        if(actMatchingPostalCodeOrgUnitIds.size()>0 && !actMatchingPostalCodeOrgUnitIds.isEmpty() && actMatchingPostalCodeOrgUnitIds.containsKey(postalCodeHavingActIds.get(key)) && actMatchingPostalCodeOrgUnitIds.get(postalCodeHavingActIds.get(key)) != null){
                            cgcloud__Account_Org_Unit__c customerOrgUnitRec = New cgcloud__Account_Org_Unit__c();
                            customerOrgUnitRec.cgcloud__Account__c = key;
                            customerOrgUnitRec.cgcloud__Org_Unit__c = actMatchingPostalCodeOrgUnitIds.get(postalCodeHavingActIds.get(key));
                            customerOrgUnitRec.cgcloud__Valid_From__c = System.today();
                            customerOrgUnitRec.cgcloud__Valid_Thru__c = Date.newInstance(2099, 12, 31);
                            customerOrgUnitsList.add(customerOrgUnitRec);
                        }                   

                    }
                    System.debug('After Insert, Customer Org Units: ' + customerOrgUnitsList);
                    if(customerOrgUnitsList.size() > 0){
                        insert customerOrgUnitsList;
                    }
                }                 
 
            }        
            when AFTER_UPDATE { 
                
                for(Account actNewRec : newMap.values()){ 

                    if(allowedRecordTypeIds.contains(actNewRec.RecordTypeId) && allowedRecordTypeIds.contains(oldMap.get(actNewRec.id).RecordTypeId)){
                        if((!(string.isBlank(actNewRec.ShippingPostalCode))  && !(string.isBlank(oldMap.get(actNewRec.id).ShippingPostalCode))) && !(string.isBlank(actNewRec.cgcloud__Sales_Org__c))){    
                            if(actNewRec.ShippingPostalCode != oldMap.get(actNewRec.id).ShippingPostalCode)  { 
                                deletedPostalCodeActIds.add(actNewRec.id);
                                postalCodeHavingActIds.put(actNewRec.Id,actNewRec.ShippingPostalCode);
                                salesOrgHavingActIds.put(actNewRec.Id,actNewRec.cgcloud__Sales_Org__c);
                            }else if((actNewRec.ShippingPostalCode == oldMap.get(actNewRec.id).ShippingPostalCode) && (!(string.isBlank(actNewRec.cgcloud__Sales_Org__c)) && string.isBlank(oldMap.get(actNewRec.id).cgcloud__Sales_Org__c))){
                                postalCodeHavingActIds.put(actNewRec.Id,actNewRec.ShippingPostalCode);
                                salesOrgHavingActIds.put(actNewRec.Id,actNewRec.cgcloud__Sales_Org__c);                            
                            }else{
                                //Need to check, If someone removes/deletes customer org unit record from account related list, then if next time a user updates account record with same zip code it will not creates new customer org unit record

                            }                        
                        }else if((!(string.isBlank(actNewRec.ShippingPostalCode)) && string.isBlank(oldMap.get(actNewRec.id).ShippingPostalCode)) && !(string.isBlank(actNewRec.cgcloud__Sales_Org__c))){
                            postalCodeHavingActIds.put(actNewRec.Id,actNewRec.ShippingPostalCode);
                            salesOrgHavingActIds.put(actNewRec.Id,actNewRec.cgcloud__Sales_Org__c);    
                        }else if(string.isBlank(actNewRec.ShippingPostalCode) && !(string.isBlank(oldMap.get(actNewRec.id).ShippingPostalCode))){
                            deletedPostalCodeActIds.add(actNewRec.id);
                        }else{                       
    
                        }
                     }else if(allowedRecordTypeIds.contains(actNewRec.RecordTypeId) && !allowedRecordTypeIds.contains(oldMap.get(actNewRec.id).RecordTypeId)){
                        
                        if(!(string.isBlank(actNewRec.ShippingPostalCode)) && !(string.isBlank(actNewRec.cgcloud__Sales_Org__c))){    
                            postalCodeHavingActIds.put(actNewRec.Id,actNewRec.ShippingPostalCode);  
                            salesOrgHavingActIds.put(actNewRec.Id,actNewRec.cgcloud__Sales_Org__c);                     
                        }
                     }else if(!allowedRecordTypeIds.contains(actNewRec.RecordTypeId) && allowedRecordTypeIds.contains(oldMap.get(actNewRec.id).RecordTypeId)){
                        
                        if(!(string.isBlank(oldMap.get(actNewRec.id).ShippingPostalCode))){
                            deletedPostalCodeActIds.add(actNewRec.id);
                        }                     
                     }  
                   
                }
                
                List<cgcloud__Account_Org_Unit__c> delCustomerOrgUnitRecList = new List<cgcloud__Account_Org_Unit__c>();
                for(cgcloud__Account_Org_Unit__c delCustomerOrgUnitRec : [SELECT Id FROM cgcloud__Account_Org_Unit__c WHERE cgcloud__Account__c IN : deletedPostalCodeActIds]){
                    delCustomerOrgUnitRecList.add(delCustomerOrgUnitRec);
                }                 
                
                if(delCustomerOrgUnitRecList.size() > 0){
                    delete delCustomerOrgUnitRecList;
                }                
                for(cgcloud__Org_Unit__c orgUnitRec : [SELECT Id,Zip_Code__c FROM cgcloud__Org_Unit__c WHERE Zip_Code__c IN : postalCodeHavingActIds.values() and cgcloud__Sales_Org__c IN : salesOrgHavingActIds.values()]){
                    actMatchingPostalCodeOrgUnitIds.put(orgUnitRec.Zip_Code__c,orgUnitRec.Id);                 
                }
                
            
                List<cgcloud__Account_Org_Unit__c> customerOrgUnitsList = New List<cgcloud__Account_Org_Unit__c>();
                for(Id key: postalCodeHavingActIds.keySet()){
                    if(actMatchingPostalCodeOrgUnitIds.size()>0 && !actMatchingPostalCodeOrgUnitIds.isEmpty() && actMatchingPostalCodeOrgUnitIds.containsKey(postalCodeHavingActIds.get(key)) && actMatchingPostalCodeOrgUnitIds.get(postalCodeHavingActIds.get(key)) != null){
                        cgcloud__Account_Org_Unit__c customerOrgUnitRec = New cgcloud__Account_Org_Unit__c();
                        customerOrgUnitRec.cgcloud__Account__c = key;
                        customerOrgUnitRec.cgcloud__Org_Unit__c = actMatchingPostalCodeOrgUnitIds.get(postalCodeHavingActIds.get(key));
                        customerOrgUnitRec.cgcloud__Valid_From__c = System.today();
                        customerOrgUnitRec.cgcloud__Valid_Thru__c = Date.newInstance(2099, 12, 31);
                        customerOrgUnitsList.add(customerOrgUnitRec);
                    }                    
                }
                System.debug('After Update, Customer Org Units: ' + customerOrgUnitsList);
                if(customerOrgUnitsList.size() > 0){
                    insert customerOrgUnitsList;
                }
            }
        }     
    }
    public static void handleStoreAssortmentsAssign(Map<Id,Account> newMap,Map<Id,Account> oldMap,System.TriggerOperation triggerEvent){
        //Map<String,Id> actsWithMatchFieldVals = new Map<String,Id>();
        Map<Id,String> actsWithMatchFieldVals = new Map<Id,String>();
        Map<String,Id> actsMatchingAssortmentsInfo = new Map<String,Id>();

        Set<String> actSalesOrgVals = new Set<String>();
        Set<String> actCompliMechVals = new Set<String>();
        Set<String> actShipStateVals = new Set<String>();

        Set<Id> deletedAssortActIds = new Set<Id>();

        switch on triggerEvent {
            when AFTER_INSERT {                   
                for(Account actRec:newMap.values()){  
                    
                    if(!(string.isBlank(actRec.cgcloud__Sales_Org__c)) && !(string.isBlank(actRec.ShippingState)) && !(string.isBlank(actRec.ComplianceMechanism__c))){
                        actSalesOrgVals.add(actRec.cgcloud__Sales_Org__c);
                        actCompliMechVals.add(actRec.ComplianceMechanism__c);
                        actShipStateVals.add(actRec.ShippingState);
                        String accounttFieldVals = actRec.cgcloud__Sales_Org__c+':'+actRec.ComplianceMechanism__c+':'+actRec.ShippingState;
                        actsWithMatchFieldVals.put(actRec.Id,accounttFieldVals);
                    }
                }     
                System.debug('actSalesOrgVals'+actSalesOrgVals);   
                System.debug('actCompliMechVals'+actCompliMechVals);
                System.debug('actShipStateVals'+actShipStateVals); 
                System.debug('actsWithMatchFieldVals'+actsWithMatchFieldVals);                     
                             
                if(actsWithMatchFieldVals.size()>0 && !actsWithMatchFieldVals.isEmpty()){
                    
                    for(Assortment assortmentRec : [SELECT Id,cgcloud__Sales_Org__c,Compliance_Mechanism_for_Auto_assigner__c,Auto_assigner_State_Territory_Name__c FROM Assortment WHERE cgcloud__Sales_Org__c IN :actSalesOrgVals and Compliance_Mechanism_for_Auto_assigner__c IN :actCompliMechVals and Auto_assigner_State_Territory_Name__c IN :actShipStateVals]){             
                        String assortFieldVals = assortmentRec.cgcloud__Sales_Org__c+':'+assortmentRec.Compliance_Mechanism_for_Auto_assigner__c+':'+assortmentRec.Auto_assigner_State_Territory_Name__c;
                        actsMatchingAssortmentsInfo.put(assortFieldVals,assortmentRec.Id);
                    }

                    System.debug('actsMatchingAssortmentsInfo'+actsMatchingAssortmentsInfo);   
                  
                    

                    Map<Id,Id> actsMatchingAssortIds = new Map<Id,Id>();
 
                    for(string actId : actsWithMatchFieldVals.keySet()){
                        if(actsMatchingAssortmentsInfo.size() > 0){
                            if(actsMatchingAssortmentsInfo.containsKey(actsWithMatchFieldVals.get(actId))){
                                actsMatchingAssortIds.put(actId,actsMatchingAssortmentsInfo.get(actsWithMatchFieldVals.get(actId)));
                            }
                        }                        
                    }
                    System.debug('actsMatchingAssortIds'+actsMatchingAssortIds);
                    
                    
                    List<StoreAssortment> storeAssortmentList = New List<StoreAssortment>();
                    if(actsMatchingAssortIds.size() > 0){
                        for(Id actId : actsMatchingAssortIds.keySet()){     
                            if(actsMatchingAssortIds.containsKey(actId)){                     
                                StoreAssortment storeAssortmentRec = New StoreAssortment();
                                storeAssortmentRec.AssortmentId = actsMatchingAssortIds.get(actId);
                                storeAssortmentRec.AccountId = actId;
                                storeAssortmentRec.StartDate = System.today();
                                storeAssortmentList.add(storeAssortmentRec);    
                            }
                        }
                    } 
                    System.debug('storeAssortmentList'+storeAssortmentList);
                    
                    if(storeAssortmentList.size() > 0){ System.debug('storeAssortmentList Inserted');
                        insert storeAssortmentList;
                    }                  
                } 
            }        
            when AFTER_UPDATE { 
                for(Account actNewRec : newMap.values()){  

                 
                    
                    if(!(string.isBlank(actNewRec.cgcloud__Sales_Org__c))  && !(string.isBlank(actNewRec.ShippingState)) && !(string.isBlank(actNewRec.ComplianceMechanism__c))){ 
                        if(actNewRec.cgcloud__Sales_Org__c != oldMap.get(actNewRec.id).cgcloud__Sales_Org__c || actNewRec.ComplianceMechanism__c != oldMap.get(actNewRec.id).ComplianceMechanism__c || actNewRec.ShippingState != oldMap.get(actNewRec.id).ShippingState){ 
                            deletedAssortActIds.add(actNewRec.id);

                            actSalesOrgVals.add(actNewRec.cgcloud__Sales_Org__c);
                            actCompliMechVals.add(actNewRec.ComplianceMechanism__c);
                            actShipStateVals.add(actNewRec.ShippingState);

                            String accounttFieldVals = actNewRec.cgcloud__Sales_Org__c+':'+actNewRec.ComplianceMechanism__c+':'+actNewRec.ShippingState;
                            //actsWithMatchFieldVals.put(accounttFieldVals,actNewRec.Id);
                            actsWithMatchFieldVals.put(actNewRec.Id,accounttFieldVals);
                        }
                    }else{
                        if(!(string.isBlank(oldMap.get(actNewRec.id).cgcloud__Sales_Org__c)) && !(string.isBlank(oldMap.get(actNewRec.id).ShippingState)) && !(string.isBlank(oldMap.get(actNewRec.id).ComplianceMechanism__c))){
                            deletedAssortActIds.add(actNewRec.id);
                        }
                    }
                }
                    
                List<StoreAssortment> delStoreAssortmentRecList = new List<StoreAssortment>();
                for(StoreAssortment delStoreAssortmentRec : [SELECT Id FROM StoreAssortment WHERE AccountId IN : deletedAssortActIds]){
                    delStoreAssortmentRecList.add(delStoreAssortmentRec);
                }                 
                
                if(delStoreAssortmentRecList.size() > 0){
                    delete delStoreAssortmentRecList;
                } 
                
                
                for(Assortment assortmentRec : [SELECT Id,cgcloud__Sales_Org__c,Compliance_Mechanism_for_Auto_assigner__c,Auto_assigner_State_Territory_Name__c FROM Assortment WHERE cgcloud__Sales_Org__c IN :actSalesOrgVals and Compliance_Mechanism_for_Auto_assigner__c IN :actCompliMechVals and Auto_assigner_State_Territory_Name__c IN :actShipStateVals]){             
                    String assortFieldVals = assortmentRec.cgcloud__Sales_Org__c+':'+assortmentRec.Compliance_Mechanism_for_Auto_assigner__c+':'+assortmentRec.Auto_assigner_State_Territory_Name__c;
                    actsMatchingAssortmentsInfo.put(assortFieldVals,assortmentRec.Id);
                }
                

                Map<Id,Id> actsMatchingAssortIds = new Map<Id,Id>();
                for(string actId : actsWithMatchFieldVals.keySet()){
                    if(actsMatchingAssortmentsInfo.size() > 0){
                        if(actsMatchingAssortmentsInfo.containsKey(actsWithMatchFieldVals.get(actId))){
                            actsMatchingAssortIds.put(actId,actsMatchingAssortmentsInfo.get(actsWithMatchFieldVals.get(actId)));
                        }
                    }                        
                }
                
                List<StoreAssortment> storeAssortmentList = New List<StoreAssortment>();
                if(actsMatchingAssortIds.size() > 0){
                    for(Id actId : actsMatchingAssortIds.keySet()){   
                        if(actsMatchingAssortIds.containsKey(actId)){                            
                            StoreAssortment storeAssortmentRec = New StoreAssortment();
                            storeAssortmentRec.AssortmentId = actsMatchingAssortIds.get(actId);
                            storeAssortmentRec.AccountId = actId;
                            storeAssortmentRec.StartDate = System.today();
                            storeAssortmentList.add(storeAssortmentRec);    
                        }
                    }
                } 

                if(storeAssortmentList.size() > 0){
                    insert storeAssortmentList;
                    System.debug('Test storeAssortmentList'+storeAssortmentList);
                }

            }
        }     
    }
 }