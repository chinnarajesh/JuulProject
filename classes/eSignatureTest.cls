@isTest
public class eSignatureTest {
    @IsTest
    static void testOTPMatch() {
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        eSignature tmp = new eSignature(sc);
        //system.assert(tmp.username != null, 'unexpected username');
        //system.assert(tmp.password == null, 'unexpected password');
        tmp.comment = 'the case comment to store in the new record';
        tmp.otp = 12345;
        tmp.oneTimePass = 12345;
        //tmp.password = 'incorrect_password';
        //Test.setMock(HttpCalloutMock.class, new CalloutMockImpl_ok());
        tmp.sendOTP();
        tmp.doVerify();
        Test.stopTest();
    }

//    static testMethod void testMethod2() {
//        Test.startTest();
//        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
//        eSignature tmp = new eSignature(sc);
//        system.assert(tmp.username != null, 'unexpected username');
//        //system.assert(tmp.password == null, 'unexpected password');
//        tmp.comment = 'the case comment to store in the new record';
//        //tmp.password = 'incorrect_password';
//
//        Test.setMock(HttpCalloutMock.class, new CalloutMockImpl_fail());
//
//        tmp.doVerify();
//
//        Test.stopTest();
//    }
//    @IsTest
//    static void test_XDSR_verify() {
//        Test.startTest();
//        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
//        eSignature tmp = new eSignature(sc);
//        tmp.eSigType = 'XDSR';
//        system.assert(tmp.username != null, 'unexpected username');
//        //system.assert(tmp.password == null, 'unexpected password');
//        tmp.comment = 'the case comment to store in the new record';
//        //tmp.password = 'incorrect_password';
//
//        //Test.setMock(HttpCalloutMock.class, new CalloutMockImpl_fail());
//
//        tmp.doVerify();
//
//        Test.stopTest();
//    }

    @IsTest
    static void testMethod3() {
        Case ca = New Case(Description = 'description', Case_Region__c = null, SuppliedName = 'James Conway',
                SuppliedEmail = 'jamesconway0@mailinator.com');
        insert ca;

        ApexPages.StandardController sc = new ApexPages.StandardController(ca);
        eSignature tmp = new eSignature(sc);
        Test.startTest();
        system.assert(!tmp.isAlreadySigned, 'expected not yet signed');
        insert new eSignature__c(
                Case__c = ca.Id,
                Comment__c = 'comment'
        );
        system.assert(tmp.isAlreadySigned, 'expected  signed');
    }

//    @IsTest
//    static void test_XDSR() {
//        XDSR__c ca = New XDSR__c();
//        insert ca;
//
//        ApexPages.StandardController sc = new ApexPages.StandardController(ca);
//        eSignature tmp = new eSignature(sc);
//        tmp.eSigType = 'XDSR';
//        Test.startTest();
//        system.assert(!tmp.isAlreadySigned, 'expected not yet signed');
//        insert new eSignature__c(
//                XDSR__c = ca.Id,
//                Comment__c = 'comment'
//        );
//        system.assert(tmp.isAlreadySigned, 'expected  signed');
//    }

//    public class CalloutMockImpl_fail implements HttpCalloutMock {
//        public HTTPResponse respond(HTTPRequest req) {
//            System.assertEquals('POST', req.getMethod());
//            // Create a fake response, this case is an invalid response
//            HttpResponse res = new HttpResponse();
//            res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
//            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>sf:INVALID_LOGIN</faultcode><faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring><detail><sf:LoginFault xsi:type="sf:LoginFault"><sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode><sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage></sf:LoginFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>');
//            res.setStatusCode(500);
//            return res;
//        }
//    }
//    public class CalloutMockImpl_ok implements HttpCalloutMock {
//        public HTTPResponse respond(HTTPRequest req) {
//            System.assertEquals('POST', req.getMethod());
//            // Create a fake response, this case is an invalid response
//            HttpResponse res = new HttpResponse();
//            res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
//            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><loginResponse><result><metadataServerUrl>https://jayson-k-dev-ed.my.salesforce.com/services/Soap/m/40.0/00D460000017Wny</metadataServerUrl><passwordExpired>false</passwordExpired><sandbox>false</sandbox><serverUrl>https://jayson-k-dev-ed.my.salesforce.com/services/Soap/u/40.0/00D460000017Wny</serverUrl><sessionId>SESSION_ID_REMOVED</sessionId><userId>005460000013ZSyAAM</userId><userInfo><accessibilityMode>false</accessibilityMode><chatterExternal>false</chatterExternal><currencySymbol>$</currencySymbol><orgAttachmentFileSizeLimit>5242880</orgAttachmentFileSizeLimit><orgDefaultCurrencyIsoCode>USD</orgDefaultCurrencyIsoCode><orgDefaultCurrencyLocale>en_US</orgDefaultCurrencyLocale><orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments><orgHasPersonAccounts>false</orgHasPersonAccounts><organizationId>00D460000017WnyEAE</organizationId><organizationMultiCurrency>false</organizationMultiCurrency><organizationName>Propel Jayson</organizationName><profileId>00e46000001PLkaAAG</profileId><roleId xsi:nil="true"/><sessionSecondsValid>7200</sessionSecondsValid><userDefaultCurrencyIsoCode xsi:nil="true"/><userEmail>ron@propelplm.com</userEmail><userFullName>Ron Hess</userFullName><userId>005460000013ZSyAAM</userId><userLanguage>en_US</userLanguage><userLocale>en_US</userLocale><userName>ron@20170413.dev</userName><userTimeZone>America/Los_Angeles</userTimeZone><userType>Standard</userType><userUiSkin>Theme3</userUiSkin></userInfo></result></loginResponse></soapenv:Body></soapenv:Envelope>');
//            res.setStatusCode(500);
//            return res;
//        }
//    }
}