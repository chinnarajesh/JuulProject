@IsTest(SeeAllData=false)
public class ZendeskToCaseServiceHelperTest {
    static testMethod void testReturnCase() {
         List<Zendesk__Zendesk_Ticket__c> tickList = new List<Zendesk__Zendesk_Ticket__c>();
       
            Zendesk__Zendesk_Ticket__c zt = new Zendesk__Zendesk_Ticket__c();
            zt.Request_Type__c = 'order_issue';
            zt.Order_Issue_Type__c = 'edit_order';
            zt.Edit_Order_Type__c = 'cancel_order';
            tickList.add(zt);
            insert tickList;
        Id recordTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
        String lang = 'en_US';
        String subject = 'Case Subject';
        String description = 'Case Description';
        String ticketType = 'Type 1';
        String priority = 'High';
        String orderNumber = '12345';
        Boolean noOrderNumber = false;
        String promoCode = 'Promo1';
        String returnPromoCode = 'Promo2';
        String topic = 'Topic 1';
        String issue = 'Issue 1';
        String action = 'Action 1';
        Id zdTicketId = zt.id;
        Boolean agreeToPP = true;
        String custFirstName = 'John';
        String custLastName = 'Doe';
        String custEmail = 'john.doe@example.com';
        String custPhone = '123-456-7890';

        Case testCase = ZendeskToCaseServiceHelper.returnCase(recordTypeId, lang, subject, description, ticketType, priority, 
                                                                orderNumber, noOrderNumber, promoCode, returnPromoCode, topic,
                                                                issue, action, zdTicketId, agreeToPP, custFirstName, custLastName, 
                                                                custEmail, custPhone);
       
    }

}