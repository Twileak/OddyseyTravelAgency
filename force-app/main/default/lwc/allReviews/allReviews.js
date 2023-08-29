import { LightningElement, api, wire, track } from 'lwc';
import getReviews from '@salesforce/apex/AllReviewsController.getReviews';
import TITLE_LABEL from '@salesforce/label/c.Product_Reviews';
import NO_REVIEWS from '@salesforce/label/c.No_Reviews';

export default class AllReviews extends LightningElement {
    @api recordId;
    reviews = [];
    error = "";

    label = {
                    TITLE_LABEL,
                    NO_REVIEWS
                };

    @wire(getReviews, { productId: '$recordId' })
    wiredReviews({error, data}) {
        if(data) {
            this.reviews = data;
        } else if(error) {
            this.error = error;
        }
    };

    get hasReviews() {
        return this.reviews !== undefined && this.reviews != null && this.reviews.length > 0;
    }
}