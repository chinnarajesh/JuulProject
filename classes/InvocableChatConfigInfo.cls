/*******************************************************************************************
 * @Name         InvocableChatConfigInfo
 * @Author       Rayan Rao <rayan.rao@juul.com>
 * @Date         02/12/2020
 * @Group        Customer Service
 * @Description  This service returns case number based on case ID
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Rayan         03/04/2020         Initial Creation
*******************************************************************************************/
global without sharing class InvocableChatConfigInfo {
    
    global class Requests {
        @InvocableVariable(label='Market' description='Market' required=true)
        public String varMarket;
        
        @InvocableVariable(label='Language' description='Language' required=true)
        public String varLanguage;
           
        @InvocableVariable(label='Type' description='Type' required=true)
        public String varType;
        
    }
    
     global class Results {
        @InvocableVariable(label='Org ID' description='Org ID' required=true)
        public String varOrgID;
         
        @InvocableVariable(label='Button ID' description='Button ID' required=true)
        public String varButtonID;
        
        @InvocableVariable(label='Deployment ID' description='Deployment ID' required=true)
        public String varDeploymentID;
         
    }

        
    @InvocableMethod
    global static List <Results> execute ( List<Requests> requestList) {
        
		List<CS_Chat_Button_Configurations__mdt> listChatConfigDetails;
        String varMarket = requestList[0].varMarket;
        String varLanguage = requestList[0].varLanguage;
        String varType = requestList[0].varType;
        String varOrgID = '';
        String varButtonID = '';
        String varDeploymentID = '';
        
        System.debug('The Market is: ' + varMarket + 'The Language is: ' + varLanguage + 'The Type is: ' + varType);
        
        if ( varType == 'I have an app issue.' ){
            listChatConfigDetails = [SELECT Org_ID__c, Button_ID__c, Deployment_ID__c FROM CS_Chat_Button_Configurations__mdt
                                          						WHERE Market__c = :varMarket
                                         						and Language__c = :varLanguage 
                                         						and Type__c = 'App' ];
        }
        else{
			listChatConfigDetails = [SELECT Org_ID__c, Button_ID__c, Deployment_ID__c   FROM CS_Chat_Button_Configurations__mdt
                                          						WHERE Market__c = :varMarket
                                         						and Language__c = :varLanguage 
                                         						and Type__c = 'None' ];	
        }
        
        // Assign ButtonID, DeploymentID, OrgID
        if (!listChatConfigDetails.isEmpty()){
               varOrgID =  listChatConfigDetails[0].Org_ID__c;
        	   varButtonID = listChatConfigDetails[0].Button_ID__c;
        	   varDeploymentID = listChatConfigDetails[0].Deployment_ID__c;
        }
      
        //Create a Results object to hold the return values
        Results response = new Results();

        //Add the return value to the Results object
        response.varDeploymentID = varDeploymentID;
        response.varButtonID = varButtonID;
        response.varOrgID = varOrgID;

        //Wrap the Results object in a List container
        List<Results> responseWrapper = new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
    }
    
    
}