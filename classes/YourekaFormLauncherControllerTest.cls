@isTest
private class YourekaFormLauncherControllerTest {
    private static List<Account> accounts = new List<Account>();

    @isTest
    private static void testGetRecord() {
        setup();

        YourekaFormLauncherController.ObjectWrapper objectWrapper =
            YourekaFormLauncherController.getRecord(accounts[0].Id, 'AccountNumber');
        Account account = (Account)objectWrapper.record;
        System.assertEquals('Account', objectWrapper.sObjectName);
        System.assertEquals('1234', account.AccountNumber);
    }

    @isTest
    private static void testGetRecordNoTitle() {
        setup();

        YourekaFormLauncherController.ObjectWrapper objectWrapper =
            YourekaFormLauncherController.getRecord(accounts[0].Id, null);
        Account account = (Account)objectWrapper.record;
        System.assertEquals('Account', objectWrapper.sObjectName);
        try {
            String accountNumber = account.AccountNumber;
        } catch (Exception ex) {
            String exceptionMessage = 'SObject row was retrieved via SOQL without querying';
            exceptionMessage += ' the requested field: Account.AccountNumber';
            System.assertEquals(exceptionMessage, ex.getMessage());
        }
    }

    @isTest
    private static void testGetUITheme() {
        System.assertEquals('Theme3', YourekaFormLauncherController.getUITheme());
    }

    private static void setup() {
        Account account1 = new Account(
            Name = 'Test Account',
            AccountNumber = '1234'
        );

        accounts.add(account1);
        insert accounts;
    }
}