({
    init: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        var propertyValue = myPageRef.state.c__propertyValue;
        var missionId = myPageRef.state.c__recordId;
        var accountId = myPageRef.state.c__accountId;
        //alert('missionId-->'+missionId+'accountId-->'+accountId);
        cmp.set("v.propertyValue", propertyValue);
        cmp.set("v.recordId", missionId);
        cmp.set("v.accountId", accountId);
        cmp.set("v.doReload",true);

    },
    closeMethodInAuraController: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    refreshMethodInAuraController: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
    
})