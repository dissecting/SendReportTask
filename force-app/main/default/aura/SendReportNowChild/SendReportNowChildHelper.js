({
    handleSend: function(component, helper, recordId) {
        var isVF = component.get("v.isVF");

        helper.handleSendData(component,
            "c.getReport",
            recordId
        );

        window.setTimeout(
            $A.getCallback(function() {
                var state = component.get("v.stateStatus");

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
                    var errors = component.get("v.errorMsg");
                    if (!isVF) {
                        component.find("notifLib").showToast({
                            "variant": "error",
                            "header": "Error!",
                            "message": errors
                        });
                    } else {
                        component.set("v.isConfirm", false);
                        component.set("v.isError", true);
                        component.set("v.msg", errors[0].message);
                    }
                    console.error(errors);
                }
            }), 4000
        );
    }
})