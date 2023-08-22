import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import errorTitle from '@salesforce/label/c.Something_Wrong';
import getProductNames from '@salesforce/apex/productComparerController.getProductNames';
import getProductDetails from '@salesforce/apex/productComparerController.getProductDetails';
import getProductPrice from '@salesforce/apex/productComparerController.getProductPrice';
import getReviewDetails from '@salesforce/apex/productComparerController.getReviewDetails';
import Accommodation from '@salesforce/label/c.Accommodation';
import All_Inclusive from '@salesforce/label/c.All_Inclusive';
import Current_Members from '@salesforce/label/c.Current_members';
import Duration from '@salesforce/label/c.Duration';
import Name from '@salesforce/label/c.Name';
import Summary from '@salesforce/label/c.Summary';
import Cities from '@salesforce/label/c.Cities';
import Transportation from '@salesforce/label/c.Transportation';
import Get_Product_Info from '@salesforce/label/c.Get_Product_Info';
import Select_Product_1 from '@salesforce/label/c.Select_Product_1';
import Select_Product_2 from '@salesforce/label/c.Select_Product_2';
import Price from '@salesforce/label/c.Price';
import Number_Of_Votes from '@salesforce/label/c.Number_of_Votes';
import Average_Rating from '@salesforce/label/c.Average_Rating';
import Free_Spots from '@salesforce/label/c.Free_Spots';
import Date from '@salesforce/label/c.Date';
import Continent from '@salesforce/label/c.Continent';
import Additional_Information from '@salesforce/label/c.Additional_Information';
const PRICEBOOK = '01s06000006AF0WAAW';

export default class ProductComparer extends LightningElement {
    @track selectedProduct1 = {productId: ''};
    @track selectedProduct2 = {productId: ''};
    allProductOptions = [];
    productOptions1 = [];
    productOptions2 = [];
    @track product1 = '';
    @track product2 = '';
    @track product1Price = '';
    @track product2Price = '';
    @track product1Reviews = '';
    @track product2Reviews = '';
    label = {
        errorTitle,
        Accommodation,
        All_Inclusive,
        Current_Members,
        Duration,
        Name,
        Summary,
        Transportation,
        Get_Product_Info,
        Select_Product_1,
        Select_Product_2,
        Price,
        Number_Of_Votes,
        Average_Rating,
        Free_Spots,
        Date,
        Continent,
        Additional_Information,
        Cities
    };

    get isButtonDisabled() {
        return !this.selectedProduct1.productId || !this.selectedProduct2.productId;
    }

    connectedCallback() {
        this.loadProductOptions();
    }

    async loadProductOptions() {
        try {
            const result = await getProductNames();
            if (result) {
                this.productOptions = result.map(product => ({ label: product.Name, value: product.Id }));
                this.productOptions1 = [...this.productOptions];
                this.productOptions2 = [...this.productOptions];
            }
        } catch (error) {
            this.displayToast(this.label.errorTitle, "error");
        }
    }

    handleProduct1Change(event) {
            this.productOptions2 = [...this.productOptions];
            const newSelectedValue = event.target.value;
            this.selectedProduct1.productId = newSelectedValue;
            this.productOptions2 = this.productOptions2.filter(option => option.value !== newSelectedValue);
        }

        handleProduct2Change(event) {
            this.productOptions1 = [...this.productOptions];
            const newSelectedValue = event.target.value;
            this.selectedProduct2.productId = newSelectedValue;
            this.productOptions1 = this.productOptions1.filter(option => option.value !== newSelectedValue);
        }

    async handleButtonClick() {
        try {
            const product1Details = await getProductDetails(this.selectedProduct1);
            const product1Price = await getProductPrice(this.selectedProduct1, PRICEBOOK);
            const product1Reviews = await getReviewDetails(this.selectedProduct1);
            const product2Details = await getProductDetails(this.selectedProduct2);
            const product2Price = await getProductPrice(this.selectedProduct2, PRICEBOOK);
            const product2Reviews = await getReviewDetails(this.selectedProduct2);

            this.product1 = product1Details;
            this.product1Price = product1Price.UnitPrice;
            this.product1Reviews = product1Reviews;
            this.product2 = product2Details;
            this.product2Price = product2Price.UnitPrice;
            this.product2Reviews = product2Reviews;
        } catch (error) {
            this.displayToast(this.label.errorTitle, "error");
         }
    }

    displayToast(title, variant) {
        const toast = new ShowToastEvent({
            title: title,
            variant: variant,
        });
        this.dispatchEvent(toast);
    }
}