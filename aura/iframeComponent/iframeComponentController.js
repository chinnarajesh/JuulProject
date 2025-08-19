({
	doInit : function(component, event, helper) {
		 var userId = $A.get("$SObjectType.CurrentUser.Id");
		 var tableauUrl=component.get("v.iframeUrl");
         var action = component.get("c.getAccountId");
         action.setParams({"userId":userId});  
         action.setCallback(this, function(response) {
            var state = response.getState();
             console.log("Failed with state: " + state);
            if (state === "SUCCESS") {
               
console.log("accountid: " + response.getReturnValue());
                component.set("v.iframeUrl",tableauUrl+"&Id (Account)="+response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
       

        
	},
   
})