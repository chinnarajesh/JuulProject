@isTest
public class InvocableCustomerSupportCommunitiesTest {

    static testMethod void createCase(){
        Case c = new Case();
        insert c;
        
        String recordId = String.valueOf(c.Id);
        InvocableCustomerSupportCommunities.Requests inputVariable = new InvocableCustomerSupportCommunities.Requests();
        inputVariable.inputCaseID = recordId;
        InvocableCustomerSupportCommunities.execute(new List<InvocableCustomerSupportCommunities.Requests>{inputVariable});
          
    }

}