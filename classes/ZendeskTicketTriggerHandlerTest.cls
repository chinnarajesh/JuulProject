/*******************************************************************************************
* @Name         ZendeskTicketTriggerHandlerTest
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         10/30/2018
* @Group        Customer Service
* @Description  Test class for ZenDeskTicketTriggerHandler
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         10/30/2018          Initial Creation
*******************************************************************************************/
@isTest(seeAllData = false)
private class ZendeskTicketTriggerHandlerTest {

    /**************************************************************************************
     * @Description This method tests conditions: basic juul info & whats the nicotine content
     * @Param   --none--
     * @Return  --none--
     **************************************************************************************/
    static testMethod void testCondition01() {
        Test.startTest();
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //basic juul info & what's the nicotine content
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'basic_juul_info';
            zt.Basic_Juul_Info_Type__c = 'what_is_the_nicotine_content';
            tickList.add(zt);
        }
        insert tickList;
        Test.stopTest();
    }
    /**************************************************************************************
    * @Description This method tests conditions: basic juul info & what's the ingredients
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition02() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //basic juul info & what's the ingredients
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'basic_juul_info';
            zt.Basic_Juul_Info_Type__c = 'what_is_the_ingredients';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: basic juul info & What technology does Juul use?
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition03() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //basic juul info & What technology does Juul use?
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'basic_juul_info';
            zt.Basic_Juul_Info_Type__c = 'what_technology_does_juul_use';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: basic juul info & how do you use juul
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition04() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //basic juul info & how do you use juul
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'basic_juul_info';
            zt.Basic_Juul_Info_Type__c = 'how_do_you_use_juul';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition05() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & website promotions
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'promotions';
            zt.Promotions_Type__c = 'website_promotions';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition06() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'promotions';
            zt.Promotions_Type__c = 'retailer_promotions';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: wholesale inquiry
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition07() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //wholesale inquiry
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'wholesale_inquiry';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: affiliate inquiry
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition08() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //affiliate inquiry
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'affiliate_inquiry';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: survey question
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition09() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //survey question
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'survey_question';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: find a retailer
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition10() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //find a retailer
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'find_a_retailer';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: autoship & sign up for autoshipping
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition11() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //autoship & sign up for autoshipping
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'auto_ship';
            zt.Auto_Ship_Type__c = 'sign_up_for_auto-shipping';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: autoship & update address
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition12() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //autoship & update address
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'auto_ship';
            zt.Auto_Ship_Type__c = 'update_address';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
     * @Description This method tests conditions: autoship & update order
     * @Param   --none--
     * @Return  --none--
     **************************************************************************************/
    static testMethod void testCondition13() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //autoship & update order
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'auto_ship';
            zt.Auto_Ship_Type__c = 'update_order';
            tickList.add(zt);
        }
        insert tickList;
    }

    /**************************************************************************************
     * @Description This method tests conditions: autoship & auto-ship promotions
     * @Param   --none--
     * @Return  --none--
     **************************************************************************************/
    static testMethod void testCondition14() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //autoship & auto-ship promotions
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'auto_ship';
            zt.Auto_Ship_Type__c = 'auto-ship_promotions';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: autoship & change ship date
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition15() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //autoship & change ship date
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'auto_ship';
            zt.Auto_Ship_Type__c = 'change_ship_date';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: autoship & cancel auto shipping
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition16() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //autoship & cancel auto shipping
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'auto_ship';
            zt.Auto_Ship_Type__c = 'cancel_auto-shipping';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: age verification & upload issues
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition17() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //age verification & upload issues
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'age_verification';
            zt.Age_Verification_Type__c = 'upload_issues';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: age verification & 18+ questions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition18() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //age verification & 18+ questions
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'age_verification';
            zt.Age_Verification_Type__c = '18_questions';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: billing & questions about your bill
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition19() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //billing & questions about your bill
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'billing';
            zt.Billing_Type__c = 'questions_about_your_bill';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: billing & checkout trouble
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition20() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //billing & checkout trouble
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'billing';
            zt.Billing_Type__c = 'checkout_trouble';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: billing & coupon code issues
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition21() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //billing & coupon code issues
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'billing';
            zt.Billing_Type__c = 'coupon_code_issues';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: shipping & order delay
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition22() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //shipping & order delay
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'shipping';
            zt.Shipping_Type__c = 'order_delay';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: shipping & order not delivered
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition23() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //shipping & order not delivered
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'shipping';
            zt.Shipping_Type__c = 'order_not_delivered';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: edit order & change order
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition24() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //edit order & change order
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'edit_order';
            zt.Edit_Order_Type__c = 'change_order';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: edit order & change address
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition25() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //edit order & change address
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'edit_order';
            zt.Edit_Order_Type__c = 'change_address';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: edit order & return order
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition26() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //edit order & return order
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'edit_order';
            zt.Edit_Order_Type__c = 'return_order';
                    tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: edit order & cancel order
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition27() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //edit order & cancel order
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'edit_order';
            zt.Edit_Order_Type__c = 'cancel_order';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests exception
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition28() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //edit order & cancel order
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = new Zendesk__Zendesk_Ticket__c();
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'edit_order';
            zt.Edit_Order_Type__c = 'cancel_order';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: basic juul info & what's the ingredients
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition29() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //basic juul info & what's the ingredients
            zt.Request_Type__c = 'health_concern';
            //zt.General_Inquiry_Type__c = 'basic_juul_info';
            //zt.Basic_Juul_Info_Type__c = 'what_is_the_ingredients';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: autoship
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition30() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //autoship & update address
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'auto_ship';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: age verification & upload issues
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition31() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //age verification & upload issues
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'age_verification';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: billing & coupon code issues
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition32() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //billing & coupon code issues
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'billing';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: shipping & order delay
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition33() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //shipping & order delay
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'shipping';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: edit order & change order
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition34() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //edit order & change order
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'edit_order';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: edit order & change order
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition35() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        //edit order & change order
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: basic juul info & how do you use juul
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition36() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //basic juul info & how do you use juul
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'basic_juul_info';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition37() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'general_inquiry';
            zt.General_Inquiry_Type__c = 'promotions';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition38() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'general_inquiry';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition39() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition40() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_account';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition41() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_account';
            zt.App_Account_Type__c = 'log_in_trouble';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition42() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_account';
            zt.App_Account_Type__c = 'create_account';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition43() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_account';
            zt.App_Account_Type__c = 'upload_id_app';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition44() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_account';
            zt.App_Account_Type__c = 'av_failed_app';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition45() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition46() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            zt.App_Settings_Type__c = 'find_my_juul';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition47() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            zt.App_Settings_Type__c = 'lock_and_unlock';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition48() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            zt.App_Settings_Type__c = 'usage_tracking';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition49() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            zt.App_Settings_Type__c = 'getting_started';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition50() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            zt.App_Settings_Type__c = 'bluetooth_connection';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition51() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            zt.App_Settings_Type__c = 'device_pairing';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition52() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            zt.App_Settings_Type__c = 'phone_requirements';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition53() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'app_issue';
            zt.App_Issue_Type__c = 'app_settings';
            zt.App_Settings_Type__c = 'firmware_issue';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition54() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            //promotions & retailer promotions
            zt.Request_Type__c = 'device_issue';
            zt.Zendesk__Subject__c = 'Incoming Call';
            zt.Zendesk__Description__c = 'Incoming Call';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition55() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'i_have_an_account_question_or_issue';
            zt.Zendesk__Subject__c = 'Incoming Call';
            zt.Zendesk__Description__c = 'Incoming Call';
            zt.JUUL_Pass_Type__c = 'what_is_juul_pass';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition56() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'i_have_an_account_question_or_issue';
            zt.Zendesk__Subject__c = 'Incoming Call';
            zt.Zendesk__Description__c = 'Incoming Call';
            zt.JUUL_Pass_Type__c = 'how_do_i_enroll_unenroll';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition57() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'i_have_an_account_question_or_issue';
            zt.Zendesk__Subject__c = 'Incoming Call';
            zt.Zendesk__Description__c = 'Incoming Call';
            zt.JUUL_Pass_Type__c = 'what_is_loss_protection';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: promotions & website promotions
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition58() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'i_have_an_account_question_or_issue';
            zt.Zendesk__Subject__c = 'Incoming Call';
            zt.Zendesk__Description__c = 'Incoming Call';
            //zt.JUUL_Pass_Type__c = 'what_is_loss_protection';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests conditions: general inquiry about money back 
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testCondition59() {
        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i = 0; i < 2; i++) {
            Zendesk__Zendesk_Ticket__c zt = createCommonFields(i);
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'billing';
            zt.Billing_Type__c = 'general_question_money_back_guarantee';
            tickList.add(zt);
        }
        insert tickList;
    }
    /**************************************************************************************
    * @Description This method tests the case creation flow with an existing person account
    * @Param   --none--
    * @Return  --none--
    **************************************************************************************/
    static testMethod void testExistingCustAccount() {
        Account newAccountObj = new Account();
        newAccountObj.RecordTypeId = RecordTypeUtil.recordTypeId('Account','Person Account');
        newAccountObj.FirstName = 'James';
        newAccountObj.LastName = 'Conway';
        newAccountObj.PersonEmail = 'jamesconway@mailinator.com';
        newAccountObj.Phone = '1233438761';
        insert newAccountObj;

        List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
        for (Integer i=0;i<10;i++) {
            Zendesk__Zendesk_Ticket__c zt = new Zendesk__Zendesk_Ticket__c();
            zt.Zendesk_First_Name__c = 'James';
            zt.Zendesk_Last_Name__c = 'Conway';
            zt.Zendesk__RequesterEmailAddress__c = 'jamesconway@mailinator.com';
            zt.Phone_Number__c = '1233438761';
            zt.Zendesk__Brand__c = 'JUUL US';
            zt.Language_Preference__c = 'en-US';
            zt.Zendesk__Subject__c = 'Incoming Call';
            zt.Zendesk__Description__c = 'Incoming Call';
            zt.Zendesk__Type__c = 'Problem';
            zt.Zendesk__Priority__c = 'High';
            zt.Order_Number__c = '122287312';
            zt.Promotion_Code__c = '1221promo';
            zt.Retailer_Promotion_Code__c = '1232121retprom';
            zt.Request_Type__c = 'Order Issue';
            zt.Order_Issue_Type__c = 'Edit Order';
            zt.Edit_Order_Type__c = 'Cancel Order';
            tickList.add(zt);
        }
        insert tickList;
    }

    /**************************************************************************************
     * @Description This method creates data about the customer
     * @Param   --none--
     * @Return  --none--
     **************************************************************************************/
    static Zendesk__Zendesk_Ticket__c createCommonFields(Integer cnt) {
        Zendesk__Zendesk_Ticket__c zt = new Zendesk__Zendesk_Ticket__c();
        zt.Zendesk_First_Name__c = 'Bruce' + cnt;
        zt.Zendesk_Last_Name__c = 'Wayne' + cnt;
        zt.Zendesk__RequesterEmailAddress__c = 'brucewayne' + cnt + '@mailinator.com';
        zt.Phone_Number__c = '908969969' + cnt;
        zt.Zendesk__Brand__c = 'JUUL US';
        zt.Language_Preference__c = 'en-US';
        zt.Zendesk__Subject__c = 'zendesk subject';
        zt.Zendesk__Description__c = 'zendesk description';
        zt.Zendesk__Type__c = 'Problem';
        zt.Zendesk__Priority__c = 'High';
        zt.Order_Number__c = '122287312';
        zt.Promotion_Code__c = '1221promo';
        zt.Retailer_Promotion_Code__c = '1232121retprom';
        zt.Agree_to_Privacy_Policy__c = true;
        return zt;
    }
}