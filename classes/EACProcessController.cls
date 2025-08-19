/**************************************************************************************/ 
/* Mehod Name : EACProcessController
/*Description: For EAC Process flow.                                                 
/* Ticket : JTP-164                                                                   
/* Added By : Pooja Gite                                                                                            
/**************************************************************************************/    

public class EACProcessController {
    
Public static List<Account> dd = new List<Account>();
//getAccounts methods to fetch all Account records as per criteria.
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts(String SOIds) {
        dd = [select Id, Name,Chain_Expansion__c,Last_Parent_Account_Update__c FROM Account where (Last_Parent_Account_Update__c != null AND EAC_Certification_Status__c != 'Certification Passed' AND DocAttachedCheck__c = false AND ParentId =:SOIds)];
        return dd;
    }

//updateAccount method to update Account EAC Certification Status.
    @AuraEnabled
    public static void updateAccount(List<ID> SetIDs)
    {
        System.debug('SetIDs-->'+SetIDs);
       List<Account> accList = new List<Account>();
        for(Account acc : [select id,EAC_Certification_Status__c, DocAttachedCheck__c from account where id =:  setIDs])
        {
            //acc.EAC_Certification_Status__c = 'Certification Pending';
            // added by subodh for new built jtp-418
            acc.Pathway_Status__c='Certification Pending';
            acc.DocAttachedCheck__c = true;
            acc.X2D_Bar_Scanner__c = true; 
            acc.Update_Via_EAC_Process__c=true;
            accList.add(acc);
        }
        if(accList!=null){
           update accList;
        }
    }
    
   
    @InvocableMethod(label='accountUpdate from Flowto create case' description='This will update account and create case' category='Account') 
      public static void updateAccountAnnotated(List<String> SetIDs)
    {
    
     String[] VarIds;
     
    System.debug('SetIDs-->'+SetIDs);
    System.debug('SetIDs[0] -->'+SetIDs[0]);
   // List < String > strInputs
         //  List<String> listTemp = SetIDs.split( ‘,’ );
         if(SetIDs[0].contains('XXX'))
          VarIds = SetIDs[0].split('XXX');
         else
         VarIds=SetIDs;
     
      System.debug('VarIds-->'+VarIds);      
           
        List<Account> accList = new List<Account>();
        for(Account acc : [select id,EAC_Certification_Status__c, DocAttachedCheck__c from account where id =: VarIds])
        {
            //acc.EAC_Certification_Status__c = 'Certification Pending';
            // added by subodh for new built jtp-418
            acc.Pathway_Status__c='Certification Pending';
            acc.DocAttachedCheck__c = true;
            acc.X2D_Bar_Scanner__c = true; 
            acc.Update_Via_EAC_Process__c=true;
            accList.add(acc);
        }
        if(accList!=null){
           update accList;
        }
    
    }
}