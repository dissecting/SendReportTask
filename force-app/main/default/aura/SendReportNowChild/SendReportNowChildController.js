({
    onSend: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.handleSend(component, helper, recordId);
    }
})