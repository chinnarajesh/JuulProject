trigger Trigger_SocialPost on SocialPost (before insert, before update, before delete,
                                         after insert, after update, after delete) {
      SocialPostTriggerHelper.newList = Trigger.new;
      SocialPostTriggerHelper.oldList = Trigger.old;
      SocialPostTriggerHelper.newMap = Trigger.newMap;
      SocialPostTriggerHelper.oldMap = Trigger.oldMap;
    

      if( !SocialPostTriggerHelper.runTrigger ) {
          return;
      }

      if( Trigger.isAfter ) {
          if( Trigger.isInsert ) {
              SocialPostTriggerHelper.deleteContacts();
          }
      }
                                        
}