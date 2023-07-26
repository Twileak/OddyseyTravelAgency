({
    showEditModal: function(component, event, helper) {
            var target = event.currentTarget;
            var idOfRecord = target.dataset.recordid;
            console.log('value: ', idOfRecord);
            component.set("v.selectedRecordId", idOfRecord);
            component.set("v.showModal", true);
        },

    handleEditCancel: function(component, event, helper) {
             component.set("v.showModal", false);
         },

    loadProducts: function(component, event, helper) {
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

    deleteProduct: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;

        var action = component.get("c.deleteProductRecord");
        action.setParams({
            productId: recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS"){
                var products = component.get("v.products");
                var updatedProducts = products.filter(function(product) {
                    return product.Id !== recordId;
                });
                component.set("v.products", updatedProducts);
                var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "title": "Record deleted",
                                "variant": "success"
                            });
                            resultsToast.fire();
            } else {
                var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "title": "Error during deleting record",
                                "variant": "error"
                            });
                            resultsToast.fire();
                console.log("Error deleting record " + state);
            }
        });
        $A.enqueueAction(action);
    },
    handleError: function (cmp, event, helper) {
            cmp.find('notifLib').showToast({
                "title": "Something has gone wrong!",
                "message": event.getParam("message"),
                "variant": "error"
            });
        },
    handleSuccess: function (cmp, event, helper) {
            cmp.find('notifLib').showToast({
                "title": "action successful!",
                "message": event.getParam("message"),
                "variant": "success"
            });
        }
})