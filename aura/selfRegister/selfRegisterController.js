({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();        
        component.set('v.extraFields', helper.getExtraFields(component, event, helper));
        var query = location.search.substr(1);
        var sURLVariables = query.split('&');
        if(sURLVariables.length>1){
            component.set("v.storeLocatorId",helper.getJsonFromUrl().storeLocatorId);//will get abc as storeLocatorId
            console.log('storeLocatorId'+component.get("v.storeLocatorId"));
        }
       // 
    },
    
    handleSelfRegister: function (component, event, helpler) {
       if($A.util.isEmpty(component.find("firstname").get("v.value")) ||
         $A.util.isEmpty(component.find("lastname").get("v.value")) ||
         $A.util.isEmpty(component.find("email").get("v.value")) ||
         $A.util.isEmpty(component.find("phone").get("v.value")) ){
                   component.set("v.errorMessage",'All * should be required');
                   component.set("v.showError",true);
       }else{
           component.set("v.errorMessage",'');
           helpler.handleSelfRegister(component, event, helpler);
       }
        
    },
     handleLogin: function(component, event, helpler) {  
        var startUrl = component.get("v.startUrl");
        var storeLocatorId=component.get("v.storeLocatorId");
         //
         console.log('***starturl'+decodeURIComponent(startUrl));
         console.log('***login:'+component.get("v.loginUrl"));
        startUrl ='/?storeLocatorId='+storeLocatorId+'&startUrl='+startUrl;
        var attributes = { url: startUrl,"storeLocatorId": component.get("v.storeLocatorId") };    
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component, event, helper);
    },
    
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
    } ,
     // function automatic called by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    }
})