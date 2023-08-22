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
    private Integer duration;

    public ProductBuilder() {
        this.accommodation = 'Hotel';
        this.cities = 'Bialystok,Warszawa';
        this.continent = 'Europe';
        this.currentMembers = 0;
        this.startDate = Date.newInstance(2023, 8, 1);
        this.endDate = Date.newInstance(2023, 8, 5);
        this.isAllInclusive = false;
        this.memberLimit = 10;
        this.transportation = 'Bus';
        this.name = 'Test trip';
        this.summary = 'Test summary';
        this.duration = 4;
    }

    public ProductBuilder setDuration(Integer duration){
        this.duration = duration;
        return this;
    }
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
        return new Product2(
                Name = this.name,
                Accommodation__c = this.accommodation,
                Cities__c = this.cities,
                Continent__c = this.continent,
                Current_Members__c = this.currentMembers,
                Start_Date__c = this.startDate,
                End_Date__c = this.endDate,
                Is_All_Inclusive__c = this.isAllInclusive,
                Member_Limit__c = this.memberLimit,
                Transportation__c = this.transportation,
                Summary__c = this.summary,
                Duration__c = this.duration
        );
    }
}