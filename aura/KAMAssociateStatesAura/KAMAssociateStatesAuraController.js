({


    closeMethodInAuraController: function (component, event, helper) {
        // var shouldRender =  component.set("v.inputValue",event.getParam('value'));// Assuming manageAPT is an attribute in the Aura component
        // console.log('Aura Component - shouldRender:', shouldRender);
        const childcompdescription = event.getParam('childcompdescription');
        component.set("v.manageAPT", event.getParam('childcompdescription'));
        // console.log('manageAPT',childcompdescription);
        if(!childcompdescription){
            $A.get("e.force:closeQuickAction").fire();
        }

    },
    refreshMethodInAuraController: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})