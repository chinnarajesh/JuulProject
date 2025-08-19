public class ActivityHandler {
    private static final SObjectType LEADSOBJECTTYPE = Lead.sobjectType;
    private static final SObjectType TASKSOBJECTTYPE = Task.sobjectType;
    private static final SObjectType EVENTSOBJECTTYPE = Event.sobjectType;
    private static final SObjectType CASEOBJECTTYPE = Case.sobjectType;
    
    public static void run(Map<Id,SObject> newMap, Map<Id,SObject> oldMap){
        SObjectType stype = newMap.getSObjectType();
        List<Id> accIds = new List<Id>();
        List<Id> leadIds = new List<Id>();
        List<Id> caseIds = new List<Id>();
        for(SObject sobj : newMap.values()){
            if(stype == TASKSOBJECTTYPE){
                filter((Task)sobj,Trigger.isInsert ? NULL : (Task)oldMap.get(sobj.Id),accIds,leadIds,caseIds);
            }
            else if(stype == EVENTSOBJECTTYPE){
                filter((Event)sobj,Trigger.isInsert ? NULL : (Event)oldMap.get(sobj.Id),accIds,leadIds,caseIds);
            }
        }
        List<SObject> sobjects = new List<SObject>();
        if(!accIds.isEmpty()){
            sobjects.addAll(query(stype,accIds));
        }
        
        if(!leadIds.isEmpty()){
            sobjects.addAll(query(stype,leadIds));
        }
        
        if(!caseIds.isEmpty()){
            sobjects.addAll(query(stype,caseIds));
        }
        
        for(SObject sobj : sobjects){
            if(sobj.getSObjects(stype+'s')!=NULL){
                sobj.put(stype+'_Count__c',sobj.getSObjects(stype+'s').size());
            }else{
                sobj.put(stype+'_Count__c',0);   
            }    
        }
        
        if(!sobjects.isEmpty()){
            update sobjects;
        }
    }
    
    private static void filter(Task t, Task ot, List<Id> accIds, List<Id> leadIds, List<Id> caseIds){
        if((t.IsClosed && Trigger.isInsert) || (Trigger.isUpdate && ot.IsClosed != t.isClosed)){
            if( t.WhoId != NULL && t.WhoId.getSObjectType() == LEADSOBJECTTYPE){
                leadIds.add(t.WhoId);
            }
            else if( t.WhatId != NULL && t.WhatId.getSObjectType() == CASEOBJECTTYPE){
                caseIds.add(t.WhatId);
            } 
            else if(t.AccountId != NULL){
                accIds.add(t.AccountId);
            } 
        }
    }
    
    private static void filter(Event t, Event ot, List<Id> accIds, List<Id> leadIds, List<Id> caseIds){
        if( t.WhoId != NULL && t.WhoId.getSObjectType() == LEADSOBJECTTYPE){
            leadIds.add(t.WhoId);
        }
        else if( t.WhatId != NULL && t.WhatId.getSObjectType() == CASEOBJECTTYPE){
            caseIds.add(t.WhatId);
        } 
        else if(t.AccountId != NULL){
            accIds.add(t.AccountId);
        } 
    }
    
    private static List<SObject> query(SObjectType triggerStype,List<Id> Ids){
        SObjectType objType = Ids[0].getSObjectType();
        String qry = 'SELECT Id,(SELECT Id FROM '+(triggerStype == Event.sObjectType ? ' Events' : ' Tasks WHERE isClosed = true')+' ) FROM '+objType+' WHERE Id IN:Ids'
            +(objType == Lead.sObjectType ? ' AND isConverted= false' : '');
        return Database.query(qry);   
    }
}