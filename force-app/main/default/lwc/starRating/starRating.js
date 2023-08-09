import { LightningElement, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SUCCESS_TITLE from '@salesforce/label/c.Review_Created';
import ERROR_TITLE from '@salesforce/label/c.Review_Issue';

export default class StarRating extends LightningElement {
    @api record;
    @api author;
    satisfactionRating = 0;

    label = {
                    SUCCESS_TITLE,
                    ERROR_TITLE
                };

    rating(event) {
        this.satisfactionRating = event.target.value;
    }

    get currentTimestamp(){
        return new Date().toISOString();
    }

    handleSubmit(event) {
        event.preventDefault();
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess() {
        const toast = new ShowToastEvent({
            title: this.label.SUCCESS_TITLE,
            variant: "success",
        });
        this.dispatchEvent(toast);
        this.handleReset();
    }

    handleReset() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if(inputFields) {
            inputFields.forEach(field => {field.reset(); });
            this.satisfactionRating = 0;
        }
    }

    handleError() {
        const errorToast = new ShowToastEvent({
                    title: this.label.ERROR_TITLE,
                    variant: "error",
                });
        this.dispatchEvent(errorToast);
    }
}