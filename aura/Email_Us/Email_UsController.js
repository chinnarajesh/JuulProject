({
	doInit : function(cmp, event, helper) {
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
        hitType : 'event',
        eventCategory : 'Button',
        eventAction : 'Email Us',
        eventLabel : 'Email Us',
        eventValue: 200
    });
    analyticsInteraction.fire();
}
})