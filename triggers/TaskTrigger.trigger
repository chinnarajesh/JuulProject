trigger TaskTrigger on Task (after insert,after update) {
 Trigger_Controller__c TaskTriggerControl = Trigger_Controller__c.getInstance('TaskTrigger');
    if(TaskTriggerControl != null && TaskTriggerControl.Enabled__c ){
        if(Trigger.isAfter && Trigger.isInsert){
            TaskTriggerHandler.process(Trigger.New);
        }
        
        if(Trigger.isInsert || Trigger.isUpdate){
             ActivityHandler.run(trigger.newMap,trigger.oldMap);
        }
         if(Trigger.isAfter && Trigger.isUpdate){
            TaskTriggerHandler.updateAccNotesWithTaskComments(Trigger.New, Trigger.oldMap);
        }
    }
}