({
  
  // for text classification, OR when file/image is already present (and model changes)
    getvaluefromLWC : function(component, event, helper) {
        //helper.upload(component);
        component.set("v.markupPending", true);
        var contentrecordId=event.getParam('recordId');
        var contentrecord=event.getParam('recordData');
        console.log('LWC***'+contentrecordId);
        console.log('contentrecord***'+JSON.stringify(contentrecord.probabilities));
        helper.upload(component,contentrecordId,contentrecord);
        
    },
    
})