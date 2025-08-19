global with sharing class BrontoAPIService implements Database.AllowsCallouts, Queueable , Database.Batchable<sObject>{
    String param;
   global Database.QueryLocator start(Database.BatchableContext BC){
        /*String query = 'SELECT ID, Type, Status, CreatedDate, ClosedDate, Account.PersonalEmail '
                    + ' Product__c, Topic__c, Issue__c FROM Case';
        */
      return Database.getQueryLocator(param);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
        Case CaseRecord = (Case)(scope[0]);
        juul.sendToBronto(caseRecord, CaseRecord.Account.PersonEmail);
        pax.sendToBronto(caseRecord, CaseRecord.Account.PersonEmail);
    }

   global void finish(Database.BatchableContext BC){
    
   }

    public void execute(QueueableContext context){
        List<Case> cases = [SELECT 
								ID, Type, Status, CreatedDate, ClosedDate
								, Account.PersonEmail, isClosed
								, Product__c, Topic__c, Issue__c 
						  FROM 
							Case
						  WHERE
							ID =: param AND Account.PersonEmail != null ];
		if(! cases.isEmpty()){
			Case caseRecord = cases[0];
			juul.sendToBronto(caseRecord, CaseRecord.Account.PersonEmail);
			pax.sendToBronto(caseRecord, CaseRecord.Account.PersonEmail);
		}
    }



    public BrontoAPIService(String param){
        this.param = param;
    }
    public Products juul 
                    = new Products(
                        'F6CE080A-D786-4EB8-9D6C-610A3C84FF94'
                        ,'0bdc03e900000000000000000000000137ff'
                        , '0bdc03e90000000000000000000000013800'
                        , '0bdc03e90000000000000000000000013801'
                        , '0bdc03e90000000000000000000000013802'
                        , '0bdc03e900000000000000000000000138ae'
                        , '0bdc03e900000000000000000000000138b0'
                        , '0bdc03e900000000000000000000000138af'
                    );
    public Products pax 
                    = new Products(
                        'DC905DB9-12D6-4EDC-9998-CAD2448B15D4'
                        ,'0bdc03e900000000000000000000000137d6'
                        , '0bdc03e900000000000000000000000137d7'
                        , '0bdc03e900000000000000000000000137d8'
                        , '0bdc03e900000000000000000000000137d9'

                        , '0bdc03e900000000000000000000000138b1'
                        , '0bdc03e900000000000000000000000138b3'
                        , '0bdc03e900000000000000000000000138b2'
                    );
    


    

    public class Products{
        public String apiToken;
        public String fieldTicketStatus;
        public String fieldTicketDateCreated;
        public String fieldTicketDateClosed;
        public String fieldTicketType;
        public String fieldTicketProduct;
        public String fieldTicketIssue;
        public String fieldTicketTopic;


        public void sendToBronto(Case caseRecord, string email){
            try{
                    apiBrontoComV4.BrontoSoapApiImplPort bservice = new apiBrontoComV4.BrontoSoapApiImplPort();
                    bservice.sessionHeader  = new apiBrontoComV4.sessionHeader();
                    bservice.sessionHeader.sessionId = bservice.login(apiToken);
                    System.debug(bservice.sessionHeader.sessionId);
                    if(String.isNotBlank(bservice.sessionHeader.sessionId)){
                        apiBrontoComV4.stringValue emailFilter = new apiBrontoComV4.stringValue();
                        emailFilter.operator = 'EqualTo';
                        emailFilter.value = email;
                        apiBrontoComV4.contactFilter filter = new apiBrontoComV4.contactFilter();
                        filter.email = new List<apiBrontoComV4.stringValue>();
                        filter.email.add(emailFilter);
                        apiBrontoComV4.contactObject[] matchingContacts = bService.readContacts(filter);
                        System.debug(matchingContacts);
                        if(matchingContacts != null && ! matchingContacts.isEmpty()){
                            matchingContacts[0].fields = new List<apiBrontoComV4.contactField>();
                            matchingContacts[0].fields.add(
                                            new apiBrontoComV4.contactField(
                                                fieldTicketStatus
                                                , caseRecord.Status
                                            ));
                            matchingContacts[0].fields.add(
                                            new apiBrontoComV4.contactField(
                                                fieldTicketIssue
                                                , caseRecord.Issue__c
                                            ));
                            matchingContacts[0].fields.add(
                                            new apiBrontoComV4.contactField(
                                                fieldTicketTopic
                                                , caseRecord.Topic__c
                                            ));
                            matchingContacts[0].fields.add(
                                            new apiBrontoComV4.contactField(
                                                fieldTicketProduct
                                                , caseRecord.Product__c
                                            ));
                            matchingContacts[0].fields.add(
                                            new apiBrontoComV4.contactField(
                                                fieldTicketDateCreated
                                                , caseRecord.CreatedDate.format('yyyy-MM-dd')
                                            ));
                            System.debug('--caseRecord.closeddate-' + caseRecord.closeddate);
                            System.debug('--caseRecord.fieldTicketDateClosed-' + fieldTicketDateClosed);
                            if(caseRecord.closeddate != null ){
                                System.debug('--caseRecord.fieldTicketDateClosed-' + caseRecord.closeddate.format('yyyy-MM-dd'));
                                matchingContacts[0].fields.add(
                                                new apiBrontoComV4.contactField(
                                                    fieldTicketDateClosed
                                                    , caseRecord.closeddate.format('yyyy-MM-dd')
                                                ));
                            }
                            matchingContacts[0].fields.add(
                                            new apiBrontoComV4.contactField(
                                                fieldTicketType
                                                , caseRecord.Type
                                            ));
                            System.debug(matchingContacts[0].fields);
                            apiBrontoComV4.writeResult result = bService.updateContacts(matchingContacts);
                            System.debug(result);
                        }
                    }
                }catch(Exception ex){
                    throw ex;
                }
        }

        public Products(String apiToken, String fieldTicketStatus
                    , String fieldTicketDateCreated, String fieldTicketDateClosed
                    , String fieldTicketType, String fieldTicketProduct, String fieldTicketIssue
                    , String fieldTicketTopic){
            this.apiToken = apiToken;
            this.fieldTicketStatus = fieldTicketStatus;
            this.fieldTicketDateCreated = fieldTicketDateCreated;
            this.fieldTicketDateClosed = fieldTicketDateClosed;
            this.fieldTicketType = fieldTicketType;
            this.fieldTicketProduct = fieldTicketProduct;
            this.fieldTicketIssue = fieldTicketIssue;
            this.fieldTicketTopic = fieldTicketTopic;
        }
    }
    
}