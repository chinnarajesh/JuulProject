public class eSignature {

    Id recordId;
    public eSignature(ApexPages.StandardController controller) {
        this.recordId = controller.getId();
    }
    //public final String LOGIN_DOMAIN = 'login'; //other options: test, prerellogin.pre
    public final String SUCCESS_MESSAGE = 'Correct Verification Code. eSignature created.';
    public final String FAILURE_MESSAGE = 'Incorrect Verification Code.';
    public final String ALREADY_DONE = 'This record has already been signed.';
    public String username { get {return UserInfo.getUsername();} }
    //public transient String password { get; set; }
    public String comment { get; set; }
    public String eSigType { get; set; } {
        eSigType = 'Case';
    } // set a default

    //otp
    public Integer otp { get; set; }
    public Integer oneTimePass { get; set; }
    public Boolean showCodePanel { get; set; }
    public Integer noOfAttempts = 0;
    public Boolean isAlreadySigned {
        get {
            // MVP-9181 check to see if signed off
            eSignature__c[] didSignOff = [
                    select Id
                    from eSignature__c
                    where
                    Case__c = :this.recordId
                    AND OwnerId = :UserInfo.getUserId()
                    limit 1
            ];
            if (didSignOff.size() > 0) {
                // dont add a this message if the page already has a SUCCESS_MESSAGE or FAIL message
                if (!ApexPages.hasMessages()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ALREADY_DONE));
                }
            }
            return (didSignOff.size() > 0);
        }
    }

    public void doVerify() {
        long now = datetime.now().gettime();
        while (datetime.now().gettime() - now < 5000); // Busy loop for 5000 ms

        if (noOfAttempts > 4) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Too many unsuccessful attempts. Please request a new Code.'));
            showCodePanel = false;
        }
        Boolean verified = false;
        System.debug('otp-> ' + otp);
        System.debug('oneTimePass-> ' + oneTimePass);
        if (otp == oneTimePass) {
            verified = true;
        }
        System.debug('verified-> ' + verified);
        if (verified && eSigType == 'Case') {
            insert new eSignature__c (Case__c = this.recordId, Comment__c = comment);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, SUCCESS_MESSAGE));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, FAILURE_MESSAGE));
            noOfAttempts++;
        }
    }

    public void sendOTP() {
        //get case number from Id
        String caseNumber;
        List<Case> caseList = [SELECT CaseNumber FROM Case WHERE Id =:this.recordId];
        if (!caseList.isEmpty()) caseNumber = caseList[0].CaseNumber;

        //send a random number to the user
        oneTimePass = Math.round((Math.random() * (900000) + 100000));
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{
                UserInfo.getUserEmail()
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('One Time Verification Code');
        //mail.setReplyTo('no-reply@juul.com');
        //mail.setSenderDisplayName('Salesforce Support');
        mail.setPlainTextBody('Hi ' + UserInfo.getName() + ', Your one time verification code for Case Number '+caseNumber+' is '+ oneTimePass+'. Please use this code to approve and create a eSignature record. Here\'s the link to the Case record : '+Url.getSalesforceBaseUrl().toExternalForm()+'/'+this.recordId);
        //set from
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@juulvapor.com'];
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
        showCodePanel = true;
        noOfAttempts = 0;
    }
}