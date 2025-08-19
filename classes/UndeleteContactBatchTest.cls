/**********************************************************************/
/* VERSION     		AUTHOR                  	DATE                           */
/*     1.0     		Ramya Ganeshkar       05-17-2021                    */
/* Class Name: UndeleteContactBatchTest                       */
/* Description: Test class for coverage UndeleteContactBatchTest  */
/*Ticket Number:     */
/**********************************************************************/
@isTest
public class UndeleteContactBatchTest {
    
    static testmethod void userRestrictContact(){
        Profile p = [Select Id from Profile where Name = 'System Administrator'];
        User u = new User();
        u.LastName = 'Ownbackup User';
        u.Alias = 'ownb';
        u.Email = 'ownbackup@gmail.com';
        u.Username = 'ownbackup@gmail.com';
        u.ProfileId = p.Id;
        u.EmailEncodingKey = 'ISO-8859-1';
        u.TimeZoneSidKey =  'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
        System.runAs(u){
            List<Contact> conLst = new List<Contact>();
            Contact con = new contact();
            con.LastName = 'Test Contact 1';
            conLst.add(con);
            
            Contact c1 = new Contact();
            c1.LastName = 'Contact Test';
            conLst.add(c1);        
            insert conLst;
            //delete c1;             
            
            Test.startTest();
            delete conLst;  
            List<Contact> lstCon = [SELECT Id, Name FROM Contact WHERE isDeleted=true ALL ROWS];
            //undelete c1;
            UndeleteContactBatch restrictBatch = new UndeleteContactBatch();
            Database.executeBatch(restrictBatch);
            Test.stopTest();
            
            Contact c = [SELECT Id, Name FROM Contact WHERE Id=:c1.Id];
            System.assertEquals(c.Name, 'Contact Test');
            
        }
    }
}