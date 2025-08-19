public class RPT_ComplaintInfo_Controller 
{

@AuraEnabled
public Case CaseObj {get;set;}
    
@AuraEnabled
public Account Acct {get;set;}
    
@AuraEnabled    
public LiveChatTranscript  LiveChat{get; set;}
    
@AuraEnabled    
public List<EmailMessage> EmailMsg {get; set;}
    
@AuraEnabled    
public List<AccountHistory> accHist {get;set;}
    
Public datetime NOW;
Id case_id;
    
public RPT_ComplaintInfo_Controller (ApexPages.StandardController stdController)
   {
      case_id = System.currentPageReference().getParameters().get('id');
      NOW  = system.now(); 
      EmailMsg = new List<EmailMessage>();
       try{
           CaseObj = [ SELECT Id, ParentId, Action__c,  JUULpod_pack_code1__c, JUULpod_pack_code2__c, Flavor_Feedback__c, JUUL_flavor_1__c, JUUL_flavor_2__c, Owner.Name, JUUL_type_1__c, Leak_Type_2__c, CaseNumber,Last_Agent_Owner__c,Description,Last_Case_Comment__c, Origin,CreatedDate,Topic__c,Issue__c,Reason__c,Other__c,Status,Resolution__c,Zendesk__Resolution_Time__c,Agent_Replied__c,RMA_Notes__c,RMA_Status__c,RMA_Received__c,JUULpods_Coupon_Code__c, AccountID, Account_Email_to_Deactivate__c FROM Case WHERE Id =:case_id];
           } catch(Exception ex){
               CaseObj = null;
           }
       
      try{
           Acct = [SELECT Id, Name, OwnerId, Description_Shortener__c, PersonEmail from account WHERE Id =:CaseObj.AccountId];
           } catch(Exception ex){
               Acct = null;
           }
       
      try{   
          EmailMsg = [SELECT Id, ParentID, CreatedById, LastModifiedById, TextBody, HtmlBody, Subject, FromName, FromAddress, ToAddress, Status, MessageDate FROM EmailMessage WHERE ParentId =:case_id order by MessageDate asc];
           } catch(Exception ex){
               EmailMsg = null;
           } 
       
       try{
           LiveChat = [ SELECT Id, OwnerId, Name, Created_Date_Time__c,  LiveChatVisitorId, Body, CaseId, RequestTime, StartTime, EndTime, EndedBy, Status__c, First_Agent_Response__c FROM LiveChatTranscript WHERE CaseId =:case_id];
           } catch(Exception ex){
               LiveChat = null;
           } 

   }
    
}