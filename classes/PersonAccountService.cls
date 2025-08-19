/*******************************************************************************************
* @Name         PersonAccountService
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         04/22/2019
* @Group        Customer Service
* @Description  This class processes incoming data to create/update person accounts
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         04/22/2019          Initial Creation
*******************************************************************************************/
public without sharing class PersonAccountService {
    /**************************************************************************************
     * @Description this method attaches person accounts with incoming cases based on email
     * @Param   List<Case>
     * @Return  N/A
     **************************************************************************************/
    public static void attachPersonAccountWithCase(List<Case> caseList) {
        try {
            if (!caseList.isEmpty()) {
                //get all record type IDs currently in use
                Id genInqRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                Id ecommerceRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                Id warrantyRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Product Troubleshooting & Warranty Fulfillment');
                Id appTroubleRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                Id healthExpRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Health Experience');
                
				//Added for new Juul2 and added the record type condition in the check.
				Id Juul2appTroubleRecTypeId = RecordTypeUtil.recordTypeId('Case', 'JUUL2 App Pairing & Connectivity');
				//End for new Juul2
                List<Case> casesToUpdate = new List<Case>();
                System.debug('caseList line 29-> '+caseList);
                for (Case c : caseList) {
                    System.debug('c.Recordtypeid-> '+c.RecordTypeId);
                    if (c.RecordTypeId == genInqRecTypeId || c.RecordTypeId == ecommerceRecTypeId ||
                            c.RecordTypeId == warrantyRecTypeId || c.RecordTypeId == appTroubleRecTypeId
                            || c.RecordTypeId == healthExpRecTypeId || c.RecordTypeId == Juul2appTroubleRecTypeId) {
                        System.debug('case line 34-> '+c);
                        casesToUpdate.add(c);
                    }
                }
                System.debug('casesToUpdate line 36-> '+casesToUpdate);
                if (!casesToUpdate.isEmpty()) {
                    //filter cases by the ones which have SuppliedEmail value on them
                    Set<Id> casesWithSuppEmailSet = new Set<Id>();
                    for (Case c : casesToUpdate) {
                        if (String.isNotBlank(c.SuppliedEmail)) {
                            casesWithSuppEmailSet.add(c.Id);
                        }
                    }
                    if (!casesWithSuppEmailSet.isEmpty()) {
                        //upsert person account and attach to the case in a separate transaction
                        upsertPersonAccountsUsingCasesWithSuppEmail(casesWithSuppEmailSet);
                    }

                }
            }
        } catch (Exception e) {
            System.debug('Exception--> ' + e.getMessage());
            EventLogger.log(e);
            if (!Test.isRunningTest()) throw e;
        }
    }

    /**************************************************************************************
     * @Description this method attaches the person account's contact on the case
     * @Param   List<Case>
     * @Return  N/A
    **************************************************************************************/
    public static void attachContactWithCase(List<Case> caseList) {
        if (!caseList.isEmpty()) {
            try {
                Id genInqRecTypeId = RecordTypeUtil.recordTypeId('Case', 'General Inquiry');
                Id ecommerceRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Ecommerce Account');
                Id warrantyRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Product Troubleshooting & Warranty Fulfillment');
                Id appTroubleRecTypeId = RecordTypeUtil.recordTypeId('Case', 'App Troubleshooting');
                Id healthExpRecTypeId = RecordTypeUtil.recordTypeId('Case', 'Health Experience');
				
				//Added for new Juul2 and added the record type condition in the check.
				Id Juul2appTroubleRecTypeId = RecordTypeUtil.recordTypeId('Case', 'JUUL2 App Pairing & Connectivity');
				//End for new Juul2
                Set<Id> accountIdSet = new Set<Id>();
                for (Case c : caseList) {
                    if (c.AccountId != null && (c.RecordTypeId == genInqRecTypeId || c.RecordTypeId == ecommerceRecTypeId || c.RecordTypeId == warrantyRecTypeId || c.RecordTypeId == appTroubleRecTypeId
                            || c.RecordTypeId == healthExpRecTypeId || c.RecordTypeId == Juul2appTroubleRecTypeId)) {
                        accountIdSet.add(c.AccountId);
                    }
                }
                if (!accountIdSet.isEmpty()) {
                    Map<Id, Account> accIdMap = new Map<Id, Account>([
                            SELECT PersonContactId, Email_UID__c, FirstName,
                                    LastName, Phone
                            FROM Account
                            WHERE IsPersonAccount = true
                            AND Id = :accountIdSet
                    ]);
                    if (!accIdMap.isEmpty()) {
                        for (Case c : caseList) {
                            if (c.AccountId != null && accIdMap.containsKey(c.AccountId)) {
                                c.ContactId = accIdMap.get(c.AccountId).PersonContactId;
                                c.SuppliedEmail = accIdMap.get(c.AccountId).Email_UID__c;
                                c.SuppliedName = accIdMap.get(c.AccountId).LastName;
                                c.Web_Last_Name__c = accIdMap.get(c.AccountId).LastName;
                                c.Web_First_Name__c = accIdMap.get(c.AccountId).FirstName;
                                c.SuppliedPhone = accIdMap.get(c.AccountId).Phone;
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.debug('Exception--> ' + e.getMessage());
                EventLogger.log(e);
                if (!Test.isRunningTest()) throw e;
            }
        }
    }

    /**************************************************************************************
     * @Description this method creates/updates person accounts from a case list based on
     *              the customer's email
     * @Param   List<String>
     * @Return  N/A
     **************************************************************************************/
    @Future
    public static void upsertPersonAccountsUsingCasesWithSuppEmail(Set<Id> caseIds) {
        if (!caseIds.isEmpty()) {
            List<String> newCustEmails = new List<String>(); //to fetch new person accounts by email
            String emailLowerCase;
            Map<String, Account> mapOfEmailToAccObj = new Map<String, Account>();
            Id persAccRecTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
            Map<String, Account> mapOfCustEmailToAcc = new Map<String, Account>();//email key to account object map
            List<Case> casesToUpdate = new List<Case>();
            casesToUpdate = [
                    SELECT Id,SuppliedEmail,Web_Last_Name__c,Web_First_Name__c,SuppliedName,
                            SuppliedPhone,Market__c,AccountId
                    FROM Case
                    WHERE Id = :caseIds
            ];
            System.debug('casesToUpdate-> ' + casesToUpdate);
            if (!casesToUpdate.isEmpty()) {
                for (Case c : casesToUpdate) {
                    if (String.isNotBlank(c.SuppliedEmail)) {
                        emailLowerCase = c.SuppliedEmail.trim().toLowerCase();
                    }
                    if (String.isNotBlank(emailLowerCase)) {
                        Account newAccountObj = new Account(); //new account object
                        newAccountObj.RecordTypeId = persAccRecTypeId; //set the account record type
                        //set the name of the account
                        if (String.isNotBlank(c.Web_Last_Name__c)) {
                            newAccountObj.FirstName = c.Web_First_Name__c;
                            newAccountObj.LastName = c.Web_Last_Name__c;
                        } else if (String.isNotBlank(c.SuppliedName)) {
                            String delimiter = ' ';
                            if (c.SuppliedName.containsAny(delimiter)) {
                                String firstName = c.SuppliedName.substringBefore(delimiter);
                                String lastName = c.SuppliedName.substringAfter(delimiter);
                                newAccountObj.FirstName = firstName;
                                newAccountObj.LastName = lastName;
                            } else {
                                newAccountObj.LastName = c.SuppliedName;
                            }
                        } else if (String.isBlank(c.SuppliedName) && String.isBlank(c.Web_Last_Name__c)) {
                            newAccountObj.LastName = 'No Name - ' + emailLowerCase; //append email to lastname
                        }
                        //set the account's email
                        newAccountObj.PersonEmail = emailLowerCase;
                        newAccountObj.Email_UID__c = emailLowerCase;
                        //set the phone number
                        if (String.isNotBlank(c.SuppliedPhone)) {
                            newAccountObj.Phone = c.SuppliedPhone;
                        }
                        //get market from the case and assign
                        if (String.isNotBlank(c.Market__c)) {
                            newAccountObj.Market__c = c.Market__c;
                        }
                        //add to the map for upsert
                        mapOfCustEmailToAcc.put(emailLowerCase, newAccountObj);
                    }
                }
            }
            System.debug('mapOfCustEmailToAcc-> ' + mapOfCustEmailToAcc);
            if (!mapOfCustEmailToAcc.isEmpty()) {
                List<Database.UpsertResult> resultList = Database.upsert(mapOfCustEmailToAcc.values(),
                        Account.fields.Email_UID__c, false);
                for (Database.UpsertResult re : resultList) {
                    if (re.getErrors().size() > 0) {
                        for (Database.Error er : re.getErrors()) {
                            System.debug('Account Upsert Error message--> ' + er.getMessage());
                            //throw new PersonAccountServiceException(er.getMessage());
                        }
                    }
                }
                //retrieve newly created accounts and add them to the map
                for (Account a : mapOfCustEmailToAcc.values()) {
                    if (String.isNotBlank(a.Email_UID__c)) {
                        System.debug('PP--Email Id--'+a.Email_UID__c);
                        newCustEmails.add(a.Email_UID__c);
                    }
                }

                for (Account a : [
                        SELECT Id, PersonEmail, Phone, LastName, Email_UID__c,
                                FirstName,PersonContactId
                        FROM Account
                        WHERE RecordTypeId = :persAccRecTypeId
                        AND (Email_UID__c IN :newCustEmails)
                ]) {
                    if (String.isNotBlank(a.Email_UID__c)) {
                        mapOfEmailToAccObj.put(a.Email_UID__c.toLowerCase(), a);
                    }
                }
                System.debug('mapOfEmailToAccObj-> ' + mapOfEmailToAccObj);
                //populate Person account and contact on cases with SuppliedEmail
                for (Case cs : casesToUpdate) {
                    if (cs.AccountId == null && String.isNotBlank(cs.SuppliedEmail) &&
                            mapOfEmailToAccObj.containsKey(cs.SuppliedEmail.trim().toLowerCase())) {
                        cs.AccountId = mapOfEmailToAccObj.get(cs.SuppliedEmail.toLowerCase()).Id;
                        cs.ContactId = mapOfEmailToAccObj.get(cs.SuppliedEmail.toLowerCase()).PersonContactId;
                    }
                }

                if (!casesToUpdate.isEmpty()) {
                    List<Database.SaveResult> caseUpdateResults = Database.update(casesToUpdate, false);
                    for (Database.SaveResult sr : caseUpdateResults) {
                        if (sr.getErrors().size() > 0) {
                            for (Database.Error er : sr.getErrors()) {
                                System.debug('Case update error message-> ' + er.getMessage());
                                throw new PersonAccountServiceException(er.getMessage());
                            }
                        }
                    }
                }
            }
        }
    }

    /*******************************************************************************************************************
    * @Description This method returns a map of incoming customer emails to salesforce person account record id
    * @Param   List<CustomerInfoWrapper>
    * @Return  Map<String, Id>
   ******************************************************************************************************************/
    public static Map<String, Account> upsertPersonAccUsingXDSR(List<CustomerInfoWrapper> custInfoRecs) {
        Map<String, Account> mapOfEmailToAccount = new Map<String, Account>(); //map to hold emails with accounts
        Map<String, Account> mapOfPhoneToAccount = new Map<String, Account>(); //map to hold phones with accounts
        Map<String, Account> mapOfKeyToAccount = new Map<String, Account>(); //map to hold one of the keys with accounts
        List<String> newCustEmails = new List<String>(); //to fetch new person accounts by email
        List<String> newCustPhones = new List<String>(); //to fetch new person accounts by Phone
        String emailLowerCase;
        //first try with email. If not found, try with phone to use as a key.
        System.debug('No. of records to be processed--> ' + custInfoRecs.size());
        //get the record type id of person account
        Id persAccRecTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
        //now check if there are any new customers - if yes, create person accounts and add to the map
        Map<String, Account> mapOfCustEmailToAcc = new Map<String, Account>();//email key to account object map

        for (CustomerInfoWrapper c : custInfoRecs) {
            String trimmedLastName;
            if (String.isNotBlank(c.last_name)) {
                trimmedLastName = c.last_name.trim();
            }
            if (String.isNotBlank(c.email_address) && DataUtility.checkEmail(c.email_address)) {
                emailLowerCase = c.email_address.toLowerCase();
            }
            Account newAccountObj = new Account(); //new account object
            newAccountObj.RecordTypeId = persAccRecTypeId; //set the account record type
            if (String.isNotBlank(emailLowerCase) && DataUtility.checkEmail(emailLowerCase)) {
                //set the name of the account
                if (String.isBlank(trimmedLastName)) {
                    newAccountObj.LastName = 'No Name - ' + emailLowerCase; //append email to lastname
                } else {
                    if (String.isNotBlank(trimmedLastName)) newAccountObj.LastName = trimmedLastName;
                    if (String.isNotBlank(c.first_name)) newAccountObj.FirstName = c.first_name;
                }
                //set the account's email
                newAccountObj.PersonEmail = emailLowerCase;
                newAccountObj.Email_UID__c = emailLowerCase;
                //set the account's phone
                if (String.isNotBlank(c.phone_number)) newAccountObj.Phone = c.phone_number;
                //add to the map
                mapOfCustEmailToAcc.put(emailLowerCase, newAccountObj);
            } else if (String.isBlank(emailLowerCase) && String.isNotBlank(c.phone_number)) {
                //set the name of the account
                if (String.isBlank(trimmedLastName)) {
                    newAccountObj.LastName = 'No Name - ' + c.phone_number;
                } else {
                    if (String.isNotBlank(trimmedLastName)) newAccountObj.LastName = trimmedLastName;
                    if (String.isNotBlank(c.first_name)) newAccountObj.FirstName = c.first_name;
                }
                //phone
                newAccountObj.Phone = c.phone_number;
                //market
                if (String.isNotBlank(c.country)) {
                    newAccountObj.Market__c = c.country;
                }
                //add to the map
                mapOfCustEmailToAcc.put(emailLowerCase, newAccountObj);
            }
        }
        if (!mapOfCustEmailToAcc.isEmpty()) {
            List<Database.UpsertResult> resultList = Database.upsert(mapOfCustEmailToAcc.values(), Account.fields.Email_UID__c, false);
            for (Database.UpsertResult re : resultList) {
                if (re.getErrors().size() > 0) {
                    for (Database.Error er : re.getErrors()) {
                        System.debug('Account Upsert Error message--> ' + er.getMessage());
                        throw new PersonAccountServiceException(er.getMessage());
                    }
                }
            }
            //retrieve newly upserted accounts and add them to the map
            for (Account a : mapOfCustEmailToAcc.values()) {
                if (String.isNotBlank(a.Email_UID__c)) {
                    newCustEmails.add(a.Email_UID__c);
                } else if (String.isNotBlank(a.Phone)) {
                    newCustPhones.add(a.Phone);
                }
            }

            for (Account a : [
                    SELECT Id, PersonEmail, Phone, LastName, Email_UID__c,PersonContactId
                    FROM Account
                    WHERE RecordTypeId = :persAccRecTypeId
                    AND (Email_UID__c IN :newCustEmails OR Phone IN :newCustPhones)
            ]) {
                if (String.isNotBlank(a.Email_UID__c)) {
                    mapOfEmailToAccount.put(a.Email_UID__c.toLowerCase(), a);
                } else if (String.isNotBlank(a.Phone)) {
                    mapOfPhoneToAccount.put((String) a.Phone, a);
                }
            }
        }
        System.debug('mapOfEmailToAccount with existing+new accounts--> ' + mapOfEmailToAccount);
        System.debug('mapOfPhoneToAccount with existing+new accounts--> ' + mapOfPhoneToAccount);
        //copy both maps into the common map and return it
        mapOfKeyToAccount.putAll(mapOfEmailToAccount);
        mapOfKeyToAccount.putAll(mapOfPhoneToAccount);
        System.debug('final map of emails+phones with account--> ' + mapOfKeyToAccount);
        return mapOfKeyToAccount;
    }

    /*******************************************************************************************************************
     * @Description This method returns a map of zendesk customer email to salesforce person account record id
     * @Param   List<Zendesk__Zendesk_Ticket__c>
     * @Return  Map<String, Id>
    ******************************************************************************************************************/
    public static Map<String, Account> upsertPersonAccUsingZendeskTicket(List<Zendesk__Zendesk_Ticket__c> workingRecords) {
        //populate incoming emails in a set
        Set<String> allEmailsSet = new Set<String>();
        for (Zendesk__Zendesk_Ticket__c zt : workingRecords) {
            System.debug('zt--> ' + JSON.serialize(zt));
            //email address is a required field on the page, so this field should always have the customer's email
            if (String.isNotBlank(zt.Zendesk__RequesterEmailAddress__c))
                allEmailsSet.add(zt.Zendesk__RequesterEmailAddress__c.toLowerCase());
        }
        //if the set is empty, no accounts can be fetched or created
        if (allEmailsSet.isEmpty())
            throw new PersonAccountServiceException('There should be at least 1 customer email to continue.');
        //get the record type id of person account
        Id persAccRecTypeId = RecordTypeUtil.recordTypeId('Account', 'Person Account');
        Map<String, Account> mapOfEmailToAccount = new Map<String, Account>();
        List<String> newCustEmails = new List<String>(); //to fetch new person accounts by email
        Map<String, Account> mapOfCustEmailToAcc = new Map<String, Account>();//email key to account object map

        for (Zendesk__Zendesk_Ticket__c zt : workingRecords) {
            System.debug('about to create new acc--> ' + zt);
            Account newAccountObj = new Account();
            newAccountObj.RecordTypeId = persAccRecTypeId;
            newAccountObj.FirstName = zt.Zendesk_First_Name__c;
            newAccountObj.LastName = zt.Zendesk_Last_Name__c;
            newAccountObj.PersonEmail = zt.Zendesk__RequesterEmailAddress__c.toLowerCase();
            newAccountObj.Email_UID__c = zt.Zendesk__RequesterEmailAddress__c.toLowerCase();
            newAccountObj.Phone = zt.Phone_Number__c;
            newAccountObj.Market__c = ZendeskToCaseServiceHelper.getMarket(zt.Language_Preference__c);
            mapOfCustEmailToAcc.put(zt.Zendesk__RequesterEmailAddress__c.toLowerCase(), newAccountObj);
        }
        System.debug('final map--> ' + mapOfCustEmailToAcc);
        if (!mapOfCustEmailToAcc.isEmpty()) {
            List<Database.UpsertResult> resultList = Database.upsert(mapOfCustEmailToAcc.values(), Account.fields.Email_UID__c, false);
            for (Database.UpsertResult re : resultList) {
                if (re.getErrors().size() > 0) {
                    for (Database.Error er : re.getErrors()) {
                        System.debug('Account Upsert Error message--> ' + er.getMessage());
                        throw new PersonAccountServiceException(er.getMessage());
                    }
                }
            }
            //retrieve newly upserted accounts and add them to the map
            for (Account a : mapOfCustEmailToAcc.values()) {
                if (String.isNotBlank(a.Email_UID__c)) {
                    newCustEmails.add(a.Email_UID__c);
                }
            }
            System.debug('newCustEmails--> ' + newCustEmails);
            for (Account a : [
                    SELECT Id, PersonEmail, Email_UID__c,PersonContactId
                    FROM Account
                    WHERE RecordTypeId = :persAccRecTypeId
                    AND Email_UID__c IN :newCustEmails
            ]) {
                mapOfEmailToAccount.put(a.Email_UID__c.toLowerCase(), a);
            }
        }
        System.debug('about to return the map--> ' + mapOfEmailToAccount);
        return mapOfEmailToAccount;
    }

    public class PersonAccountServiceException extends Exception {
    }
}