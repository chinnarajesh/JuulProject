({
    doInit: function(component, event, helper) {

        var action = component.get("c.generateShipmentLabel");
        action.setParams({
            'caseId' : component.get('v.recordId')
        })
        action.setCallback(this, function(data) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Shipment has been queued for the label.",
                "type": "success"
            });
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);

    }
})