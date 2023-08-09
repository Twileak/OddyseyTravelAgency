import { LightningElement, api } from 'lwc';

export default class RatingStars extends LightningElement {
    @api rating;

    get stars() {
        const stars = [];
        for (let i = 5; i >= 1; i--) {
            stars.push({
                value: i,
                class: i <= this.rating ? 'golden-star' : 'grey-star'
            });
        }
        return stars;
    }
}