({
    doInit: function(component, event, helper) {
        //Send LC Host as parameter to VF page so VF page can send message to LC; make it all dynamic
        component.set('v.lcHost', window.location.hostname);
        component.set('v.users', []);
        window.addEventListener("message", $A.getCallback(function (ev) {
            helper.listener(component, ev, helper) 
        }),false);
    }
})