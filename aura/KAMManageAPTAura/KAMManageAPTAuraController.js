({
    closeMethodInAuraController: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    refreshMethodInAuraController: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})