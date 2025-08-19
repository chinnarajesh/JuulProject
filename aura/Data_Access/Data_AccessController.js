({
    doInit: function(component, event, helper) {
        window.scrollTo(0, 0);
    },
    handleClick : function(component, event, helper) {component.set("v.showSpinner", true);
        var label = event.getSource().get("v.label");
        if(label == 'Submit'){
            var contactFields = component.find("Data_Access");
            var blank=0;
            if(contactFields.length!=undefined) {
                var allValid = contactFields.reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
                if (!allValid) {
                    blank++;
                }
            } else {
                var allValid = contactFields;
                if (!allValid.get('v.validity').valid) {
                    blank++;
                }
            }
            if(blank==0) {
                var verifyCaptcha = component.get("v.verifyCaptcha");
                /*var fileName = component.get("v.fileName");
                if(fileName == 'No File Selected..'){
                    component.set("v.showSpinner", false);
                    component.set("v.errorMsgFileUpload",'Please upload signed copy');
                } */
                var isSubmitTrue = helper.verifyCheckboxes(component,event,helper);
                if(isSubmitTrue){
                   if(verifyCaptcha){
                    helper.createCaseHelper(component, event, helper); 
                }
                else{
                    component.set("v.showSpinner", false);
                    component.set("v.errorMsg","Please verify Captcha to submit request");  
                } 
                }
                else{
                    component.set("v.showSpinner",false);
                }
                
            }
            else{
                component.set("v.showSpinner",false);
            }
        }
        if(label == 'Back'){
            component.set("v.showTileMenu",true);
            component.set("v.showAccountDeletion",false);
            component.set("v.showDoNotSellInfo",false);
            component.set("v.showDataAccess",false);
            component.set("v.showSpinner", false);
        } 
    },
    
    formatPhone : function(component, event, helper) {
        var CaseValues = component.get("v.CaseValues");
        if(CaseValues.SuppliedPhone != undefined && CaseValues.SuppliedPhone!='' 
           && CaseValues.SuppliedPhone.length == 10 && CaseValues.SuppliedPhone.indexOf('-') == -1){
            var SuppliedPhone = CaseValues.SuppliedPhone.substring(0,3)+'-'
            + CaseValues.SuppliedPhone.substring(3,6)+ '-'+
                CaseValues.SuppliedPhone.substring(6,10);
            component.set("v.CaseValues.SuppliedPhone", SuppliedPhone);
        } 
    },
    
})