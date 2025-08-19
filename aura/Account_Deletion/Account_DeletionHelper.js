({
    createCaseHelper : function(component,event, helper) {
        var CaseValues = component.get("v.CaseValues");
        var action = component.get("c.createCaseForDataAccess");
        action.setParams({
            caseParam : CaseValues,
            caseType : 'Account Deletion'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner",false);
                component.set("v.NewCase",response.getReturnValue());
                var appEvent = $A.get("e.c:showNewCaseEvent");
                appEvent.setParams({
                    "NewCase" : response.getReturnValue()
                });
                appEvent.fire();   
            } 
            else{
                this.showToast(component, event, helper,'Cannot Create Case Due to Technical Issue','Error!');
                component.set("v.showSpinner",false); 
            }
        });
        $A.enqueueAction(action);
    },
    
    showToast : function(component, event, helper,message,Type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": Type,
            "message": message
        });
        toastEvent.fire();
    }
})