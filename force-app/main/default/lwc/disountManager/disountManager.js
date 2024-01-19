import { LightningElement, track, wire } from 'lwc';
import * as Labels from './labels.js';
import getProducts from '@salesforce/apex/DiscountManagerController.getProducts';
import getCategories from '@salesforce/apex/DiscountManagerController.getCategories';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import errorTitle from '@salesforce/label/c.Something_Wrong';
import getLowestPrice from '@salesforce/apex/DiscountManagerController.getLowestPrice';
import getSelectedProductsByCategory from '@salesforce/apex/DiscountManagerController.getSelectedProductsByCategory';
import createPromotion from '@salesforce/apex/DiscountManagerController.createPromotionJob';

export default class DisountManager extends LightningElement {
    activeSections = ['product', 'promotion', 'promotionValue'];
    allProducts = [];
    allCategories = [];
    selectedWeekdays = [];
    selectedProducts = [];
    selectedCategories = [];
    productsInSelectedCategory = [];
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
    @track isButtonDisabled = true;
    @track absolutePromotionValue = 0;
    @track percentagePromotionValue;
    @track oneTimePromotionStartDate = null;
    @track oneTimePromotionEndDate = null;
    @track periodicPromotionStartDate = null;
    @track periodicPromotionEndDate = null;
    @track highestAbsoluteDiscount = 0;

    get labels() {
        return Labels.labels;
    }

    get productOptions() {
        return [
            {label: this.labels.Product, value: 'product'},
            {label: this.labels.Category, value: 'category'}
        ];
    }

    get promotionValueTypeOptions() {
            return [
                {label: this.labels.Percent, value: 'percent'},
                {label: this.labels.Absolute, value: 'absolute'}
            ];
        }

    get periodicPromotionOptions() {
            return [
                {label: this.labels.Weekly, value: 'weekly'},
                {label: this.labels.Monthly, value: 'monthly'}
            ];
        }

    get weekdayOptions() {
        return [
            {label: this.labels.Monday, value: 'MON'},
            {label: this.labels.Tuesday, value: 'TUE'},
            {label: this.labels.Wednesday, value: 'WED'},
            {label: this.labels.Thursday, value: 'THU'},
            {label: this.labels.Friday, value: 'FRI'},
            {label: this.labels.Saturday, value: 'SAT'},
            {label: this.labels.Sunday, value: 'SUN'},
        ]
    }

    get promotionOptions() {
        return [
            {label: this.labels.One_time_promotion, value: 'oneTime'},
            {label: this.labels.Periodic_promotion, value: 'periodic'}
        ]
    }

    connectedCallback() {
        this.loadProducts();
        this.loadCategories();
        this.loadLowestPrice();
    }

    async loadLowestPrice() {
        try {
            const result = await getLowestPrice();
            if(result) {
                this.highestAbsoluteDiscount = result;
            }
        } catch(error) {
            this.displayToast(this.labels.errorTitle, JSON.stringify(error), "error");
        }
    }

    async loadProducts() {
        try {
            const result = await getProducts();
            if(result) {
                this.allProducts = result.map(product => ({label: product.Name, value: product.Id}));
            }
        } catch(error) {
            this.displayToast(this.labels.errorTitle, JSON.stringify(error), "error");
        }
    }

    async loadCategories() {
        try {
            const result = await getCategories();
            if(result) {
                this.allCategories = result.map(category => ({label: category.Name, value: category.Id}));
            }
        } catch(error) {
            this.displayToast(this.labels.errorTitle, JSON.stringify(error), "error");
        }
    }

    async loadProductsInSelectedCategories(listOfCategories) {
        try {
            const result = await getSelectedProductsByCategory({ categoryIds: listOfCategories });
            if(result) {
                this.productsInSelectedCategory = result.map(product => ({label: product.Name, value:product.Id}));
            }
        } catch(error) {
            this.displayToast(this.labels.errorTitle, JSON.stringify(error), "error");
        }
    }

    handleProductCheckboxChange(event) {
        this.selectedProducts = event.detail.value;
        this.handleEnabledSubmitButton();
    }

