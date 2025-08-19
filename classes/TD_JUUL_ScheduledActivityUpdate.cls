/** 
* File Name: TD_JUUL_ScheduledActivityUpdate.cls
* Description: Scheduled Apex Job that updates Talkdesk activities with Contact and Account based on the Contact's phone number.
* Copyright : Talkdesk, Inc. Copyright (c) 2017
* Author : Phillip Zeelig
* Date: 10182017
**/ 

global class TD_JUUL_ScheduledActivityUpdate implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {

 //Build list of activities that are missing contacts or accounts.
    Map <string,string> actMap = new Map <string,string>();
    List<talkdesk__Talkdesk_Activity__c> activityListUpdate = new List<talkdesk__Talkdesk_Activity__c>();
    
    for(Contact contact: [SELECT id, Phone, HomePhone, OtherPhone, MobilePhone FROM Contact]){
        if (contact.Phone!=NULL){
            actMap.put(contact.phone.replaceAll('\\D+','').right(10),contact.id);  
        }
        if (contact.HomePhone!=NULL){
            actMap.put(contact.HomePhone.replaceAll('\\D+','').right(10),contact.id);  
        }
        if (contact.OtherPhone!=NULL){
            actMap.put(contact.OtherPhone.replaceAll('\\D+','').right(10),contact.id);  
        }
        if (contact.MobilePhone!=NULL){
            actMap.put(contact.MobilePhone.replaceAll('\\D+','').right(10),contact.id);  
        }
    }
    
    if(actMap.size()>0){
        
      List<talkdesk__Talkdesk_Activity__c> activityListNoCon = [Select id, talkdesk__Contact_Phone__c, talkdesk__Contact__c from talkdesk__Talkdesk_Activity__c where talkdesk__Contact__c = NULL];
    
      for(talkdesk__Talkdesk_Activity__c activityNoCon: activityListNoCon){
        String phone = activityNoCon.talkdesk__Contact_Phone__c.replaceAll('\\D+','').right(10);
        if(phone != NUll)
        {
            activityNoCon.talkdesk__Contact__c = actMap.get(Phone);
            activityListUpdate.add(activityNoCon);
        }
      } 
      update(activityListUpdate);
      activityListUpdate.clear();
    }
    for(talkdesk__Talkdesk_Activity__c activityNoAct: [Select id, talkdesk__Contact_Phone__c, talkdesk__Contact__c,talkdesk__Contact__r.account.id, talkdesk__account__c from talkdesk__Talkdesk_Activity__c where talkdesk__Contact__c != NULL AND talkdesk__Account__c = NULL ])
    {
        if(activityNoAct.talkdesk__Contact__r.account.id != NUll){
            activityNoAct.talkdesk__account__c = activityNoAct.talkdesk__Contact__r.account.id;
            activityListUpdate.add(activityNoAct);
        }
    }    
    update(activityListUpdate);
 }
}