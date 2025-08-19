public with sharing class AccountPlan_Controller {
    public boolean booleanEditMode{get;set;}
    public Opportunity opportunity{get;set;}
    public AccountPlan_Controller(ApexPages.StandardController controller) {
        booleanEditMode = false;
        opportunity = (Opportunity)controller.getRecord();
    }
    public Pagereference editPage(){
        booleanEditMode = true;
        return null;
    }
    public Pagereference savePage(){
        booleanEditMode = false;
        update opportunity;
       return null;
    }
    public Pagereference cancelPage(){
        booleanEditMode = false;
       return null;
    }

}