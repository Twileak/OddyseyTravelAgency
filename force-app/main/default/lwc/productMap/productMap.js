import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import titleLabel from '@salesforce/label/c.Map_Title';
import citiesLabel from '@salesforce/label/c.Cities';

const fields = ['Product2.Coordinates__c', 'Product2.Cities__c'];

export default class ProductCoordinates extends LightningElement {
    @api recordId;
    mapMarkers = [];
    selectedMarkerValue;
    center;
    mapOptions = {
            disableDefaultUI: true,
        };
    label = {
            titleLabel,
            citiesLabel
        };

    @wire(getRecord, { recordId: '$recordId', fields })
    productRecord({ error, data }) {
        if (data) {
            this.parseCoordinates(data.fields);
        }
    }

    parseCoordinates(coordinatesData) {
        const coordinateEntries = coordinatesData.Coordinates__c.value.split('\n');
        const citiesEntries = coordinatesData.Cities__c.value.split(',')
        this.selectedMarkerValue = citiesEntries[0];
        this.center = citiesEntries[0];
        let tempMarkers = [];

        coordinateEntries.forEach(entry => {
            const city = citiesEntries.shift();
            const [latitude, longitude] = entry.split(',');
            let marker = {
                location: {
                        Street: ' ',
                        Latitude: latitude,
                        Longitude: longitude,
                            },
                value:city,
                title:city,
                description: ''
                };
            tempMarkers.push(marker);
        })
        this.mapMarkers = tempMarkers;
    }

    get isMapDataAvailable() {
        return this.mapMarkers.length > 0;
    }

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
    }
}