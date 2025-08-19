({
	handleClick : function(component, event, helper) {
        var hotsheetURL = component.get("v.simpleRecord.Hot_Sheet_URL_Link__c");
        console.log('hotsheetURLhotsheetURL************* '+hotsheetURL);
    /*  	var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": hotsheetURL
        });
       urlEvent.fire(); */
    window.open(hotsheetURL, '_blank');
    }
})