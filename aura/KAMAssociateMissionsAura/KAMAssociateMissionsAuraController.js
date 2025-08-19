({
    doInit: function (component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        //alert('@@Formfactor Value : '+device);
        component.set('v.formFactor',device)
    },
    closeMethodInAuraController: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    refreshMethodInAuraController: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    directToAccountRecord : function(component,event,helper)
    {
        //alert('recordId'+event.getParam('recordId'));
        $A.get("e.force:closeQuickAction").fire();
    }
})