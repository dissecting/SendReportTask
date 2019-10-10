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
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Email successfully sended!"
                    });
                    toastEvent.fire();
                } else {
                    component.set("v.isError", false);
                    component.set("v.msg", "Email successfully sended!");
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (!isVF) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": errors[0].message
                    });
                    toastEvent.fire();
                } else {
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