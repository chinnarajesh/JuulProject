({
	doInit : function(cmp, event, helper) {
    var analyticsInteraction = $A.get("e.forceCommunity:analyticsInteraction");
    analyticsInteraction.setParams({
        hitType : 'event',
        eventCategory : 'Button',
        eventAction : 'Chat Us',
        eventLabel : 'Chat Us',
        eventValue: 200
    });
    analyticsInteraction.fire();
}
})