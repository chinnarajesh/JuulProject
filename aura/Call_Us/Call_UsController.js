({
	doInit : function(cmp, event, helper) {
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
        hitType : 'event',
        eventCategory : 'Button',
        eventAction : 'Call Us',
        eventLabel : 'Call Us',
        eventValue: 200
    });
    analyticsInteraction.fire();
}
})