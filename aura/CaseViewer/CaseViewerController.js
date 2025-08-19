({
    doInit : function(component, event, helper) {
        component.set('v.caseviewers', {});
        helper.sync(component, helper);
        /*
        var timer = window.setInterval(function(){
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(r){
                console.log(r.recordId, component.get("v.recordId"));
                if(r.recordId == component.get("v.recordId")){
                    console.log(r.recordId, '<<<<')
                    helper.sync(component, helper);
                }
            })
        },3 * 60 * 1000);
         component.set('v.timer', timer); 
        */
         
    },
    handleDestroy : function (component, event, helper) {
        helper.handleInactive(component,helper);
        
    }
})