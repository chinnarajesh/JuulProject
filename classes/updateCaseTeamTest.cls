@isTest 
private class 
updateCaseTeamTest{
    
static testMethod void myUnitTest() {
        
case c = new case();
        
c.status = 'New';
        
c.Origin = 'Web';

c.Add_Support_Case_Team__c = TRUE;

c.Support_2__c = FALSE;
        
      
insert c;
           
}
}