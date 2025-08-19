/************************************************************************************/
/* VERSION     AUTHOR                     DATE                                      */ 
/*     1.0     Jyoti Choudhary          12-04-2021                                  */
/* Class Name: AccountCampaignMembershipTriggerHandler                              */
/* Description: SFDC - 0000004405 -Automation for Campaign Membership Address Fields*/
/************************************************************************************/
public class AccountCampaignMembershipTriggerHandler {
    
    //This Method updates ShippingAddress
    public static void UpdateShippingAddress(List<Account_Campaign_Members__c> AccountCampaignMembershipList)
    {
        Set<Id> ACMAccIds = new Set<Id>();
        for (Account_Campaign_Members__c acm : AccountCampaignMembershipList) {
            ACMAccIds.add(acm.Account__c);
        }
        Map<Id,Account> AccShippingAddress = new Map<Id,Account>();
        if(ACMAccIds.size()>0){
            for(Account a : [SELECT Id, Name,ShippingCity,ShippingPostalCode,ShippingState,ShippingStreet FROM Account where Id IN : ACMAccIds]){
                AccShippingAddress.put(a.Id,a);
            }             
        }
        
        List<Account_Campaign_Members__c> ACMUpdateAddressList = new List<Account_Campaign_Members__c>();
        for(Account_Campaign_Members__c ac : AccountCampaignMembershipList){
            if(AccShippingAddress!=null && AccShippingAddress.size()>0){
                for(ID a : AccShippingAddress.keyset()){
                    ac.Shipping_Street__c = AccShippingAddress.get(a).ShippingStreet;
                    ac.Shipping_City__c = AccShippingAddress.get(a).ShippingCity;
                    ac.Shipping_State__c = AccShippingAddress.get(a).ShippingState;
                    ac.Shipping_Zip_Postal_Code__c = AccShippingAddress.get(a).ShippingPostalCode;
                    ACMUpdateAddressList.add(ac);
                }
            }
        }
    }
    //Added by JC for SFDC - 0000005571
    //This Method restrict More than ACM on One Account
    public static void UniqueACMOnAccount(List<Account_Campaign_Members__c> AccountCampaignMembershipList)
    {
        Set<Id> ACMAccountSet = new Set<Id>();
        Set<Id> ACMPromotionSet = new Set<Id>();
        Id ACMAccount;
        Id ACMPromotion;
        
        for(Account_Campaign_Members__c acm : AccountCampaignMembershipList)
        {
            ACMAccount = acm.Account__c;
            ACMPromotion = acm.Promotion__c;
            ACMAccountSet.add(acm.Account__c);
            ACMPromotionSet.add(acm.Promotion__c);
        }
        
        if(ACMAccountSet != null && ACMPromotion != null)
		{
            List<Account_Campaign_Members__c> ACMList = new List<Account_Campaign_Members__c>([Select Id,Account__c,Promotion__c from 
                                                                                               Account_Campaign_Members__c 
                                                                                               where Account__c IN : ACMAccountSet AND Promotion__c IN : ACMPromotionSet]);
            
            Map<String ,Account_Campaign_Members__c> mapUniqueAccountCampaignMembership = new Map<String,Account_Campaign_Members__c>();
            If(ACMList.size()>0)
            {
                For(Account_Campaign_Members__c acm : ACMList)
                {
                    String RelatedAccount = acm.Account__c;
                    String RelatedPromotion = acm.Promotion__c;
                    System.debug(RelatedAccount +' '+ RelatedPromotion);
                    mapUniqueAccountCampaignMembership.put(RelatedAccount + RelatedPromotion ,acm);
                }
            }
            For(Account_Campaign_Members__c acm1 : AccountCampaignMembershipList)
            {
                String Account = acm1.Account__c;
                String Promotion = acm1.Promotion__c;
                if(mapUniqueAccountCampaignMembership.containsKey(Account + Promotion))
                {
                    acm1.addError('An Account Campaign Membership Record is already exist for Selected Campaign and Account');
                }
            }
        }
    }
}