({
    doInit: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.handleInit(component, recordId);
    },

    onRemove: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.handleRemove(component, recordId);
    }
})