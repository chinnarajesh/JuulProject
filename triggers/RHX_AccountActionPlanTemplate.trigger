trigger RHX_AccountActionPlanTemplate on AccountActionPlanTemplate__c
    (after delete, after insert, after undelete, after update, before delete) {
        
  	 Type rollClass = System.Type.forName('rh2', 'ParentUtil');
	 if(rollClass != null) {
		rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
		if (trigger.isAfter) {
			pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'AccountActionPlanTemplate__c'}, null);
    	}
    }

        if (trigger.isBefore) {
            if (trigger.isDelete) {
            	 AccountActionPlanTemplateTriggerHelper.handleBeforeDelete(Trigger.oldMap); 
        	}
        }      
        
        
}