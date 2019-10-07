({
    handleSendData: function(component, method, params) {
        var action = component.get(method);
        action.setParams({
            recordId: params
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.stateStatus", state);
            if (state === "ERROR") {
                var errors = response.getError();
                component.set("v.errorMsg", errors[0].message);
            }
        });
        $A.enqueueAction(action);
    }
})