public class TemplateResolver{


    public static String compile(String emailTemplate, Id rid){
        return replace(emailTemplate, rid.getSobjectType()+'', rid);
    }
    
    private static String replace(String emailTemplate, String objectName, Id recordId){
        Pattern regex = Pattern.compile('\\{!([^}]*)\\}');
        Matcher regexMatcher = regex.matcher(emailTemplate);
        Set<String> tokens = new Set<String>();

        while (regexMatcher.find()){         
            String dirtyVariable = regexMatcher.group();
  
            String variable = dirtyVariable.substring(2,dirtyVariable.length()-1); 
            if(variable.startsWith(objectName + '.')){
                tokens.add(variable.replace(objectName + '.', ''));
            }
        }
        String qry = 'Select ';
        for(String s : tokens){
            qry += s + ',';
        } 
        qry = qry.substring(0, qry.length()-1);
        system.debug('!!!!' + qry);
        SObject o = Database.query(qry + ' From ' + objectName + ' Where ID = :recordID');
        
        for(String s : tokens){         
            emailTemplate = emailTemplate.replace('{!' + objectName + '.' + s + '}', getValue(o, s));
        }
        return emailTemplate;
    }
    
    private static String getValue(SObject o, String fieldName){
        return (o.get(fieldName) != null) ?   String.valueOf(o.get(fieldName)) : '';
    } 
}