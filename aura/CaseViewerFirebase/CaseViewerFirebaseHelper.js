({
    sendMessage: function(component, helper, message) {
        message.origin = window.location.hostname;
        if (component.find("vfFrame")) {
            var vfWindow = component.find("vfFrame").getElement().contentWindow;
            if (vfWindow.postMessage) vfWindow.postMessage(JSON.stringify(message), component.get("v.vfHost"));
            else console.error('not able to find iframe postMessage', vfWindow);
        } else {
            console.log('not able to find iframe');
        }

    },

    sendToVF: function(component, helper, message) {
        helper.sendMessage(component, helper, message);
    },

    listener: function(component, event, helper) {
        console.log('event.data.state', event.data);
        if (event.data.state == 'LOADED') {
            // called when firebase is ready with the list of users for this
            // particular record
            component.set("v.vfHost", event.data.vfHost);
            component.set("v.users", event.data.payload);
            component.set("v.user", event.data.currentUser);
            component.set("v.skip", event.data.skip);
            component.set("v.idle", event.data.idle);
            helper.setupIdleHandler(component, helper);
            helper.toast(component, helper);
        } else if (event.data.state == 'CHANGED') {
            var users = component.get('v.users') || [];
            for (var i = 0; i < users.length; i++) {
                if (event.data.payload.Id == users[i].Id) {
                    users[i] = event.data.payload;
                }
            }
            component.set('v.users', helper.dedupe(users));
        } else if (event.data.state == 'ADDED') {
            var users = component.get('v.users') || [];
            users.push(event.data.payload);
            component.set('v.users', helper.dedupe(users));
        } else if (event.data.state == 'REMOVED') {
            var users = component.get('v.users') || [];
            var data = [];
            for (var i = 0; i < users.length; i++) {
                if (event.data.payload.Id != users[i].Id) {
                    data.push(users[i]);
                }
            }
            component.set('v.users', helper.dedupe(users));
        }
    },

    setupIdleHandler: function(component, helper) {
        var idle = new Idle({
            onHidden: $A.getCallback(function() {
                // helper.setUserStatus(component, helper, "idle");
            }),
            onVisible: $A.getCallback(function() {
                helper.setUserStatus(component, helper, "online");
            }),
            onAway: $A.getCallback(function() {
                helper.setUserStatus(component, helper, "away");
            }),
            onAwayBack: $A.getCallback(function() {
                helper.setUserStatus(component, helper, "online");
            }),
            awayTimeout: component.get("v.idle")
        });
    },
    setUserStatus: function(component, helper, status) {
        console.log('sending vf', status);
        helper.sendToVF(component, helper, {
            message: 'STATUS',
            payload: status
        });

    },
    toast: function(component, helper) {
        var users = component.get('v.users') || [];



        var currentUser = component.get('v.user');

        var otherUsers = users.filter(function(r) {
            return r.Id != currentUser.Id && r.status != 'away';
        })

        var allViewers = otherUsers.map(function(r) {
            return r.Name;
        }).join(',');

        if (otherUsers.length > 0) {

            // $A.getCallback(function() {

            swal({
                type: 'info',
                html: `<b>${allViewers}</b> <br/> is actively viewing this case`,
                allowOutsideClick: false,
                allowEscapeKey: false,
                allowEnterKey: true,
                showCancelButton: component.get('v.skip'),
                cancelButtonText: 'Continue',
                confirmButtonText: 'Close Tab'
            }).then(function(r) {
                console.log(r);
                if (r) {
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getEnclosingTabId().then(function(tabId) {
                        console.log('tab', tabId);
                        workspaceAPI.closeTab({
                            tabId: tabId
                        });
                        // window.clearInterval(component.get("v.timer"));
                    })
                }

            }).catch(function(res) {
                if (component.get('v.skip')) {
                    // update case from here
                    helper.call(component, component.get('c.updateCase'), {
                        caseId: component.get('v.recordId')
                    }).then(function(result) {
                        console.log(result);
                    })

                }

            })
            //})

        }
    },
    dedupe : function (users) {
        var ids = [];
        var uniqueUsers = [];
        for (var i = 0; i < users.length; i++) {
            if (ids.indexOf(users[i].Id) === -1) {
                uniqueUsers.push(users[i]);
                ids.push(users[i].Id);
            }

        }
        return uniqueUsers;
    },
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

    }
})