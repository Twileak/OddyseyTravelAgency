({
    showEditModal: function(component, event, helper) {
        var idOfRecord = event.currentTarget.dataset.recordid;
        var nameOfRecord = event.currentTarget.dataset.recordname;
        helper.showEditModalHelper(component, idOfRecord, nameOfRecord);
    },

    handleEditCancel: function(component, event, helper) {
        helper.handleEditCancelHelper(component);
    },

    loadProducts: function(component, event, helper) {
        helper.loadProductsHelper(component);
    },

    deleteProduct: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        helper.deleteProductHelper(component, event, recordId);
    },

    handleError: function(component, event, helper) {
        var message = $A.get("$Label.c.Something_Wrong");
        var variant = "error";
        helper.handleToastMessage(component, message, variant);
    },

    handleSuccess: function(component, event, helper) {
        var message = $A.get("$Label.c.Success");
        var variant = "success";
        helper.handleToastMessage(component, message, variant);
    }
})