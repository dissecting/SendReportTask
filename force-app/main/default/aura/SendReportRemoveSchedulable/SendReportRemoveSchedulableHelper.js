({
    handleInit : function(component, recordId) {
        var action = component.get("c.checkCronStatus");
        this.handleStartLoading(component);
        var isVF = component.get("v.isVF");
        action.setParams({
            recordId: recordId
        });
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
                } else {
                    component.set("v.isConfirm", false);
                    component.set("v.isError", true);
                    component.set("v.msg", errors[0].message);
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                console.error(errors);
                this.handleStopLoading(component);
            }
        });
        $A.enqueueAction(action);
    },

    handleAction: function(component, recordId) {
        var action = component.get("c.removeSchedulable");
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
                        "message": "Schedulable was successfully removed!"
                    });
                } else {
                    component.set("v.isConfirm", true);
                    component.set("v.isError", false);
                    component.set("v.msg", "Schedulable was successfully removed!");
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
            this.handleStopLoading(component);
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });
        $A.enqueueAction(action);
    }
})