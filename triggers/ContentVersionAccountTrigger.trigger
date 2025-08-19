/*****************************************************************************************
*
*   @File name: Content Version Account Trigger
*   @File Description: Trigger to validate only one active Plan on Page file in an account.
*   @author - Sanjeev Krishnan
*
*****************************************************************************************
* Modification Log
*----------------------------------------------------------------------------------------
* Developer                   Date                   Description
*----------------------------------------------------------------------------------------
* Sanjeev Krishnan           01/06/19                 created
*
*
*****************************************************************************************/ 
trigger ContentVersionAccountTrigger on ContentVersion (after update,before update) {  
        
       
    if(trigger.isBefore && trigger.isUpdate){ 
           ContentVersionAccountTriggerHandler handler = new  ContentVersionAccountTriggerHandler();
  
        handler.updateContent(Trigger.new);  

    }  
   
}