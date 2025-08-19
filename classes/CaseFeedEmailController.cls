/*
*
*	Retrieve OrgWideEmail Address based on profile
*/
public with Sharing class CaseFeedEmailController {
	public String emailAddressList {get;set;}

	public CaseFeedEmailController(ApexPages.StandardController stdCon){
		emailAddressList = '';
		for(OrgWideEmailAddress orgWide : [SELECT ID, Address FROM OrgWideEmailAddress]){
			emailAddressList += (String.isNotBlank(emailAddressList) ? ',':'') + orgWide.Address;
		}
	}
}