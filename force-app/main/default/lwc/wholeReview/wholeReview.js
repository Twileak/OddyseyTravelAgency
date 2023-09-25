import { LightningElement, wire, track, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import TITLE_LABEL from '@salesforce/label/c.Share';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getComment from '@salesforce/apex/CommentsController.getComment';
import SUCCESS_TITLE from '@salesforce/label/c.Review_Created';
import ERROR_TITLE from '@salesforce/label/c.Review_Issue';

export default class WholeReview extends LightningElement {
    @api recordId;
    @track authorName;
    @track satisfactionRating = 0;
    @track myReview;
    buttonDisabled = true;
    @track showEdit = false;

    label = {
                TITLE_LABEL
            };

    @wire(getRecord,{recordId: Id, fields: [UserNameFIELD]})
    currentUserInfo({error, data}) {
        if (data) {
            this.authorName = data.fields.Name.value;
            console.log('Author: ', this.authorName);
            console.log('Product: ', this.recordId);
            this.getMyComment();
        } else if (error) {
            this.error = error;
        }
    }

    async getMyComment() {
        try {
            this.myReview = await getComment({user: this.authorName, productId: this.recordId});
            console.log('My review: ', JSON.stringify(this.myReview));
        } catch (error) {
            this.displayToast(this.label.errorTitle, "error");
        }
    }

    handleShowEdit() {
        this.showEdit = true;
    }

    displayToast(title, variant) {
        const toast = new ShowToastEvent({
            title: title,
            variant: variant,
        });
        this.dispatchEvent(toast);
    }

    rating(event) {
        this.satisfactionRating = event.target.value;
        this.buttonDisabled = false;
    }

    get currentTimestamp(){
        return new Date().toISOString();
    }

    handleSubmit(event) {;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Comment__c = this.comment;
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

    changeComment(){
        this.comment = event.detail.value;
    }
}