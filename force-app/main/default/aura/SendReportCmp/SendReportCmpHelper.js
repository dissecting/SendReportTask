({
    handleAction: function(component, recordId) {

    },

    handleStartLoading: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },

    handleStopLoading: function(component) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
    }
})
