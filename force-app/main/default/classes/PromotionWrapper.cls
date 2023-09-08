/**
 * Created by dawid.zamojda on 24.08.2023.
 */

public with sharing class PromotionWrapper {
    public List<String> listOfProducts {get; set;}
    public Boolean isPeriodic {get; set;}
    public Boolean isWeekly {get; set;}
    public List<String> weekdays {get; set;}
    public Date startDate {get; set;}
    public Date endDate {get; set;}
    public Boolean isAbsolute {get; set;}
    public Decimal promotionValue {get; set;}

    public PromotionWrapper(){
        this.listOfProducts = new List<String>();
        this.isPeriodic = false;
        this.isWeekly = false;
        this.weekdays = new List<String>();
        this.startDate = Date.newInstance(2023, 8, 24);
        this.endDate = Date.newInstance(2023, 8, 24);
        this.isAbsolute = false;
        this.promotionValue = 0;
    }
}