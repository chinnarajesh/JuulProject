global with sharing class GenericController{
    public static Id caseId{get;set;}
    public GenericController(){
        caseId = null;
    }
    
    @RemoteAction
    global static void assignId(String Id){
        caseId = Id;
    }
}