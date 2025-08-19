public class NoteTriggerHandler {
    public static void process(List<Note> notes){
        Map<String,String> caseNumbersMap = new Map<String,String>();
        for(Note n : notes){
            //String body = n.Body;
            if(string.isNotEmpty(n.Body)){
                Integer posOne = n.Body.indexOf('%');
                Integer posTwo = n.Body.lastIndexOf('%');
                if(posTwo > posOne && (posTwo-PosOne) > 1 && (posTwo-PosOne) <=9 ){
                   caseNumbersMap.put(reformat(n.Body.substring(posOne+1, posTwo)),n.Body);
                }
            }
        }
        if(!caseNumbersMap.values().isEmpty()){
            insertCaseCommentsForValidCases(caseNumbersMap) ; 
        }
    }
    private static string reformat(String str){
        for(Integer  i =str.length() ; i < 8 ; i++){
            str ='0'+str ;
        }
        return str.toLowerCase();
    }
    
    @future
    private static void insertCaseCommentsForValidCases(Map<String,String> caseNumbersMap){
        List<CaseComment> caseComments = new List<CaseComment>();  
        for(Case cs : [
            SELECT Id,CaseNumber 
            FROM Case 
            WHERE CaseNumber IN : caseNumbersMap.keySet()]
        ){
            CaseComment comment = new CaseComment();
            comment.ParentId =cs.Id;
            comment.CommentBody = caseNumbersMap.get(cs.CaseNumber);
            caseComments.add(comment);
        }
        if(!caseComments.isEmpty()){
            database.insert(caseComments);
        }
        
    }
}