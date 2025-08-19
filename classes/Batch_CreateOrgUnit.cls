global class Batch_CreateOrgUnit implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        set<id>allowedRecordTypeIds = new Set<ID>();
        set<string>recordTypesForAutomation = new Set<string>();
        recordTypesForAutomation.add('Independent Retailer');
        recordTypesForAutomation.add('Chain Retail');
        recordTypesForAutomation.add('Regional Chain Retailer');
        
        for(RecordType rcdType :[SELECT ID FROM RECORDTYPE WHERE sObjectType = 'Account' and Name IN :recordTypesForAutomation ])
        {
            allowedRecordTypeIds.add(rcdType.id);
        }
       
       
        String query = 'SELECT Id,Name,ShippingPostalCode,cgcloud__Sales_Org__c,recordTypeID,ShippingCountry FROM Account where isPersonAccount = false and ShippingPostalCode != null and cgcloud__Account_Template__c != null and  cgcloud__Sales_Org__c != null and recordTypeID IN :allowedRecordTypeIds and ShippingCountry = \'US\'';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        Map<Id,String> postalCodeHavingActIds = new Map<Id,String>();
        Map<Id,String> salesOrgHavingActIds = new Map<Id,String>();
        Map<String,Id> actMatchingPostalCodeOrgUnitIds = new Map<String,Id>();
        Map<Id,String> updatedPostalCodeActIds = new Map<Id,String>();
        
        for(Account actRec:scope)
        {
            postalCodeHavingActIds.put(actRec.Id,actRec.ShippingPostalCode);
            salesOrgHavingActIds.put(actRec.Id,actRec.cgcloud__Sales_Org__c);
        }
        if(postalCodeHavingActIds.size()>0 && !postalCodeHavingActIds.isEmpty()){
            for(cgcloud__Org_Unit__c orgUnitRec : [SELECT Id,Zip_Code__c FROM cgcloud__Org_Unit__c WHERE Zip_Code__c IN : postalCodeHavingActIds.values() and cgcloud__Sales_Org__c IN : salesOrgHavingActIds.values()]){
                actMatchingPostalCodeOrgUnitIds.put(orgUnitRec.Zip_Code__c,orgUnitRec.Id);
            }
            List<cgcloud__Account_Org_Unit__c> customerOrgUnitsList = New List<cgcloud__Account_Org_Unit__c>();
            for(Id key: postalCodeHavingActIds.keySet()){
                if(actMatchingPostalCodeOrgUnitIds.size()>0 && !actMatchingPostalCodeOrgUnitIds.isEmpty()){
                    cgcloud__Account_Org_Unit__c customerOrgUnitRec = New cgcloud__Account_Org_Unit__c();
                    customerOrgUnitRec.cgcloud__Account__c = key;
                    customerOrgUnitRec.cgcloud__Org_Unit__c = actMatchingPostalCodeOrgUnitIds.get(postalCodeHavingActIds.get(key));
                    customerOrgUnitRec.cgcloud__Valid_From__c = System.today();
                    customerOrgUnitRec.cgcloud__Valid_Thru__c = Date.newInstance(2099, 12, 31);
                    customerOrgUnitsList.add(customerOrgUnitRec);
                }
            }
            if(!customerOrgUnitsList.IsEmpty()){
                database.insert(customerOrgUnitsList,false);
            }
        }
    }
    global void finish(Database.BatchableContext BC) {

        //This is Standard CG Cloud Batch class added by sudeep, need to cross check later is it required or not 
        //cgcloud.AccountManagerOrgUnitBased accMgrOrgUnit= new cgcloud.AccountManagerOrgUnitBased(); 
        //Id accMgrOrgUnitJobId = Database.executeBatch(accMgrOrgUnit, 100);
    }
}