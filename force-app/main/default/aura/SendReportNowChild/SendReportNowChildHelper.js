({
    handleInit : function(component, recordId) {
        this.handleStartLoading(component);
        this.handleAction(component, recordId);
    },

    handleAction: function(component, recordId) {
        var action = component.get("c.getReport");
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
                        "message": "Email successfully sended!"
                    });
                } else {
                    component.set("v.isConfirm", true);
                    component.set("v.isError", false);
                    component.set("v.msg", "Email successfully sended!");
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