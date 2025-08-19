global  class AccountHierarchyStateBatchClass implements Database.Batchable<sObject>, Database.Stateful {
                                              
    public Id accId;
    public id aptId;
    public Integer allActsCnt = 0;
    public Integer maxDeepLevel = 1;

    
    Map<String, List<Id>> actGrpByState;
    Map<String, Integer> actGrpCntByState;

    Map<Integer, Integer> fff;
    public Integer ddd = 1;
    public List<string> errorMessege;

    public AccountHierarchyStateBatchClass(id parentAccId ,Id ActionPlanTemplateId){
     accId=parentAccId;
     aptId=ActionPlanTemplateId;

        actGrpByState = new Map<String, List<Id>>();
        actGrpCntByState = new Map<String, Integer>();
    }
    Public Database.Querylocator start (Database.BatchableContext BC) {
         
     String query = 'SELECT ID,ShippingState, Name, ParentID,Type  FROM Account WHERE ParentID =:accId';

     return Database.getQueryLocator(query);
    }


    global void execute (Database.BatchableContext BC,List<Account> ChildAccounts) {

        
        
        Set <ID> queryIDs = new Set <ID>();   

        fff = new Map<Integer, Integer>();

        fff.put(ddd, ChildAccounts.size());

        ddd = ddd+1;
       
        //temporary
        // Set<ID> AccountIdSet = new Set<ID>();  
        // for(Account acc : accIDList){
        //     AccountIdSet.add(acc.id);
        // }
        // List <Account> accChildList = [SELECT ID,ShippingState, Name, ParentID ,(SELECT ID,ShippingState From ChildAccounts) FROM Account WHERE ID IN :AccountIdSet]; 

        if (ChildAccounts.size() > 0) {

                for (Integer i = 0; i < ChildAccounts.size(); i++) {
                    if(actGrpCntByState.containsKey(ChildAccounts[i].ShippingState)){
                        List<Id> actIdsExist = actGrpByState.get(ChildAccounts[i].ShippingState);

                        if(ChildAccounts[i].Type != 'HQ'){
                            actIdsExist.add(ChildAccounts[i].id);
                            actGrpByState.put(ChildAccounts[i].ShippingState,actIdsExist);
                            actGrpCntByState.put(ChildAccounts[i].ShippingState,actIdsExist.size());
                        }
                        
                    }else{
                        List<Id> actIdsNew = new List<Id>();
                        if(ChildAccounts[i].Type != 'HQ'){
                            actIdsNew.add(ChildAccounts[i].id);
                            actGrpByState.put(ChildAccounts[i].ShippingState,actIdsNew);
                            actGrpCntByState.put(ChildAccounts[i].ShippingState,actIdsNew.size());
                        }
                    }
                    queryIDs.add(ChildAccounts[i].id);
                }
    
                System.debug('1 level Deep Ids-'+queryIDs);
                System.debug('1 level Deep Ids count-'+queryIDs.size());
    
                allActsCnt = allActsCnt + queryIDs.size();
    
    
                
                while (queryIDs.size() > 0) {
      
                    List <Account> childAccount = [SELECT ID,ShippingState, Name, ParentID ,(SELECT ID,ShippingState,Type From ChildAccounts) FROM Account WHERE ID IN :queryIDs];        
                    queryIDs.clear();
                    if(maxDeepLevel < 7){
                        System.debug('maxDeepLevel '+maxDeepLevel);
                        //System.debug('childAccount'+childAccount);
                        for (Account oneAcc: childAccount) {
                            //System.debug('oneAcc cnt'+oneAcc.ChildAccounts.size());
                            if (oneAcc.ChildAccounts.size() > 0) {
                                
                                //childMap.put(oneAcc.id, oneAcc.ChildAccounts);
                                
                                for (Integer i = 0; i < oneAcc.ChildAccounts.size(); i++) {
 
                                    if(actGrpCntByState.containsKey(oneAcc.ChildAccounts[i].ShippingState)){
                                        List<Id> actIds222 = actGrpByState.get(oneAcc.ChildAccounts[i].ShippingState);
                                        if(oneAcc.ChildAccounts[i].Type != 'HQ'){
                                            actIds222.add(oneAcc.ChildAccounts[i].id);
                                            actGrpByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds222);
                                            actGrpCntByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds222.size());
                                        }
                                    }else{
                                        List<Id> actIds111 = new List<Id>();
                                        if(oneAcc.ChildAccounts[i].Type != 'HQ'){
                                            actIds111.add(oneAcc.ChildAccounts[i].id);
                                            actGrpByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds111);
                                            actGrpCntByState.put(oneAcc.ChildAccounts[i].ShippingState,actIds111.size());
                                        }
                                    }
    
                                    queryIDs.add(oneAcc.ChildAccounts[i].id);

                                }  
                            }    
                        }   
                        maxDeepLevel = maxDeepLevel+1; 
                        if(queryIDs.size() > 0){
                            System.debug(maxDeepLevel+' level Deep Ids-'+queryIDs);
                            System.debug(maxDeepLevel+' level Deep Ids count-'+queryIDs.size());
                            allActsCnt = allActsCnt + queryIDs.size();
    
                        }
                        
                        
                    }    
                }
            }
            //System.debug('State Wise Grouped Accounts-'+actGrpByState);
            System.debug('State Wise Grouped Account Counts-'+actGrpCntByState);
            System.debug('All Child Accounts Count-'+allActsCnt);
        

    }

    global void finish(Database.BatchableContext BC){

        for(ActionPlanTemplate__c apt : [select id,name,Associate_States_Group__c from ActionPlanTemplate__c where id =: aptId]){
            apt.Associate_States_Group__c=JSON.serializePretty(actGrpCntByState);
            update apt;
        }
        Batch_Data__e event = new Batch_Data__e(
            Message__c='Participating states are ready to use'
        );
        EventBus.publish(event);
        System.debug('test method');
        //System.debug('State Wise Grouped Accounts-'+actGrpByState);
        System.debug('State Wise Grouped Account Counts-'+actGrpCntByState);
        System.debug('All Child Accounts Count-'+allActsCnt);

        System.debug('fff-'+fff);
        System.debug('json format '+JSON.serializePretty(actGrpCntByState));

        String userId = UserInfo.getUserId();
        user us =[select id,Email from user where id =: userId];
        errorMessege = new List<String>();

        // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // String email=us.Email;
        // mail.setToAddresses(new String[] {email});
        // mail.setReplyTo(us.Email);
        // mail.setSenderDisplayName('Salesforce Batch');
        // mail.setSubject('Associate Participating States batch is completed');
        // mail.setPlainTextBody(String.join(errorMessege, '\n'));
        
        // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }

}