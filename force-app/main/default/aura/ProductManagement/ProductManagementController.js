({
    showEditModal: function(component, event, helper) {
        var idOfRecord = event.currentTarget.dataset.recordid;
        var nameOfRecord = event.currentTarget.dataset.recordname;
        helper.showEditModalHelper(component, idOfRecord, nameOfRecord);
    },

    handleEditCancel: function(component, event, helper) {
        helper.handleEditCancelHelper(component);
    },

    showDeleteModal: function(component, event, helper) {
        var idOfRecord = event.currentTarget.dataset.recordid;
        helper.showDeleteModalHelper(component, idOfRecord);
    },

    handleDeleteCancel: function(component, event, helper) {
            helper.handleDeleteCancelHelper(component);
        },

    loadProducts: function(component, event, helper) {
        helper.loadProductsHelper(component);
    },

    deleteProduct: function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        helper.deleteProductHelper(component, event, recordId);
    },

    handleError: function(component, event, helper) {
        helper.handleToastMessage(component, $A.get("$Label.c.Something_Wrong"), "error");
    },

    handleSuccess: function(component, event, helper) {
        helper.handleToastMessage(component, $A.get("$Label.c.Something_Wrong"),"success");
    }
})