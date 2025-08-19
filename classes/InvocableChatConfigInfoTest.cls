@isTest
public class InvocableChatConfigInfoTest {
    
    static testMethod void createCase(){

  		String market = 'Ireland';
        String language = 'English';
        String type = 'I have a product issue.';
        
        InvocableChatConfigInfo.Requests inputVariable = new InvocableChatConfigInfo.Requests();
        
        inputVariable.varMarket = market;
        inputVariable.varLanguage = language;
        
        // Execute when type is NOT App Issue
        inputVariable.varType = type;
        InvocableChatConfigInfo.execute(new List<InvocableChatConfigInfo.Requests>{inputVariable});
        
        //Execute when type IS App Issue
         type = 'I have an app issue.';
         InvocableChatConfigInfo.execute(new List<InvocableChatConfigInfo.Requests>{inputVariable});

          
    }
}