({
	 showToast : function(component, event, helper,message,Type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": Type,
            "message": message
        });
        toastEvent.fire();
    }
})