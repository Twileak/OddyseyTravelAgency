import { LightningElement, api } from 'lwc';
import TEMPORARY from '@salesforce/resourceUrl/OddyseyLogo';

export default class tripCard extends LightningElement {
    @api product;
    @api selectedProduct;
    temporaryPick = TEMPORARY;

    get tileBackground(){
        return 'background-image:url('+TEMPORARY+')';
    }

    selectProduct(){
        const selected = this.product.Id;

        const event = new CustomEvent('tileclick', {
            detail:{value:selected}
        });
        this.dispatchEvent(event);
    }
}