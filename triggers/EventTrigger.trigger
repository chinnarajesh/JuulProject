trigger EventTrigger on Event (after update,after insert) {
    ActivityHandler.run(trigger.newMap,trigger.oldMap);
}