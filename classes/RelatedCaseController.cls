/*
* Related Case Controller - This class fetch all the related cases from the contact and show on the VF page
*
*/
public class RelatedCaseController{
 public List<Case> relatedCaseList{get;set;}
 
 public RelatedCaseController(ApexPages.StandardController stdCon){
   Case c = [Select
                       Id, ContactId, AccountId
                    From 
                       Case
                    Where
                        Id =:stdCon.getId()];
   relatedCaseList = [Select 
                       Id, Casenumber, subject, status, CreatedDate, OwnerId
                   from 
                       Case 
                   where
                       AccountId =:c.AccountId AND id <> :c.id
                   Order by
                       Casenumber desc]; 
 }
 
 

}