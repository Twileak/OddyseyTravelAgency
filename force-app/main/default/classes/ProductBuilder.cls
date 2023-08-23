/**
 * Created by dawid.zamojda on 22.08.2023.
 */

public with sharing class ProductBuilder {
    private Product2 product;

    public ProductBuilder() {
        product = new Product2(
                Name = 'Test Name',
                Member_Limit__c = 10);
    }

    public ProductBuilder setDuration(Integer duration){
        product.Duration__c = duration;
        return this;
    }
    public ProductBuilder setTransportation(String transportation) {
        product.Transportation__c = transportation;
        return this;
    }
    public ProductBuilder setMemberLimit(Integer memberLimit) {
        product.Member_Limit__c = memberLimit;
        return this;
    }
    public ProductBuilder setIsAllInclusive(Boolean isAllInclusive) {
        product.Is_All_Inclusive__c = isAllInclusive;
        return this;
    }
    public ProductBuilder setEndDate(Date endDate) {
        product.End_Date__c = endDate;
        return this;
    }
    public ProductBuilder setStartDate(Date startDate) {
        product.Start_Date__c = startDate;
        return this;
    }
    public ProductBuilder setAccommodation(String accommodation) {
        product.Accommodation__c = accommodation;
        return this;
    }
    public ProductBuilder setCities(String cities) {
        product.Cities__c = cities;
        return this;
    }
    public ProductBuilder setContinent(String continent) {
        product.Continent__c = continent;
        return this;
    }
    public ProductBuilder setCurrentMembers(Integer currentMembers) {
        product.Current_Members__c = currentMembers;
        return this;
    }
    public ProductBuilder setName(String name) {
        product.Name = name;
        return this;
    }
    public ProductBuilder setSummary(String summary) {
        product.Summary__c = summary;
        return this;
    }
    public Product2 build() {
        return product;
    }

    public Product2 buildAndSave() {
        insert product;
        return product;
    }
}