import { LightningElement, wire, track, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import TITLE_LABEL from '@salesforce/label/c.Share';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getComment from '@salesforce/apex/CommentsController.getComment';
import deleteReview from '@salesforce/apex/CommentsController.deleteReview';
import SUCCESS_TITLE from '@salesforce/label/c.Review_Created';
import ERROR_TITLE from '@salesforce/label/c.Review_Issue';

export default class WholeReview extends LightningElement {
    @api recordId;
    @track authorName;
    @track satisfactionRating = 0;
    @track myReview;
    buttonDisabled = true;
    @track showEdit = false;
    @track reviewCreated = false;
    @track showModal = false;

    label = {
                TITLE_LABEL
            };

    @wire(getRecord,{recordId: Id, fields: [UserNameFIELD]})
    currentUserInfo({error, data}) {
        if (data) {
            this.authorName = data.fields.Name.value;
            this.getMyComment();
        } else if (error) {
            this.error = error;
        }
    }

    async getMyComment() {
        try {
            this.myReview = await getComment({user: this.authorName, productId: this.recordId});
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

    handleReviewCreated(){
        this.reviewCreated = true;
    }

    rating(event) {
        this.satisfactionRating = event.target.value;
        this.buttonDisabled = false;
    }

    get currentTimestamp(){
        return new Date().toISOString();
    }

    async handleSubmit(event) {;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Comment__c = this.comment;
        fields.Approval_Status__c = 'Waiting';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        console.log(this.myReview.Id)
        try {
        console.log('Author: ', this.authorName);
            const deleted = await deleteReview({recordId: this.recordId, author: this.authorName});
            console.log(deleted);
        } catch(error){
            this.displayToast(this.label.errorTitle, "error");
        }
    }

    handleSuccess() {
        this.displayToast(this.label.SUCCESS_TITLE, "success");
        this.handleReset();
        this.handleReviewCreated();
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

    showConfirmationModal() {
            this.showModal = true;
        }

    closeModal() {
            this.showModal = false;
        }

    async deleteReview() {
        try {
            const deleted = await deleteReview({recordId: this.recordId, author: this.authorName});
            console.log(deleted);
        } catch(error){
            this.displayToast(this.label.errorTitle, "error");
        }
        this.showModal = false;
        location.reload();
    }

    cancelEdit() {
        this.showEdit = false;
    }
}