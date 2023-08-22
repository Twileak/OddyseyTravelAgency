import { LightningElement, track, wire } from 'lwc';
import getProducts from '@salesforce/apex/DiscountManagerController.getProducts';
import getCategories from '@salesforce/apex/DiscountManagerController.getCategories';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import errorTitle from '@salesforce/label/c.Something_Wrong';

export default class DisountManager extends LightningElement {
    allProducts = [];
    allCategories = [];
    selectedProducts = [];
    selectedCategories = [];
    @track productValue = '';
    @track promotionValue = '';
    @track selectProduct = false;
    @track selectCategory = false;
    @track oneTimePromotion = false;
    @track periodicPromotion = false;

    label = {
        errorTitle
    }

    get productOptions() {
        return [
            {label: 'Product', value: 'product'},
            {label: 'Category', value: 'category'}
        ];
    }

    get promotionOptions() {
        return [
            {label: 'One time promotion', value: 'oneTime'},
            {label: 'Periodic promotion', value: 'periodic'}
        ]
    }

    connectedCallback() {
        this.loadProducts();
        this.loadCategories();
    }

    async loadProducts() {
        try {
            const result = await getProducts();
            if(result) {
                this.allProducts = result.map(product => ({label: product.Name, value: product.Id}));
            }
        } catch(error) {
            this.displayToast(this.label.errorTitle, "error");
        }
    }

    async loadCategories() {
        try {
            const result = await getCategories();
            if(result) {
                this.allCategories = result.map(category => ({label: category.Name, value: category.Id}));
            }
        } catch(error) {
            this.displayToast(this.label.errorTitle, "error");
        }
    }

    handleProductCheckboxChange(event) {
        this.selectedProducts = event.detail.value;
    }

    handleCategoryCheckboxChange(event) {
        this.selectedCategories = event.detail.value;
    }

    handleProductSelectionChange(event) {
        this.productValue = event.detail.value;

        this.selectProduct = this.productValue === 'product';
        this.selectCategory = this.productValue === 'category';
    }

    handlePromotionSelectionChange(event) {
        this.promotionValue = event.detail.value;

        this.oneTimePromotion = this.promotionValue === 'oneTime';
        this.periodicPromotion = this.promotionValue === 'periodic';
    }

    displayToast(title, variant) {
        const toast = new ShowToastEvent({
            title: title,
            variant: variant,
        });
        this.dispatchEvent(toast);
    }
}