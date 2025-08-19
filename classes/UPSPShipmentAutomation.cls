/***************************************************************************************
*
*   @File Name: UPSPShipmentAutomation.cls
*   @File Description: This class expose webservice that can be used into custom button 
*                   of case object. Exposed method will generate shipment label for the case record
*   @author - Mondaycall
*
*****************************************************************************************
* Modification Log
*----------------------------------------------------------------------------------------
* Developer                   Date                   Description
*----------------------------------------------------------------------------------------
* Mondaycall          08/31/15              Initial Creation
*
*
*****************************************************************************************
*
*****************************************************************************************/
global without sharing class UPSPShipmentAutomation {
    ApexPages.StandardController ctrl;
    public UPSPShipmentAutomation(ApexPages.StandardController ctrl){
        this.ctrl = ctrl;
    }
    
    public Pagereference generateShipmentLabel(){
        generateShipmentLabel(ctrl.getId());
        return new ApexPages.StandardController(new Case(Id = ctrl.getId() )).view();
    }
    
    @AuraEnabled
    webservice static boolean generateShipmentLabel(String caseId){
        //Steps:- 
        //Query zkusps__BillingPreference__c
        //Create zkusps__BulkShipment__c - Select z.zkusps__BillingPreference__c From zkusps__BulkShipment__c z
        //Create zkusps__QueuedShipment__c 
        //Create zkusps__QueuedPackage__c
        //Validate zkusps.BulkShipmentInterface.validateBulkShipment(bulkShipment.Id);
        //process zkusps.BulkShipmentInterface.processBulkShipment(bulkShipment.Id);
        Set<String> caseFieldAPINames = new Set<String>{'Id', 'Account.isPersonAccount', 'AccountId','ownerId'};
        String caseQuery = '';
        for(UPSPShipmentAutomationSetting__mdt fieldConfig : [SELECT 
                                                                Mapping_Field_API_Name__c
                                                             FROM UPSPShipmentAutomationSetting__mdt
                                                             WHERE
                                                                Field_Type__c = 'Case Object']){
            caseFieldAPINames.add(fieldConfig.Mapping_Field_API_Name__c);
        }
        
        for(String fieldName : caseFieldAPINames){
            caseQuery += (String.isBlank(caseQuery) ? '' : ',') + fieldName;
        }
        
        Case c ;
        
        for(Case caseObj : (List<Case>)Database.query('SELECT ' + caseQuery + ' FROM Case WHERE Id=:caseId')){
            c = caseObj;
        }
        /*
        Case c = [SELECT 
                        Id, Subject, AccountId
                        , Contact.MailingStreet, Contact.MailingCity, Contact.MailingState, Contact.MailingCountry
                        , Contact.MailingPostalCode, Contact.Name, Contact.Email, Contact.Phone, Account.Name
                        , Contact_Email__c, Contact_Name__c, Ship_To_Line_1__c, Ship_To_Line_2__c, USPS_Country__c
                        , Ship_To_City__c, USPS_Phone__c, Ship_To_State__c, Ship_To_Zip__c
                        , Serial_Number__c, Priority, CaseNumber, Account.isPersonAccount, OwnerId
                 FROM
                    Case
                 WHERE
                    Id =:caseId limit 1];
        */
        
        
        zkusps__ShippingPreference__c  shippingPrefences;
        for(zkusps__ShippingPreference__c  preference : [Select 
                                                    ID, zkusps__preference__c, zkusps__shippingStreet__c,zkusps__companyName__c
                                                         , zkusps__shippingState__c, zkusps__shippingPostalCode__c
                                                        , zkusps__shippingCity__c
                                                        , zkusps__shippingSenderNameDefault__c, zkusps__shippingSenderPhoneDefault__c
                                                        , zkusps__shippingSenderEmailDefault__c
                                                  from 
                                                    zkusps__ShippingPreference__c  where zkusps__companyName__c like 'JUUL%' limit 1]){
            shippingPrefences = preference;
        } 
        
        User caseOwner = null;
        for(User u : [SELECT ID, FirstName, LastName from User where id=:c.ownerID]){
            caseOwner = u;
        }
        if(shippingPrefences != null){
            zkusps__BulkShipment__c bulkShipment = new zkusps__BulkShipment__c(zkusps__BillingPreference__c = shippingPrefences.zkusps__preference__c);
            insert bulkShipment;
            zkusps__QueuedShipment__c queuedShipment = new zkusps__QueuedShipment__c();
            queuedShipment.zkusps__SenderStreet__c = shippingPrefences.zkusps__shippingStreet__c;
            queuedShipment.zkusps__SenderState__c = shippingPrefences.zkusps__shippingState__c;
            queuedShipment.zkusps__SenderPostalCode__c = shippingPrefences.zkusps__shippingPostalCode__c;
            queuedShipment.zkusps__SenderPhone__c = shippingPrefences.zkusps__shippingSenderPhoneDefault__c.replaceAll('[^0-9]+', '');
            queuedShipment.zkusps__SenderName__c = shippingPrefences.zkusps__shippingSenderNameDefault__c;
            queuedShipment.zkusps__SenderEmail__c = shippingPrefences.zkusps__shippingSenderEmailDefault__c;
            queuedShipment.zkusps__SenderCompany__c = shippingPrefences.zkusps__companyName__c;
            queuedShipment.zkusps__SenderCity__c = shippingPrefences.zkusps__shippingCity__c;
            
            if(c.Account.isPersonAccount == false){
                queuedShipment.zkusps__Account__c = c.AccountId;
            }
            
            for(UPSPShipmentAutomationSetting__mdt fieldConfig : [SELECT 
                                                                        Mapping_Field_API_Name__c,Field_Type__c,UPSP_Field_API_Name__c
                                                                    FROM UPSPShipmentAutomationSetting__mdt]){
                if(fieldConfig.Field_Type__c =='Case Object'){
                    queuedShipment.put(fieldConfig.UPSP_Field_API_Name__c, c.get(fieldConfig.Mapping_Field_API_Name__c));
                }else{
                    queuedShipment.put(fieldConfig.UPSP_Field_API_Name__c, fieldConfig.Mapping_Field_API_Name__c);
                }
            }
            queuedShipment.zkusps__BulkShipment__c = bulkShipment.id;
            
            /*
            if(caseOwner != null){
                queuedShipment.zkusps__SenderName__c = caseOwner.FirstName ;
            }
            
            
            
            
            queuedShipment.zkusps__PackagingType__c = 'USPS Flat Rate Envelope';
            queuedShipment.zkusps__LabelImageType__c = 'PDF';
            
            queuedShipment.zkusps__RecipientStreet__c = c.Ship_To_Line_1__c + ' ' 
                                                + (String.isBlank(c.Ship_To_Line_2__c) ? '' : c.Ship_To_Line_2__c) ;
            queuedShipment.zkusps__RecipientState__c = c.Ship_To_State__c;
            queuedShipment.zkusps__RecipientPostalCode__c = c.Ship_To_Zip__c;
            queuedShipment.zkusps__RecipientPhone__c = c.USPS_Phone__c.replaceAll('[^0-9]+', '');
            queuedShipment.zkusps__RecipientName__c = c.Contact_Name__c;
            queuedShipment.zkusps__RecipientCountry__c = c.USPS_Country__c;
            queuedShipment.zkusps__RecipientEmail__c = c.Contact_Email__c;
            IF(c.Account.Name != c.Contact_Name__c){
                queuedShipment.zkusps__RecipientCompany__c = c.Account.Name;
            }
            queuedShipment.zkusps__RecipientCity__c = c.Ship_To_City__c;
            queuedShipment.zkusps__ReturnShipment__c = true;
            queuedShipment.zkusps__ServiceType__c = 'Domestic: Priority';
            queuedShipment.zkusps__YourReference1__c = c.Serial_Number__c;
            queuedShipment.zkusps__YourReference2__c = c.Priority;
            queuedShipment.zkusps__YourReference3__c = c.CaseNumber;
            
            */
            
            for(zkusps__CustomAddressSource__c customAddressSource : [SELECT Id FROM zkusps__CustomAddressSource__c WHERE zkusps__customAddressSourceObject__c ='Case' limit 1]){
                queuedShipment.zkusps__CustomAddressSourceRecordId__c = c.id;
                queuedShipment.zkusps__CustomAddressSource__c = customAddressSource.id;
            }
            /*
            Select zkusps__RecipientStreet__c, z.zkusps__RecipientState__c, z.zkusps__RecipientPostalCode__c, z.zkusps__RecipientPhone__c, z.zkusps__RecipientName__c
                , z.zkusps__RecipientEmail__c, z.zkusps__RecipientCountry__c, z.zkusps__RecipientCompany__c, z.zkusps__RecipientCity__c
                , z.zkusps__PackagingType__c, z.zkusps__LabelImageType__c,
                
            */
            insert queuedShipment;
            
            /*Select z.zkusps__Width__c, z.zkusps__WeightPounds__c, z.zkusps__WeightOunces__c, z., 
            z.zkusps__NonMachinable__c, z.zkusps__Length__c, z.zkusps__Height__c, z.zkusps__DeclaredValue__c, z.Name From zkusps__QueuedPackage__c z*/
            zkusps__QueuedPackage__c queuedPkg = new zkusps__QueuedPackage__c();
            queuedPkg.zkusps__QueuedShipment__c = queuedShipment.id;
            queuedPkg.zkusps__WeightPounds__c = 2;
            queuedPkg.zkusps__WeightOunces__c = 0;
            queuedPkg.Case__c = caseId;
            
            insert queuedPkg;
            zkusps.BulkShipmentInterface.processBulkShipment(bulkShipment.Id);
        }
        return true;
    }
}