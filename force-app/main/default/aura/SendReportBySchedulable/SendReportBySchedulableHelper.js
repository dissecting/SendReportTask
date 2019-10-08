({
    handleInit : function(component, recordId) {
        var action = component.get("c.checkSchedulableStatus");
        var isVF = component.get("v.isVF");
        action.setParams({
            recordId: recordId
        });
        if (!isVF) {
            this.handleStartLoading(component);
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.handleAction(component, recordId);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (!isVF) {
                    component.find("notifLib").showToast({
                        "variant": "error",
                        "header": "Error!",
                        "message": errors[0].message
                    });
                    this.handleStopLoading(component);
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                } else {
                    component.set("v.isConfirm", false);
                    component.set("v.isError", true);
                    component.set("v.msg", errors[0].message);
                }
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    handleAction: function(component, recordId) {
        var action = component.get("c.setSchedulable");
        var isVF = component.get("v.isVF");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (!isVF) {
                    component.find("notifLib").showToast({
                        "variant": "success",
                        "header": "Success!",
                        "message": "Successfully Scheduled Email!"
                    });
                } else {
                    component.set("v.isConfirm", true);
                    component.set("v.isError", false);
                    component.set("v.msg", "Successfully Scheduled Email!");
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (!isVF) {
                    component.find("notifLib").showToast({
                        "variant": "error",
                        "header": "Error!",
                        "message": errors[0].message
                    });
                } else {
                    component.set("v.isConfirm", false);
                    component.set("v.isError", true);
                    component.set("v.msg", errors[0].message);
                }
                console.error(errors);
            }
            if (!isVF) {
                this.handleStopLoading(component);
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    }
})