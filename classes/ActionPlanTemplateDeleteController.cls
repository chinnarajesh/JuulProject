public class ActionPlanTemplateDeleteController {
  @AuraEnabled
    public static string DeleteactionPlanTemplateRecord(Id ActionPlanTemplateId ,Boolean aptDelete){

       List<ActionPlanTemplate__c> APT = new List<ActionPlanTemplate__c>([SELECT Id, Status__c from ActionPlanTemplate__c where Id =:ActionPlanTemplateId ]);
     string returnResponse ;
       if(APT[0].Status__c =='Planning' && aptDelete ==false){
         returnResponse ='success';
       }
        if(APT[0].Status__c !='Planning' && aptDelete ==false){
          returnResponse='error';
       }
       if((APT[0].Status__c =='Planning' || APT[0].Status__c=='None' || APT[0].Status__c=='') && aptDelete ==true){
         delete APT;
         returnResponse ='success';
       }
        return returnResponse;

    }
}