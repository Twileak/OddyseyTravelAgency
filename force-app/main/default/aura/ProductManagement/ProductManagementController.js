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
        helper.deleteProductHelper(component, recordId);
    },

    handleError: function(cmp, event, helper) {
        helper.handleErrorHelper(cmp, event);
    },

    handleSuccess: function(cmp, event, helper) {
        helper.handleSuccessHelper(cmp, event);
    }
})