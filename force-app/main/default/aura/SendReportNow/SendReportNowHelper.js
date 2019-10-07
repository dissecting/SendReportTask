({
    handleSendData: function(component, method, params) {
        var action = component.get(method);
        action.setParams({
            recordId: params
        });

        action.setCallback(this, function(response) {
            this.handleSetState(component, response);
        });
        $A.enqueueAction(action);
    }
})