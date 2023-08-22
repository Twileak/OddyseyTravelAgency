import { LightningElement, track, wire } from 'lwc';


export default class DisountManager extends LightningElement {
    @track productValue = '';
    @track promotionValue = '';
    @track selectProduct = false;
    @track selectCategory = false;
    @track oneTimePromotion = false;
    @track periodicPromotion = false;

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
}