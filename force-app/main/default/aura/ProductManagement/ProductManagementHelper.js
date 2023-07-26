({
    showEditModalHelper: function(component, recordId, recordName) {
        component.set("v.selectedRecordId", recordId);
        component.set("v.selectedRecordName", recordName);
        component.set("v.showModal", true);
    },

    handleEditCancelHelper: function(component) {
        component.set("v.showModal", false);
    },

    loadProductsHelper: function(component) {
        var action = component.get("c.getProducts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.products", response.getReturnValue());
            } else {
                console.error("Failed to load products.");
            }
        });
        $A.enqueueAction(action);
    },

    deleteProductHelper: function(component, recordId) {
        var action = component.get("c.deleteProductRecord");
        action.setParams({
            productId: recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var products = component.get("v.products");
                var updatedProducts = products.filter(function(product) {
                    return product.Id !== recordId;
                });
                component.set("v.products", updatedProducts);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": $A.get("$Label.c.Record_deleted"),
                    "variant": "success"
                });
                resultsToast.fire();
            } else {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": $A.get("$Label.c.Error_On_Delete"),
                    "variant": "error"
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    },

    handleErrorHelper: function(cmp, event) {
        cmp.find('notifLib').showToast({
            "title": $A.get("$Label.c.Something_Wrong"),
            "message": event.getParam("message"),
            "variant": "error"
        });
    },

    handleSuccessHelper: function(cmp, event) {
        cmp.find('notifLib').showToast({
            "title": $A.get("$Label.c.Success"),
            "message": event.getParam("message"),
            "variant": "success"
        });
    }
})