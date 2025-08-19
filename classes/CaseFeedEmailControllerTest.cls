@isTest
private class CaseFeedEmailControllerTest {
    private testMethod static void testMe(){
        CaseFeedEmailController con = new CaseFeedEmailController (new ApexPages.StandardController(new Case()));
        con.emailAddressList  = 'l.....;';
        
    }
}