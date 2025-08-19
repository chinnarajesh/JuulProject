/*************************************************************************************************
Trigger Name        : AccountCampaignMembershipTrigger
Version             : 1.0
Date Created        : 15-04-2021
Function            : Trigger to update Address
Author              : Gerry
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* Jyoti Choudhary       15-04-2021              Trigger to update Address
**************************************************************************************************/
trigger AccountCampaignMembershipTrigger on Account_Campaign_Members__c (before insert) {
	if (Trigger.IsBefore) {   
        if (Trigger.isInsert) {
            AccountCampaignMembershipTriggerHandler.UpdateShippingAddress(Trigger.New);
            AccountCampaignMembershipTriggerHandler.UniqueACMOnAccount(Trigger.New);//Added by JC for SFDC - 0000005571

        }
    }
}