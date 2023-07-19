/**
 * Created by dawid.zamojda on 11.07.2023.
 */

public with sharing class ProductWrapper {
    public String name {get;set;}
    public String accommodation {get; set;}
    public List<String> cities {get;set;}
    public String continent {get;set;}
    public Integer currentMembers {get;set;}
    public Integer duration {get;set;}
    public Date startDate {get;set;}
    public Date endDate {get;set;}
    public Boolean isAllInclusive {get;set;}
    public Integer memberLimit {get;set;}
    public String productDescription {get;set;}
    public String summary {get;set;}
    public String transportation {get;set;}

    public ProductWrapper(){
        this.name = '';
        this.accommodation = '';
        this.cities = new List<String>();
        this.continent = '';
        this.currentMembers = 0;
        this.duration = 0;
        this.startDate = null;
        this.endDate = null;
        this.isAllInclusive = false;
        this.memberLimit = 0;
        this.productDescription = '';
        this.summary = '';
        this.transportation = '';
    }

    public ProductWrapper(Product2 product){
        this.name = product.Name;
        this.accommodation = product.Accommodation__c;
        this.cities = product.Cities__c.split(',');
        this.continent = product.Continent__c;
        this.currentMembers = (Integer) product.Current_Members__c;
        this.duration = (Integer) product.Duration__c;
        this.startDate = product.Start_Date__c;
        this.endDate = product.End_Date__c;
        this.isAllInclusive = product.Is_All_Inclusive__c;
        this.memberLimit = (Integer) product.Member_Limit__c;
        this.productDescription = product.Description;
        this.summary = product.Summary__c;
        this.transportation = product.Transportation__c;
    }
}