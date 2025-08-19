public class CommercialActivityProductPricings {

     public class FlowInput {
        @InvocableVariable
        public String capId;
    }
    @InvocableMethod(label='Records for Input' description='creating pricing records')
    public static void creatingCommercialActivityProductPricings(List<FlowInput> inputs) {
       FlowInput objInput = inputs.get( 0 );
       System.debug('capId'+objInput.capId);
        
        Pricing_State__mdt stateList =[select id,State__c,State_ISO2__c from Pricing_State__mdt LIMIT 1];
        List<string> priceStateList = stateList.State__c.split(',');
        List<string> stateIso2List = stateList.State_ISO2__c.split(',');
        Map<string,string> stateMap = new Map<string,string>();
        
        Integer count =0;
       for(string st : priceStateList){
          stateMap.put(st,stateIso2List[count]);
          count++;
        }
        List<Commercial_Activity_Product_Pricing__c> cappList = new List<Commercial_Activity_Product_Pricing__c>();
        
        for(string stateName : priceStateList){
            Commercial_Activity_Product_Pricing__c capp = new Commercial_Activity_Product_Pricing__c(
                Commercial_Activity_Product__c=objInput.capId,
                State__c=stateName,
                State_ISO2__c=stateMap.get(stateName)
            );
            cappList.add(capp);
        }
        if(cappList.size()>0){
            insert cappList;
        }
        System.debug('cappList '+cappList.size());
    }
}