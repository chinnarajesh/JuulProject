@isTest
public class TestSubmittedItems {
    @isTest static void TestData(){
        List <PDLM__Lifecycle__c> TestLifecycles = new List  <PDLM__Lifecycle__c>();
        List <PDLM__Category__c> TestCategories = new List  <PDLM__Category__c>();
        List <PDLM__Affected_Item__c> TestAffectedItems = new List  <PDLM__Affected_Item__c>();
        List <PDLM__item__c> TestItems = new List <pdlm__item__c>();
        List <PDLM__Item_Revision__c> TestRevisions = new List<PDLM__Item_Revision__c>();
        List <PDLM__Assembly__c> TestAssembly = new List<PDLM__Assembly__c>();
        List <PDLM__Change__c> TestChange = new List<PDLM__Change__c>();
        List <PDLM__Phase__c> TestPhases = new List<PDLM__Phase__c>();
        system.debug('0');
        TestLifecycles.add(new PDLM__Lifecycle__c (Name = 'TestLifecycleItems1',PDLM__Type__c='Item'));
        system.debug('1');
        TestLifecycles.add(new PDLM__Lifecycle__c (Name='TestLifecycleChanges1',PDLM__Type__c='change'));
        Insert TestLifecycles;
        TestPhases.add(new PDLM__Phase__c (Name='TestPhase1',PDLM__Lifecycle__c=TestLifecycles[0].ID));
        Insert TestPhases;
        TestCategories.add(new PDLM__Category__c (Name='TestCategorieItems1',PDLM__Lifecycle__c=TestLifecycles[0].ID));
        TestCategories.add(new PDLM__Category__c (Name='TestCategorieChanges1',PDLM__Lifecycle__c=TestLifecycles[1].ID));
        Insert TestCategories;
        TestChange.add(new PDLM__Change__c (Name='TestChanges1', PDLM__Category__c=TestCategories[1].ID, PDLM__Title__c='Test Change1',PDLM__Description_5000__c='Test Change1'));
        Insert TestChange;
        For (integer i=0;i<100;i++){
            TestItems.add(new PDLM__Item__c (Name='item'+i,PDLM__Category__c=TestCategories[0].ID, OwnerID='00539000005Pvr3AAC'));
            System.debug('Item '+i+': '+TestItems[i]);
        }
        TestItems[0].Submission_Top__c = True;
        Insert TestItems;
        
        For (integer i=0;i<100;i++){
            TestRevisions.add(new PDLM__Item_Revision__c (Name=TestItems[i].Name+':'+string.valueOf(i),PDLM__Released__c=true,PDLM__Revision__c=string.valueOf(i),PDLM__Description__c='Description'+i,PDLM__Lifecycle_Phase__c='TestPhase1', PDLM__Master_Item__c=TestItems[i].ID));
            TestItems[i].PDLM__Latest_Revision__c=TestRevisions[i].ID;
            TestItems[i].PDLM__Latest_Released_Revision__c=TestRevisions[i].ID;
            System.debug('Rev '+i+': '+TestRevisions[i]);
        }
        TestRevisions[0].PDLM__Has_BOM__c=true;
        TestRevisions[2].PDLM__Has_BOM__c=true;
        Insert TestRevisions;
        update TestItems;
        System.debug('Item final: '+TestItems);
        TestAffectedItems.add(new PDLM__Affected_Item__c (PDLM__Change_Order_lk__c=TestChange[0].ID,PDLM__Item_Revision__c=TestRevisions[0].ID));
        Insert TestAffectedItems;
        //Assembly: level0(item0), level1(item1,item2), level 3(the rest, all under item2)
        TestAssembly.add(new PDLM__Assembly__c (Name='Assy0-1',PDLM__Find_Number__c=0,PDLM__Item__c=TestItems[0].ID, PDLM__Quantity__c=1,PDLM__Item_Revision__c=TestRevisions[1].ID));
        TestAssembly.add(new PDLM__Assembly__c (Name='Assy0-2',PDLM__Find_Number__c=1,PDLM__Item__c=TestItems[0].ID, PDLM__Quantity__c=1,PDLM__Item_Revision__c=TestRevisions[2].ID));
        For (integer i=3;i<100;i++){
            TestAssembly.add(new PDLM__Assembly__c (Name='Assy2-'+i,PDLM__Find_Number__c=i,PDLM__Item__c=TestItems[2].ID, PDLM__Quantity__c=1,PDLM__Item_Revision__c=TestRevisions[i].ID));
        }
        Insert TestAssembly;
        System.debug('Assembly final: '+TestAssembly);
        System.debug('Assembly name: '+TestAssembly[0].Name);
        system.debug('Category:'+TestCategories[0].PDLM__Is_Structural__c+TestCategories[0].PDLM__Lifecycle__c);
        System.debug('hasBOM0='+TestRevisions[0].PDLM__has_BOM__c);
        System.debug('hasBOM1='+TestRevisions[1].PDLM__has_BOM__c);
        System.debug('hasBOM2='+TestRevisions[2].PDLM__has_BOM__c);
        SubmittedItems2.insertItems2(TestChange[0].ID);
    }
}