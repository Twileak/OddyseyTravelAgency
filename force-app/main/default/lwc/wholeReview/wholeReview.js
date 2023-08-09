import { LightningElement, wire, track, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import TITLE_LABEL from '@salesforce/label/c.Share';

export default class WholeReview extends LightningElement {
    @api recordId;
    @track authorName;

    label = {
                TITLE_LABEL
            };

    @wire(getRecord,{recordId: Id, fields: [UserNameFIELD]})
    currentUserInfo({error, data}) {
        if (data) {
            this.authorName = data.fields.Name.value;
        } else if (error) {
            this.error = error;
        }
    }
}