    handleCategoryCheckboxChange(event) {
        this.selectedCategories = event.detail.value;
        this.loadProductsInSelectedCategories(this.selectedCategories);
        this.handleEnabledSubmitButton();
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

    handlePeriodicPromotionTypeChange(event) {
        this.periodicPromotionType = event.detail.value;

        this.periodicWeeklyPromotion = this.periodicPromotionType === 'weekly';
        this.periodicMonthlyPromotion = this.periodicPromotionType === 'monthly';
    }

    handleWeekdaysCheckboxChange(event) {
        this.selectedWeekdays = event.detail.value;
        this.handleEnabledSubmitButton();
    }

    handlePromotionValueTypeChange(event) {
        this.promotionValueType = event.detail.value;

        this.absolutePromotionType = this.promotionValueType === 'absolute';
        this.percentagePromotionType = this.promotionValueType === 'percent';
    }

    handleAbsoluteValueChange(event) {
        this.absolutePromotionValue = event.detail.value;
        this.handleEnabledSubmitButton();
    }

    handlePercentageValueChange(event) {
        this.percentagePromotionValue = event.detail.value;
        this.handleEnabledSubmitButton();
    }

    handleOneTimeStartDateChange(event) {
        this.oneTimePromotionStartDate = event.detail.value;
        this.handleEnabledSubmitButton();
    }

    handleOneTimeEndDateChange(event) {
        this.oneTimePromotionEndDate = event.detail.value;
        this.handleEnabledSubmitButton();
    }

    handlePeriodicStartDateChange(event) {
        this.periodicPromotionStartDate = event.detail.value;
        this.handleEnabledSubmitButton();
    }

    handlePeriodicEndDateChange(event) {
        this.periodicPromotionEndDate = event.detail.value;
        this.handleEnabledSubmitButton();
    }

    displayToast(title, message, variant) {
        const toast = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toast);
    }

    handleCreatePromotion() {
        const promotion = {
            listOfProducts: this.selectProduct ? this.selectedProducts : this.productsInSelectedCategory.map(prod => prod.value),
            isPeriodic: this.periodicPromotion,
            isWeekly: this.periodicWeeklyPromotion,
            weekdays: this.selectedWeekdays,
            startDate: this.periodicMonthlyPromotion ? this.periodicPromotionStartDate : this.oneTimePromotionStartDate,
            endDate: this.periodicMonthlyPromotion ? this.periodicPromotionEndDate : this.oneTimePromotionEndDate,
            isAbsolute: this.absolutePromotionType,
            promotionValue: this.absolutePromotionType ? this.absolutePromotionValue : this.percentagePromotionValue/100
        }
        console.log('Create Promotion');
        const stringPromotion = JSON.stringify(promotion);
        createPromotion({stringPromotion: stringPromotion});
        this.displayToast('Congratulations!', 'Promotion was scheduled', 'Success');
        this.handleReset();
    }

    handleReset() {
        this.activeSections = ['product', 'promotion', 'promotionValue'];
        this.allProducts = [];
        this.allCategories = [];
        this.selectedWeekdays = [];
        this.selectedProducts = [];
        this.selectedCategories = [];
        this.productsInSelectedCategory = [];
        this.productValue = '';
        this.promotionValue = '';
        this.promotionValueType = '';
        this.selectProduct = false;
        this.selectCategory = false;
        this.oneTimePromotion = false;
        this.periodicPromotion = false;
        this.periodicPromotionType = '';
        this.periodicWeeklyPromotion = false;
        this.periodicMonthlyPromotion = false;
        this.percentagePromotionType = false;
        this.absolutePromotionType = false;
        this.isButtonDisabled = true;
        this.absolutePromotionValue = 0;
        this.percentagePromotionValue;
        this.oneTimePromotionStartDate = null;
        this.oneTimePromotionEndDate = null;
        this.periodicPromotionStartDate = null;
        this.periodicPromotionEndDate = null;
        this.highestAbsoluteDiscount = 0;
    }

    handleEnabledSubmitButton() {
        const areProductsSelected = this.selectedProducts ||  this.productsInSelectedCategory;
        const isDateSelected = ((this.oneTimePromotionStartDate || this.periodicPromotionStartDate) && (this.oneTimePromotionEndDate || this.periodicPromotionEndDate)) || (this.selectedWeekdays);
        const isDiscountSelected = this.absolutePromotionValue || this.percentagePromotionValue;

        this.isButtonDisabled = !(areProductsSelected && isDateSelected && isDiscountSelected);
    }
}