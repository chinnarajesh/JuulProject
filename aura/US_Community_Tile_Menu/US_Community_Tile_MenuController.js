({
    checkBrowser: function(component) {
        var device = $A.get("$Browser.formFactor");
        component.set("v.deviceName", device);
        window.scrollTo(0, 0);
    },
    handleClick : function(component, event, helper) {
        var label = event.getSource().get("v.label");
        if(label == 'Account Deletion'){
            component.set("v.showTileMenu",false);
            component.set("v.showAccountDeletion",true);
            component.set("v.showDoNotSellInfo",false);
            component.set("v.showDataAccess",false);
        }
        if(label == 'Do Not Sell My Info'){
            component.set("v.showTileMenu",false);
            component.set("v.showAccountDeletion",false);
            component.set("v.showDoNotSellInfo",true);
            component.set("v.showDataAccess",false);
        }
        if(label == 'Data Access'){
            component.set("v.showTileMenu",false);
            component.set("v.showAccountDeletion",false);
            component.set("v.showDoNotSellInfo",false);
            component.set("v.showDataAccess",true);
        }
    },
    
    handleApplicationEvent : function (component, event, helper){
        var NewCase = event.getParam("NewCase");
        component.set("v.showTileMenu",false);
        component.set("v.showAccountDeletion",false);
        component.set("v.showDoNotSellInfo",false);
        component.set("v.showDataAccess",false);
        component.set("v.NewCase", NewCase);
        helper.showToast(component, event, helper,'Your Case has been created','Success!');
        
    },
})