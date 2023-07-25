({
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

    editProduct: function(component, event, helper) {
        var productId = event.currentTarget.dataset.recordId;
        var products = component.get("v.products");
        var product = products.find(p => p.Id === productId);
        component.set("v.newProduct", JSON.parse(JSON.stringify(product)));
    },

    deleteProduct: function(component, event, helper) {
        var productId = event.currentTarget.dataset.recordId;
        var action = component.get("c.deleteProduct");
        action.setParams({ productId: productId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.products", response.getReturnValue());
            } else {
                console.error("Failed to delete product.");
            }
        });
        $A.enqueueAction(action);
    },

    saveProduct: function(component, event, helper) {
        var newProduct = component.get("v.newProduct");
        var action = component.get("c.saveProduct");
        action.setParams({ product: newProduct });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.products", response.getReturnValue());
                component.set("v.newProduct", { 'sobjectType': 'Product2' });
            } else {
                console.error("Failed to save product.");
            }
        });
        $A.enqueueAction(action);
    }
});