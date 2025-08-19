({
    init: function(cmp, evt, helper) {
        //Created by Subodh 
        var myPageRef = cmp.get("v.pageReference");
        var propertyValue = myPageRef.state.c__propertyValue;
        var AccAuraID = myPageRef.state.c__recordId;
        cmp.set("v.propertyValue", propertyValue);
        cmp.set("v.recordId", AccAuraID);
        cmp.set("v.accountId", AccAuraID);
        cmp.set("v.doReload",true);
//$A.get('e.force:refreshView').fire();

    },
    closeMethodInAuraController: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    refreshMethodInAuraController: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }})