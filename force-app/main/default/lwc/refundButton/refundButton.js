import { LightningElement, api, track, wire} from 'lwc';
import refundOrderApex from '@salesforce/apex/RefundButtonController.refundOrder';
import getCurrentStatus from '@salesforce/apex/RefundButtonController.getCurrentStatus';
import Are_you_sure from '@salesforce/label/c.Are_you_sure_refund';
import Refund from '@salesforce/label/c.Refund';
import Confirm_refund from '@salesforce/label/c.Confirm_refund';
import Cancel from '@salesforce/label/c.Cancel';
import Yes from '@salesforce/label/c.Yes';

export default class RefundButton extends LightningElement {
    @api orderId;
    @track showModal = false;
    @track isRefundDisabled;

    label = {
        Are_you_sure,
        Refund,
        Confirm_refund,
        Cancel,
        Yes
    };

    @wire(getCurrentStatus, {orderId: '$orderId'})
    wiredStatus(data){
        this.isRefundDisabled = data.data == 'Reviewed for refund';
    }

    showConfirmationModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    refundOrder() {
        refundOrderApex({ orderId: this.orderId })
            .then(result => {
                this.showModal = false;
            })
            .catch(error => {
                this.showModal = false;
            });
    }
}