({
    captchaCapture : function(component, event, helper,vforigin){
        window.addEventListener("message", function(event){
            if(event.origin!=vforigin){
                return;
            }
            if(event.data==="Unlock"){
                component.set("v.verifyCaptcha",true);
                component.set("v.errorMsg","");
            }
        },false);
    },
    getCustomSettingValues : function(component, event, helper){
        var baseURL = '';
        var communityName ='';
        var urlString = window.location.href;
        if(urlString.indexOf('http') != -1){
            baseURL = urlString.split('/')[2];
            communityName = urlString.split('/')[3];
        }
        else{
            baseURL = urlString.split('/')[0];
            communityName = urlString.split('/')[1];
        }
        if(urlString.indexOf('--') != -1){
            var finalURL = 'https://support.juul.com/Juul_CCPAComReCaptcha';
        }
        else{
            var finalURL = 'https://support.juul.com/Juul_CCPAComReCaptcha';
        }
        component.set("v.IframeEndpoint", finalURL);
        component.set("v.showSpinner", false);
        this.captchaCapture(component,event,helper,'https://'+baseURL);
        
    },
    
})