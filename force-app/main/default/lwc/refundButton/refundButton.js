import { LightningElement, api, track, wire} from 'lwc';
import refundOrderApex from '@salesforce/apex/RefundButtonController.refundOrder';
import getCurrentStatus from '@salesforce/apex/RefundButtonController.getCurrentStatus';

export default class RefundButton extends LightningElement {
    @api orderId;
    @track showModal = false;
    @track isRefundDisabled;

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
                console.log(error);
                this.showModal = false;
            });
    }
}