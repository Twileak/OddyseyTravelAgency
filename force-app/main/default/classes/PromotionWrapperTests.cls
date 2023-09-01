/**
 * Created by dawid.zamojda on 31.08.2023.
 */

@IsTest
public class PromotionWrapperTests {

    @IsTest
    static void testConstructor() {
        PromotionWrapper wrapper = new PromotionWrapper();

        System.assertEquals(new List<String>(), wrapper.listOfProducts);
        System.assertEquals(false, wrapper.isPeriodic);
        System.assertEquals(false, wrapper.isWeekly);
        System.assertEquals(new List<String>(), wrapper.weekdays);
        System.assertEquals(Date.newInstance(2023, 8, 24), wrapper.startDate);
        System.assertEquals(Date.newInstance(2023, 8, 24), wrapper.endDate);
        System.assertEquals(false, wrapper.isAbsolute);
        System.assertEquals(0, wrapper.promotionValue);
    }

    @IsTest
    static void testProperties() {
        PromotionWrapper wrapper = new PromotionWrapper();
        
        wrapper.listOfProducts.add('Product A');
        wrapper.isPeriodic = true;
        wrapper.isWeekly = true;
        wrapper.weekdays.add('Monday');
        wrapper.startDate = Date.newInstance(2023, 9, 1);
        wrapper.endDate = Date.newInstance(2023, 9, 15);
        wrapper.isAbsolute = true;
        wrapper.promotionValue = 10;

        System.assertEquals(new List<String>{'Product A'}, wrapper.listOfProducts);
        System.assertEquals(true, wrapper.isPeriodic);
        System.assertEquals(true, wrapper.isWeekly);
        System.assertEquals(new List<String>{'Monday'}, wrapper.weekdays);
        System.assertEquals(Date.newInstance(2023, 9, 1), wrapper.startDate);
        System.assertEquals(Date.newInstance(2023, 9, 15), wrapper.endDate);
        System.assertEquals(true, wrapper.isAbsolute);
        System.assertEquals(10, wrapper.promotionValue);
    }
}