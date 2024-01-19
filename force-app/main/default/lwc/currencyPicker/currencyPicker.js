import { LightningElement, track, wire, api} from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import updateCurrency from '@salesforce/apex/CurrencyPickerController.updateCurrency';
import getCurrentCurrency from '@salesforce/apex/CurrencyPickerController.selectCurrentCurrency';
import getSupportedCurrencies from '@salesforce/apex/CurrencyPickerController.getSupportedCurrencies';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import errorTitle from '@salesforce/label/c.Something_Wrong';
import PLN from '@salesforce/label/c.PLN';
import USD from '@salesforce/label/c.USD';


export default class CurrencyUpdateLWC extends LightningElement {
    @track selectedCurrency;
    currencyOptions = [];

    label = {
            errorTitle,
            PLN,
            USD
        }

    @wire(getSupportedCurrencies)
    wiredSupportedCurrencies({data, error}) {
        if(data) {
            this.currencyOptions = data.split(';').map((currency) => ({
                label: currency,
                value: currency
            }));
        } else if(error) {
            this.displayToast(this.label.errorTitle, JSON.stringify(error), "error");
        }
    }

    @wire(getCurrentCurrency)
    wiredReviews({error, data}) {
        if(data) {
            this.selectedCurrency = data;
        } else if(error) {

        }
    };

    async handleCurrencyChange(event) {
        this.selectedCurrency = event.detail.value;

        try{
            await updateCurrency({cur: this.selectedCurrency});
        } catch(error){
            this.displayToast(this.label.errorTitle, JSON.stringify(error), "error");
        }
        setTimeout(() => {
            location.reload();
        }, 500);
    }

    displayToast(title, message, variant) {
            const toast = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            });
            this.dispatchEvent(toast);
        }
}