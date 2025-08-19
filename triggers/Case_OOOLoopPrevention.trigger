trigger Case_OOOLoopPrevention on Case (before insert) {
	// If Case is created by Email channel then skip auto-response rules
    Set<String>  autoEmailKeywords = EmailLoopProtectionKeywordSetting__c.getAll().keyset();
    
    for(Case c : Trigger.New){
        //If submission Channel is Email - support@pax.com
        if(c.origin == 'support@pax.com' || c.SuppliedEmail != null){
            //Case is created by Email - Check for the auto-response email
            for(String keyword : autoEmailKeywords){
                if( c.Subject != null &&  c.subject.contains(keyword)){
                    //Add [Email Loop Protection] into subject to skip auto-response rules
                    c.subject = c.subject + ' [Email Loop Protection]';
                    c.subject.addError('This is duplicate case, created by auto-reply'); 
               }

            }
            

        }

    }
    
}