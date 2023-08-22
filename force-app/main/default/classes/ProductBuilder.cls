/**
 * Created by dawid.zamojda on 22.08.2023.
 */

public with sharing class ProductBuilder {
    private String accommodation;
    private String cities;
    private String continent;
    private Integer currentMembers;
    private Date startDate;
    private Date endDate;
    private Boolean isAllInclusive;
    private Integer memberLimit;
    private String transportation;
    private String name;
    private String summary;

    public ProductBuilder() {}
    public ProductBuilder setTransportation(String transportation) {
        this.transportation = transportation;
        return this;
    }
    public ProductBuilder setMemberLimit(Integer memberLimit) {
        this.memberLimit = memberLimit;
        return this;
    }
    public ProductBuilder setIsAllInclusive(Boolean isAllInclusive) {
        this.isAllInclusive = isAllInclusive;
        return this;
    }
    public ProductBuilder setEndDate(Date endDate) {
        this.endDate = endDate;
        return this;
    }
    public ProductBuilder setStartDate(Date startDate) {
        this.startDate = startDate;
        return this;
    }
    public ProductBuilder setAccommodation(String accommodation) {
        this.accommodation = accommodation;
        return this;
    }
    public ProductBuilder setCities(String cities) {
        this.cities = cities;
        return this;
    }
    public ProductBuilder setContinent(String continent) {
        this.continent = continent;
        return this;
    }
    public ProductBuilder setCurrentMembers(Integer currentMembers) {
        this.currentMembers = currentMembers;
        return this;
    }
    public ProductBuilder setName(String name) {
        this.name = name;
        return this;
    }
    public ProductBuilder setSummary(String summary) {
        this.summary = summary;
        return this;
    }
    public Product2 build() {
        Product2 product = new Product2();
        product.Name = name;
        product.Accommodation__c = accommodation;
        product.Cities__c = cities;
        product.Continent__c = continent;
        product.Current_Members__c = currentMembers;
        product.Start_Date__c = startDate;
        product.End_Date__c = endDate;
        product.Is_All_Inclusive__c = isAllInclusive;
        product.Member_Limit__c = memberLimit;
        product.Transportation__c = transportation;
        product.Summary__c = summary;

        return product;
    }
}