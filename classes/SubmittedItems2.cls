Global class SubmittedItems2 {

    Public Static Integer NodeCount = 0;
    @invocableMethod(Label='Mark Submitted')
    global static void PBCall(list<GetECOData> ECO){
    SubmittedItems2.insertItems2(ECO[0].ECO_ID);
    }
    global class GetECOData{
        @invocableVariable(Label='ECO ID' required=true)
        Public ID ECO_ID;
    }
    Public static list<ID> FirstBOMLevel2(List<ID> CurrentLevel)
    /***************************************************************************
     Recursive function to "crawl" through the whole BOM.
     Input: ID of Item Revision
     Return: List of IDs of all the children in the BOM
    ***************************************************************************/    
    {
        List <PDLM__Assembly__c> FirstLevelChildren = [Select ID, Name, PDLM__Parent_Item__c, PDLM__Item_Revision__c, Parent_Item_Number__c, PDLM__Item_Number__c, PDLM__Item__c, PDLM__Find_Number__c, PDLM__Quantity__c, PDLM__Designators__c FROM PDLM__Assembly__c where PDLM__Item_Revision__c=: CurrentLevel];
        list <ID> ListOfChildrenID = new list <ID>(); //All children in level below CurrentLevel
        List <ID> ChildrenRevID = new List <ID>(); // list of Children converted to Item Rev
        Boolean NotLastLevel = False;
        For (PDLM__Assembly__c LoopChildren : FirstLevelChildren)
       {
           ListOfChildrenID.add(LoopChildren.PDLM__Item__c);
           system.debug('First Row: ' + LoopChildren.PDLM__Item__c);
       }   
       List <PDLM__Item_Revision__c> ChildrenRev = [Select ID, PDLM__Master_Item__c, PDLM__Has_BOM__c,PDLM__Is_Latest_Released__c From PDLM__Item_Revision__c where PDLM__Master_Item__c=:ListOfChildrenID and PDLM__Is_Latest_Released__c=:True];
       
        For (PDLM__Item_Revision__c LoopChildrenRev :ChildrenRev)
        //Loop to create a list of all item revision IDs of children in this level
       { 
           ChildrenRevID.add(LoopChildrenRev.ID);
           If (LoopChildrenRev.PDLM__Has_BOM__c) NotLastLevel=True;
           system.debug('ID: '+LoopChildrenRev.ID+'Level: '+NotLastLevel);
       }
       system.debug(ChildrenRevID.size());
       If (NotLastLevel=True && ChildrenRevID.size()!=0)
       {
           system.debug('************************'+NotLastLevel);
           ListOfChildrenID.addall(FirstBOMLevel2(ChildrenRevID));
       }
        system.debug('before return: ' + ListOfChildrenID);
        NodeCount++;
        system.debug('Level Count:'+NodeCount);
        Return ListOfChildrenID;
    }
    public static Set<ID> insertItems2(ID ChangeID)
    /***************************************************************************
     Creates and inserts Items record, pulls items from Change AI 
     Input: Id of the Change Order (Propel), ID of the Session Record (RS)
     Return: Nothing
    /***************************************************************************/
    {
        Set <ID> ItemRevIDList = new Set <ID>(); //list of all the unique Propel item revision IDs for affected items and their children trees
        Set <ID> ItemIDList = new Set <ID>();
        List<ID> AffectedItemRevID = new List <ID>(); // list of Item Revision IDs of all Affected Items
        List<ID> Level = new List <ID>();
        ID AffectedItemID; // list of Item IDs of all Affected Items
        Boolean Submission=true;
        List<PDLM__Affected_Item__c> AffectedItems = [Select ID,Name, PDLM__Change_Order_lk__c, PDLM__Item_Revision__c,Submitted_Top__c FROM PDLM__Affected_Item__c where PDLM__Change_Order_lk__c =: ChangeID];
        For (PDLM__Affected_Item__c LoopAffectedItems : AffectedItems)
        //Loop Through Affected items that are marked as Submitted top      
        {
            system.debug(LoopAffectedItems.Submitted_Top__c);
        IF (LoopAffectedItems.Submitted_Top__c) AffectedItemRevID.add(LoopAffectedItems.PDLM__Item_Revision__c);
       }
        ItemRevIDList.addAll(AffectedItemRevID);
        List<PDLM__Item_Revision__c> AffectedItemsRev = [Select ID,Name, PDLM__Has_Bom__c, PDLM__Master_Item__c FROM PDLM__Item_Revision__c where ID=:AffectedItemRevID];
        For (PDLM__Item_Revision__c LoopAffectedItemRev : AffectedItemsRev)
        {
            
                AffectedItemID=LoopAffectedItemRev.PDLM__Master_Item__c;
           //update new PDLM__Item__c(ID=AffectedItemID,Submission_Top__c=Submission, Submission_Date__c=SubmissionDate);
            ItemIDList.add(AffectedItemID);
            If (LoopAffectedItemRev.PDLM__Has_Bom__c)
           {
               system.debug('AI: '+ ItemIDList);
               Level.add(LoopAffectedItemRev.ID);
               system.debug('Level: '+ Level);
               ItemIDList.addAll(FirstBOMLevel2(Level));
               Level.clear();
           }
        }
        system.debug('The End: ' + ItemIDList);
        system.debug('The End size: ' + ItemIDList.size());
        
        List <PDLM__Item__c> RecordsToUpdate = [Select ID, Name From PDLM__Item__c Where ID=:ItemIDList];
        
        Integer RecordCounter = 0;
        For (ID IDLoop : ItemIDList)
        {
            RecordsToUpdate[RecordCounter].Submitted__c=Submission;
        system.debug('############################'+RecordsToUpdate[RecordCounter].Name+RecordsToUpdate[RecordCounter].Submitted__c);
            RecordCounter++;
            
        }
        update RecordsToUpdate;
        system.debug('# of Nodes: '+NodeCount);
        Return ItemIDList;      
    }
}