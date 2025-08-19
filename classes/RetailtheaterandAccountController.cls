public with sharing class RetailtheaterandAccountController {

   public class FlowInput {
        @InvocableVariable
        public String accountdId;
       
        @InvocableVariable
        public String retailtheaterId;
       
        @InvocableVariable
        public String visitId;
    }
    @InvocableMethod(label='Records for Input' description='Updating Account and Retial theater')
    public static void updateRetailtheaterandAccount(List<FlowInput> inputs) {
        FlowInput objInput = inputs.get( 0 );
        System.debug('fieldset++'+objInput.accountdId);
        System.debug('recordId++'+objInput.retailtheaterId);
        system.debug('objectname'+objInput.visitId);
        
         Id updateAccountId = Id.valueOf(objInput.accountdId);
           Visit visitObj = [Select Id,Retail_Theater__c from Visit  Where id =:objInput.visitId];
        List<cgcloud__Visit_Job__c> visitJobList = [select id,name,cgcloud__Job_Definition_Template__c,cgcloud__Job_Definition_Template__r.Mapping_object__c,cgcloud__Job_Definition_Template__r.Mapping_field__c,cgcloud__Display_Value__c from cgcloud__Visit_Job__c where cgcloud__Visit__c =: objInput.visitId ];
        System.debug('visitJobList++'+visitJobList);

        List<Account> accList = new List<Account>();
        List<Retail_Theater__c> rtList = new List<Retail_Theater__c>();


      
        Map<Schema.SobjectField,Object> actTheFieldValMap = new Map<Schema.SobjectField,Object>();
        List<Account> accountList = new List<Account>();

        Map<Schema.SobjectField,Object> rtTheFieldValMap = new Map<Schema.SobjectField,Object>();
        List<Retail_Theater__c> retailList = new List<Retail_Theater__c>();

        for(cgcloud__Visit_Job__c visitJob : visitJobList){ 
            System.debug('Mapping_object__c++'+visitJob.cgcloud__Job_Definition_Template__r.Mapping_object__c);
            
            if(visitJob.cgcloud__Job_Definition_Template__r.Mapping_object__c =='Account'){
             
                
              Schema.SObjectType objectType = Schema.getGlobalDescribe().get(visitJob.cgcloud__Job_Definition_Template__r.Mapping_object__c);
                
              Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
              String fieldDataType =string.valueOf(objectType.getDescribe().fields.getMap().get(visitJob.cgcloud__Job_Definition_Template__r.Mapping_field__c).getDescribe().getType());
              System.debug('fieldDataType++'+fieldDataType);
              Schema.SobjectField theField = fieldMap.get(visitJob.cgcloud__Job_Definition_Template__r.Mapping_field__c);
              System.debug('theField++'+theField);

              String query;
              query = 'SELECT Id FROM '+visitJob.cgcloud__Job_Definition_Template__r.Mapping_object__c+' WHERE Id =  \'' + updateAccountId + '\'';
              accountList = Database.query(query);


           
              
              if(fieldDataType == 'CURRENCY'){
                actTheFieldValMap.put(theField,Decimal.valueOf(visitJob.cgcloud__Display_Value__c));
              }else if(fieldDataType == 'BOOLEAN'){
                if(visitJob.cgcloud__Display_Value__c =='Yes'){
                  actTheFieldValMap.put(theField,true);  
                }
                else{
                  actTheFieldValMap.put(theField,false); 
                }     
               }
               else if(fieldDataType == 'PICKLIST'){
                actTheFieldValMap.put(theField,visitJob.cgcloud__Display_Value__c);
               }
               else if(fieldDataType == 'NUMBER'){
                actTheFieldValMap.put(theField,visitJob.cgcloud__Display_Value__c);
               }
                
            }

            
         
             if(visitJob.cgcloud__Job_Definition_Template__r.Mapping_object__c =='Retail_Theater__c'){
                
              Schema.SObjectType objectType = Schema.getGlobalDescribe().get(visitJob.cgcloud__Job_Definition_Template__r.Mapping_object__c);
                
              Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
                 
                 System.debug('fieldMap++'+fieldMap);
              Schema.SobjectField theField = fieldMap.get(visitJob.cgcloud__Job_Definition_Template__r.Mapping_field__c);
                 String fieldDataType =string.valueOf(objectType.getDescribe().fields.getMap().get(visitJob.cgcloud__Job_Definition_Template__r.Mapping_field__c).getDescribe().getType());
                System.debug('fieldDataType++'+fieldDataType);
                System.debug('theField++'+theField);
              String query;
              query = 'SELECT Id FROM '+visitJob.cgcloud__Job_Definition_Template__r.Mapping_object__c+' WHERE Id =  \'' + visitObj.Retail_Theater__c + '\'';
              retailList = Database.query(query);

            

            if(fieldDataType == 'CURRENCY'){
              rtTheFieldValMap.put(theField,Decimal.valueOf(visitJob.cgcloud__Display_Value__c));
            }
            else if(fieldDataType == 'PICKLIST'){
              rtTheFieldValMap.put(theField,visitJob.cgcloud__Display_Value__c);
            }
            else if(fieldDataType == 'DOUBLE'){
              rtTheFieldValMap.put(theField,Decimal.valueOf(visitJob.cgcloud__Display_Value__c));
            }
            else if(fieldDataType == 'NUMBER'){
              rtTheFieldValMap.put(theField,Decimal.valueOf(visitJob.cgcloud__Display_Value__c));
            }
             else{
              rtTheFieldValMap.put(theField,visitJob.cgcloud__Display_Value__c);
            }
                
                
            }
        }
        

        

      if(accountList.size() > 0){
          for(Account acc : accountList){
            for(Schema.SobjectField actField : actTheFieldValMap.keySet()){
              acc.put(actField,actTheFieldValMap.get(actField));   
            }
            accList.add(acc);
          }
          
      }

    if(retailList.size() > 0){
      for(Retail_Theater__c retail : retailList){
        for(Schema.SobjectField rtField : rtTheFieldValMap.keySet()){
          retail.put(rtField,rtTheFieldValMap.get(rtField));   
        }
        rtList.add(retail);
      }
    }
    system.debug('111-'+ accList);
      system.debug('222-'+ rtList);
        if(accList.size() > 0){
          update accList;
        }
        if(rtList.size() > 0){
          update rtList;
        }

        
    }
}