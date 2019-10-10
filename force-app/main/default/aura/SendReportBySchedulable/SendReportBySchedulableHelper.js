({
    handleInit : function(component, recordId) {
        var isVF = component.get("v.isVF");
        if (!isVF) {
            this.handleStartLoading(component);
        }
        this.handleAction(component, recordId, isVF);
    },

    handleAction: function(component, recordId, isVF) {
        var action = component.get("c.setSchedulable");
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
                        "message": "Successfully Scheduled Email!"
                    });
                    toastEvent.fire();
                } else {
                    component.set("v.isError", false);
                    component.set("v.msg", "Successfully Scheduled Email!");
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