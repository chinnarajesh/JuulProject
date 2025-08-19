({
    
    createCaseHelper : function(component,event, helper) {
        var CaseValues = component.get("v.CaseValues");
        var action = component.get("c.createCaseForDataAccess");
        action.setParams({
            caseParam : CaseValues,
            caseType : 'Data Access'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.NewCase", response.getReturnValue());
                component.set("v.showSpinner", false);
                var appEvent = $A.get("e.c:showNewCaseEvent");
                appEvent.setParams({
                    "NewCase" : component.get("v.NewCase")
                });
                appEvent.fire(); 
            } else{
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
    },
    
    verifyCheckboxes : function(component, event, helper){
        var CaseValues = component.get("v.CaseValues");
        var count = 0;
        if(CaseValues.Collection_Practices__c)count=1;
        if(CaseValues.Sharing_Practices__c)count= count+1;
        if(CaseValues.Specific_Information_Collected__c)count = count+1;
        if(count > 1){
            this.showToast(component, event, helper,
                           'Can only submit a single data access request at a time, please submit a separate request','Error!'); 
            return false;
        }
        else if(count == 0){
            this.showToast(component, event, helper,
                           'A selection is required, please select the type of data access request by checking a box','Error!');
            return false;
        }
            else if(count == 1){
                return true;
            }
                else{
                    return false;
                }  
    }
})