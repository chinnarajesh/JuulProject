/*******************************************************************************************
* @Name         ZendeskToCaseService
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         03/12/2019
* @Group        Customer Service
* @Description  Service for handling Zendesk to Case creation
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         03/12/2019          Initial Creation
*******************************************************************************************/
public with sharing class ZendeskToCaseService {

    /*******************************************************************************************************************
     * @Description This method returns a map of zendesk customer email to salesforce person account record id
     * @Param   List<Zendesk__Zendesk_Ticket__c>
     * @Return  void
    ******************************************************************************************************************/
    public static void insertCase(List<Zendesk__Zendesk_Ticket__c> zendeskTicketList) {
        Map<Id, Case> mapOfZDTicketToCase = new Map<Id, Case>();
        //loop through all new zendesk tickets and insert cases
        for (Zendesk__Zendesk_Ticket__c zt : zendeskTicketList) {
            Case newCase = new Case();
            System.debug('about to create a case here--> ' + JSON.serialize(zt));
            Id caseRecTypeId;
            System.debug('Request Type--> ' + zt.Request_Type__c);
            switch on zt.Request_Type__c {
                when 'order_issue' {
                    System.debug('Order Issue Type--> ' + zt.Order_Issue_Type__c);
                    switch on zt.Order_Issue_Type__c {
                        when 'auto_ship' {
                            System.debug('Auto Ship Type--> ' + zt.Auto_Ship_Type__c);
                            switch on zt.Auto_Ship_Type__c {
                                when 'sign_up_for_auto-shipping' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Auto-Ship',
                                            'Signing-Up', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'update_address' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Auto-Ship',
                                            'Change Request', 'Address', zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'update_order' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Shipping',
                                            'Change Items in Order', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'auto-ship_promotions' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Auto-Ship',
                                            'Device Promotion', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'change_ship_date' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Auto-Ship',
                                            'Change Request', 'Date', zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'cancel_auto-shipping' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Auto-Ship',
                                            'Cancellation Request', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when 'age_verification' {
                            System.debug('Age Verification Type--> ' + zt.Age_Verification_Type__c);
                            switch on zt.Age_Verification_Type__c {
                                when 'upload_issues' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Age Verification',
                                            'Upload Failed', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when '18_questions' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Age Verification',
                                            'Verification Pending', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when 'billing' {
                            System.debug('Billing Type--> ' + zt.Billing_Type__c);
                            switch on zt.Billing_Type__c {
                                when 'questions_about_your_bill' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Billing',
                                            'Incorrect charge', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'checkout_trouble' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Billing',
                                            'Checkout Trouble', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'coupon_code_issues' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId, zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Billing',
                                            'Incorrect charge', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'general_question_money_back_guarantee' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId, zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Money Back Guarantee',
                                            'Information Request', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when 'shipping' {
                            System.debug('Shipping Type--> ' + zt.Shipping_Type__c);
                            switch on zt.Shipping_Type__c {
                                when 'order_delay' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Shipping',
                                            'Shipment Status', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'order_not_delivered' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Shipping',
                                            'Missing Package', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when 'edit_order' {
                            System.debug('Edit order Type--> ' + zt.Edit_Order_Type__c);
                            switch on zt.Edit_Order_Type__c {
                                when 'change_order' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Shipping',
                                            'Change Items in Order', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'change_address' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Shipping',
                                            'Change an Address', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'return_order' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Returns',
                                            'Return for Refund', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'cancel_order' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Shipping',
                                            'Cancel an Order', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when else {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                    null, zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                    }
                }
                when 'general_inquiry' {
                    System.debug('General Inquiry Type--> ' + zt.General_Inquiry_Type__c);
                    switch on zt.General_Inquiry_Type__c {
                        when 'basic_juul_info' {
                            System.debug('Basic JUUL Info Type--> ' + zt.Basic_Juul_Info_Type__c);
                            switch on zt.Basic_Juul_Info_Type__c {
                                when 'what_is_the_nicotine_content' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Basic Info',
                                            'Nicotine Qs', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'what_is_the_ingredients' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Basic Info',
                                            'Ingredient Qs', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'what_technology_does_juul_use' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Basic Info',
                                            'JUUL Device Technology', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'how_do_you_use_juul' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Basic Info',
                                            'Device Education', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when 'promotions' {
                            System.debug('Promotions Type--> ' + zt.Promotions_Type__c);
                            switch on zt.Promotions_Type__c {
                                when 'website_promotions' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, null, 'Promotions', 'Promotion validation - Website',
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'retailer_promotions' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            null, zt.Retailer_Promotion_Code__c, 'Promotions',
                                            'Promotion Validation - Retail', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when 'wholesale_inquiry' {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Wholesale Inquiry',
                                    'Application Followup', null, zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                        when 'affiliate_inquiry' {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Affiliate Inquiry',
                                    'Application Followup', null, zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                        when 'find_a_retailer' {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Store Locator',
                                    'Update Request: Customer', null, zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                        when 'survey_question' {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Survey Inquiry', null,
                                    null,  zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                        when else {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                    null,  zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                    }
                }
                when 'health_concern' {
                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Product Troubleshooting & Warranty Fulfillment');
                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                            zt.Language_Preference__c,
                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                            zt.Order_Number__c, zt.No_Order_Number__c,
                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                            'Health Experience Created, No Replacement Sent', zt.Id,
                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                            zt.Phone_Number__c);
                }
                when 'app_issue' {
                    switch on zt.App_Issue_Type__c {
                        when 'app_account' {
                            switch on zt.App_Account_Type__c {
                                when 'log_in_trouble' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Account Management',
                                            'Unable to log-in', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'create_account' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Account Management',
                                            'Create account', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'upload_id_app' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'In App Age Verification',
                                            'Upload Failed', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'av_failed_app' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'In App Age Verification',
                                            'AV Failed', null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when 'app_settings' {
                            switch on zt.App_Settings_Type__c {
                                when 'find_my_juul' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Find my JUUL', null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'lock_and_unlock' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Locking', null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'usage_tracking' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Usage Tracking', null,
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'getting_started' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c,
                                            'Device pairing and connectivity', null, null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'bluetooth_connection' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c,
                                            'Device pairing and connectivity', 'Connectivity issue',
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'device_pairing' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c,
                                            'Device pairing and connectivity', null, null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'firmware_issue' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c,
                                            'Firmware update', null, null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when 'phone_requirements' {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c,
                                            'Device pairing and connectivity', 'Connectivity issue',
                                            null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                                when else {
                                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                            zt.Language_Preference__c,
                                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                            zt.Order_Number__c, zt.No_Order_Number__c,
                                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c,
                                            null, null, null, zt.Id,
                                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                            zt.Phone_Number__c);
                                }
                            }
                        }
                        when else {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c,
                                    null, null, null, zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                    }
                }
                when 'device_issue' {
                    caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Product Troubleshooting & Warranty Fulfillment');
                    newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,  zt.Language_Preference__c,
                            zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                            zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                            zt.Order_Number__c, zt.No_Order_Number__c,
                            zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, null, null,
                            null, zt.Id,
                            zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                            zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                            zt.Phone_Number__c);
                }
                when 'i_have_an_account_question_or_issue' {
                    System.debug('JUUL Pass Type-> ' + zt.JUUL_Pass_Type__c);
                    switch on zt.JUUL_Pass_Type__c {
                        when 'what_is_juul_pass' {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Membership',
                                    'Signing Up', 'How does it work?', zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                        when 'how_do_i_enroll_unenroll' {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Membership',
                                    'Signing Up', 'CM education', zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                        when 'what_is_loss_protection' {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Product Registration',
                                    'Lost Device', null, zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                        when else {
                            caseRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                            newCase = ZendeskToCaseServiceHelper.returnCase(caseRecTypeId,
                                    zt.Language_Preference__c,
                                    zt.Zendesk__Subject__c, zt.Zendesk__Description__c,
                                    zt.Zendesk__Type__c, zt.Zendesk__Priority__c,
                                    zt.Order_Number__c, zt.No_Order_Number__c,
                                    zt.Promotion_Code__c, zt.Retailer_Promotion_Code__c, 'Membership', null,
                                    null, zt.Id,
                                    zt.Agree_to_Privacy_Policy__c, zt.Zendesk_First_Name__c,
                                    zt.Zendesk_Last_Name__c, zt.Zendesk__RequesterEmailAddress__c,
                                    zt.Phone_Number__c);
                        }
                    }
                }
            }
            mapOfZDTicketToCase.put(zt.Id, newCase); //add to map for insertion outside loop
        }
        if (!mapOfZDTicketToCase.isEmpty()) {
            System.debug('cases list from zd--> ' + mapOfZDTicketToCase.values());
            List<Database.UpsertResult> upsertResult = Database.upsert(mapOfZDTicketToCase.values(), false);
            for (Database.UpsertResult sr : upsertResult) {
                if (sr.getErrors().size() > 0) {
                    for (Database.Error err : sr.getErrors()) {
                        throw new ZendeskToCaseServiceException('Failed to upsert the case. Error Message: ' + err.getMessage());
                    }
                }
            }
            //get a set of zendesk ticket ids
            Set<Id> zdTicketIdSet = new Set<Id>();
            for (Zendesk__Zendesk_Ticket__c zt : zendeskTicketList) {
                zdTicketIdSet.add(zt.Id);
            }
            //pass the tickets to a future method which updates the cases
            if (!zdTicketIdSet.isEmpty()) {
                updateZdTickets(zdTicketIdSet);
            }
        }
    }

    @Future
    public static void updateZdTickets(Set<Id> zdTicketIdSet) {
        //get case IDs using zendesk tickets
        List<Case> caseList = [
                SELECT Id,Related_Zendesk_Ticket__c
                FROM Case
                WHERE Related_Zendesk_Ticket__c = :zdTicketIdSet
        ];
        //build a map of zd ticket id to case id
        Map<Id, Id> zdTicketIdToCaseIdMap = new Map<Id, Id>();
        if (!caseList.isEmpty()) {
            for (Case c : caseList) {
                if (String.isNotBlank(c.Related_Zendesk_Ticket__c) && String.isNotBlank(c.Id)) {
                    zdTicketIdToCaseIdMap.put(c.Related_Zendesk_Ticket__c, c.Id);
                }
            }
        }
        //get the zendesk tickets to update
        if (!zdTicketIdToCaseIdMap.isEmpty()) {
            List<Zendesk__Zendesk_Ticket__c> zdTicketList = [
                    SELECT Id
                    FROM Zendesk__Zendesk_Ticket__c
                    WHERE Id = :zdTicketIdSet
            ];
            for (Zendesk__Zendesk_Ticket__c zd : zdTicketList) {
                if (zdTicketIdToCaseIdMap.containsKey(zd.Id)) {
                    zd.Related_Case__c = zdTicketIdToCaseIdMap.get(zd.Id);
                }
            }
            Database.update(zdTicketList, false);
        }
    }

    public class ZendeskToCaseServiceException extends Exception {
    }
}