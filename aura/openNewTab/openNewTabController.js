({
	openTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        var record = component.get("v.newRecordId");
        
        workspaceAPI.openTab({
            recordId: record,         				
            focus: true
        });
      
	}
})