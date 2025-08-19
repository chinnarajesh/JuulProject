({
    call: function(component, action, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            if (params) {
                action.setParams(params);
            }
            action.setCallback(this, function(a) {
                var err = a.getError();
                var result = a.getReturnValue();
                if (err && err.length > 0) reject(err);
                else resolve(result);
            });
            $A.enqueueAction(action, false);
        }));

    },
    syncViewer: function(component, helper) {
        // console.log('called');
        return helper.call(component, component.get('c.handleViewers'), {
            caseId: component.get('v.recordId')
        }).then(function(result) {
            console.log(result);
            component.set('v.viewers', result);
            return result;
        })
    },
    handleInactive: function(component, helper) {
        helper.call(component, component.get('c.handleInactive'), {
            caseId: component.get('v.recordId')
        }).then(function(result) {

        })
    },
    toast: function(component, helper, res) {
        var viewers = res.viewers;
        var allViewers = viewers.map(function(r) {
            return r.User__r.Name;
        }).join(',');

        var currentUser = component.get('v.user');

        if (viewers.length > 0) {
            swal({
                type: 'info',
                html: `<b>${allViewers}</b> <br/> is actively viewing this case`,
                allowOutsideClick: false,
                allowEscapeKey: false,
                allowEnterKey: false,
                showCancelButton :  component.get('v.skip'),
                cancelButtonText : 'Continue',
                confirmButtonText: 'Close Tab'
            }).then(function(r) {
                console.log(r);
                if (r) {
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getEnclosingTabId().then(function(tabId) {
                        workspaceAPI.closeTab({
                            tabId: tabId
                        });
                        window.clearInterval(component.get("v.timer"));
                    })
                }

            }).catch(function(){
                if (component.get('v.skip')){
                    // update case from here
                    helper.call(component, component.get('c.updateCase'), {
                        caseId: component.get('v.recordId')
                    }).then(function(result) {
                        console.log(result);
                    })

                }

            })
        }
    },
    getViewers: function(component, viewers, cUser) {
        var m = {};
        var allAgent = true;
        viewers = viewers || [];
        var caseviewers = component.get('v.caseviewers');

        caseviewers = caseviewers || {};
        for (var i = 0; i < viewers.length; i++) {
            if (!caseviewers[viewers[i].User__c] && cUser.Id != viewers[i].User__c) {
                m[viewers[i].User__c] = viewers[i];
                if (component.get('v.skip')) {
                    allAgent = false;
                }
            }

        }


        caseviewers = Object.assign({}, caseviewers, m);
        component.set('v.caseviewers', caseviewers);

        return {
            allAgent: allAgent,
            viewers: Object.values(m)
        };
    },
    sync: function(component, helper) {
        helper.syncViewer(component, helper).then(function(res) {
            // console.log(res);
            var viewers = res.viewers;
            var currentUser = res.user;
            var caseviewers = component.get('v.caseviewers');
            component.set('v.user', res.user);
            component.set('v.skip', res.skip);
            if (currentUser.Id != viewers[0].User__c) {
                // do toast
                var filtered = helper.getViewers(component, viewers, currentUser);
                helper.toast(component, helper, filtered);
            }
        })
    }

})