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
                var message = $A.get("$Label.c.Something_Wrong");
                var variant = "error";
                this.handleToastMessage(component, message, variant);
            }
        });
        $A.enqueueAction(action);
    },

    deleteProductHelper: function(component, event, recordId) {
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
                var message = $A.get("$Label.c.Record_deleted");
                var variant = "success"
                this.handleToastMessage(component, message, variant);
            } else {
                var message = $A.get("$Label.c.Error_On_Delete");
                var variant = "error"
                this.handleToastMessage(component, message, variant);
            }
        });
        $A.enqueueAction(action);
    },

    handleToastMessage: function(component, message, variant) {
        component.find('notifLib').showToast({
                    "message": message,
                    "variant": variant
                });
    }
})