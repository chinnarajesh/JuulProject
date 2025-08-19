public class CSVUtility {   
    public static List<String> lines = new List<String>();
    private static Integer inputCharacterMax { get { return 50000; } set; } 
    
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        lines = new List<String>();
        List<List<String>> allFields = new List<List<String>>();
       
        try {
            divideString(contents);
            System.debug('lines: ' + lines);
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        
        Integer iter = 0;
        if (skipHeaders) lines.remove(0);
        
        while( iter < lines.size() ){
            System.debug('iter: ' + iter);
            System.debug('size: ' + lines.size());
            String line = lines.remove(iter);
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) continue;         
            List<String> fields = line.split(',');   
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT','').replaceAll('"',''));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"').replaceAll('"',''));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"').replaceAll('"',''));
                }
            }
            allFields.add(cleanFields);
        }

        
        return allFields;      
    }

    // Divide string w/ recursion
    public static void divideString(String input) {       
        Integer pivot = input.indexOf( '\n', Integer.valueOf(Math.floor(input.length() / 2)) );
        if( pivot == -1 )
            pivot = input.indexOf( '\r', Integer.valueOf(Math.floor(input.length() / 2)) );
            
        System.debug('input: ' + input);
        String left = input.substring(0,pivot);
        String right = input.substring(pivot);
        if ( pivot < inputCharacterMax ) {
            List<String> leftLines = left.split('[\r\n]+');
            List<String> rightLines = right.split('[\r\n]+');
            lines.addAll(leftLines);
            lines.addAll(rightLines);
        }
        else {
            divideString(left);
            divideString(right);
        }
    }
    /*
    public static void sendEmail( List<String> emailAddresses,
                                  String ccAddress,
                                  String bccAddress,
                                  String emailText,
                                  String emailSubject){

        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setSenderDisplayName('support@revivoconsulting.com');
        singleEmail.setInReplyTo('support@revivoconsulting.com'); 
        singleEmail.setToAddresses(emailAddresses);
        if(ccAddress != null){
            List<String> ccAddressList =new List<String>{ccAddress};
            singleEmail.setCcAddresses(ccAddressList);
        }
        if(bccAddress != null){
            List<String> bccAddressList =new List<String>{bccAddress};
            singleEmail.setBccAddresses(bccAddressList);
        }
        singleEmail.setSubject(emailSubject);
        singleEmail.setPlainTextBody(emailText);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { singleEmail });
        }
    }
    */
}