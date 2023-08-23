import { LightningElement, track, wire } from 'lwc';
import getProducts from '@salesforce/apex/DiscountManagerController.getProducts';
import getCategories from '@salesforce/apex/DiscountManagerController.getCategories';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import errorTitle from '@salesforce/label/c.Something_Wrong';

export default class DisountManager extends LightningElement {
    allProducts = [];
    allCategories = [];
    selectedWeekdays = [];
    selectedProducts = [];
    selectedCategories = [];
    @track productValue = '';
    @track promotionValue = '';
    @track promotionValueType = '';
    @track selectProduct = false;
    @track selectCategory = false;
    @track oneTimePromotion = false;
    @track periodicPromotion = false;
    @track periodicPromotionType = '';
    @track periodicWeeklyPromotion = false;
    @track periodicMonthlyPromotion = false;
    @track percentagePromotionType = false;
    @track absolutePromotionType = false;
    @track absolutePromotionValue = 0;
    @track percentagePromotionValue = 0;
    @track oneTimePromotionStartDate = '';
    @track oneTimePromotionEndDate = '';
    @track periodicPromotionStartDate = '';
    @track periodicPromotionEndDate = '';

    label = {
        errorTitle
    }

    get productOptions() {
        return [
            {label: 'Product', value: 'product'},
            {label: 'Category', value: 'category'}
        ];
    }

    get promotionValueTypeOptions() {
            return [
                {label: 'Percent', value: 'percent'},
                {label: 'Absolute', value: 'absolute'}
            ];
        }

    get periodicPromotionOptions() {
            return [
                {label: 'Weekly', value: 'weekly'},
                {label: 'Monthly', value: 'monthly'}
            ];
        }

    get weekdayOptions() {
        return [
            {label: 'Monday', value: 'monday'},
            {label: 'Tuesday', value: 'tuesday'},
            {label: 'Wednesday', value: 'wednesday'},
            {label: 'Thursday', value: 'thursday'},
            {label: 'Friday', value: 'friday'},
            {label: 'Saturday', value: 'saturday'},
            {label: 'Sunday', value: 'sunday'},
        ]
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
        console.log(this.selectedProducts);
    }

    handleCategoryCheckboxChange(event) {
        this.selectedCategories = event.detail.value;
        console.log(this.selectedCategories);
    }

    handleProductSelectionChange(event) {
        this.productValue = event.detail.value;

        this.selectProduct = this.productValue === 'product';
        this.selectCategory = this.productValue === 'category';
        console.log(this.productValue);
    }

    handlePromotionSelectionChange(event) {
        this.promotionValue = event.detail.value;

        this.oneTimePromotion = this.promotionValue === 'oneTime';
        this.periodicPromotion = this.promotionValue === 'periodic';
        console.log(this.promotionValue);
    }

    handlePeriodicPromotionTypeChange(event) {
        this.periodicPromotionType = event.detail.value;

        this.periodicWeeklyPromotion = this.periodicPromotionType === 'weekly';
        this.periodicMonthlyPromotion = this.periodicPromotionType === 'monthly';
        console.log(this.periodicPromotionType);
    }

    handleWeekdaysCheckboxChange(event) {
        this.selectedWeekdays = event.detail.value;
        console.log(this.selectedWeekdays);
    }

    handlePromotionValueTypeChange(event) {
        this.promotionValueType = event.detail.value;
        console.log(this.promotionValueType);

        this.absolutePromotionType = this.promotionValueType === 'percent';
        this.percentagePromotionType = this.promotionValueType === 'absolute';
    }

    displayToast(title, variant) {
        const toast = new ShowToastEvent({
            title: title,
            variant: variant,
        });
        this.dispatchEvent(toast);
    }
}