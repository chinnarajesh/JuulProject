@isTest(SEEALLDATA = false)   
public class XDSRTriggerTest {
public static testMethod void insertXDSRs_Test(){
        Trigger_Controller__c triggerController = new Trigger_Controller__c(Name='XDSRTrigger',Enabled__c=true);
            insert(triggerController);
      List<CS_Country_Config__mdt> listCSCountry = [SELECT  Label,DeveloperName,XDSR_Assignment_Queue_Name__c,Market__c, Language__c FROM CS_Country_Config__mdt];
      List<XDSR__c> listXDSRToInsert = new List<XDSR__c>();
        
      for(Integer i=0; i<10;i++){
        XDSR__c xdsrRec = new XDSR__c();
        xdsrRec.External_Id__c = '563466Test737474yy'+i;
        if(i==0){
            xdsrRec.Language_Preference__c = 'English';
            xdsrRec.Market__c = 'United States';
        }
        if(i==1){
           xdsrRec.Language_Preference__c = 'English';
            xdsrRec.Market__c = 'United Kingdom'; 
        } 
        if(i==2){
           xdsrRec.Language_Preference__c = 'German';
            xdsrRec.Market__c = 'Canada'; 
        }else{
            xdsrRec.Language_Preference__c = 'Englsh';
            xdsrRec.Market__c = 'Canada'; 
        }
        listXDSRToInsert.add(xdsrRec);
    }
    insert listXDSRToInsert;
    }
}