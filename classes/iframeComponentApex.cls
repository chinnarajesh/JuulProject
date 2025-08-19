public class iframeComponentApex {
      @AuraEnabled(cacheable=true)
     public static string getAccountId(Id userId) {
        // your code here
        return [select id,AccountId,name from user where id=:userId and isActive=:true limit 1][0].AccountId;
     }
}