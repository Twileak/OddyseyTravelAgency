import { LightningElement, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SUCCESS_TITLE from '@salesforce/label/c.Review_Created';
import ERROR_TITLE from '@salesforce/label/c.Review_Issue';

export default class StarRating extends LightningElement {
    @api record;
    @api author;
    satisfactionRating = 0;
    buttonDisabled = true;

    label = {
                    SUCCESS_TITLE,
                    ERROR_TITLE
                };

    rating(event) {
        this.satisfactionRating = event.target.value;
        this.buttonDisabled = false;
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
        this.displayToast(this.label.SUCCESS_TITLE, "success");
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
        this.displayToast(this.label.ERROR_TITLE, "error");
    }

    displayToast(title, variant) {
        const toast = new ShowToastEvent({
                    title: title,
                    variant: variant,
                });
                this.dispatchEvent(toast);
    }
}