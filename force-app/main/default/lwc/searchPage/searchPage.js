import { LightningElement, wire, track } from 'lwc';
import getAllProducts from '@salesforce/apex/ProductController.getAllProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SearchPage extends LightningElement {
    @track products;
    @track selectedProduct;

    @wire(getAllProducts)
    wiredAllProducts(value){
        this.results = value;
        const{data, error} = value;
        if(data){
            this.products = JSON.parse(data);
        }else if(error){
            const event = new ShowToastEvent({
                title: 'No Results',
                message: 'We found no results',
                variant: 'info'
            });
            this.dispatchEvent(event);
            return;
        }
    }
}