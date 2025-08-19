@isTest
public with sharing class PropelOnHoldLifecycleCheckTest { 
    static void SetUpData(){
        //Create Custom Settings --> Configurations
        PDLM__Configuration__c config = new PDLM__Configuration__c(Name = 'OnHoldLifecycleCheck', PDLM__Value__c = 'true');
        insert config;

        //Item Lifecycle and Category
        PDLM__Lifecycle__c lifecycleItem = new PDLM__Lifecycle__c(Name = 'Part');
        insert lifecycleItem;

        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();
        PDLM__Phase__c firstPhase = new PDLM__Phase__c(Name='Prototype', PDLM__order__c = 1, PDLM__Default_No_Change_Control__c = true, 
                                                        PDLM__lifecycle__c = lifecycleItem.id, 
                                                        PDLM__Next_Phases__c = '["On-Hold", "Production"]');
        phasesToInsert.add(firstPhase);
        PDLM__Phase__c secondPhase = new PDLM__Phase__c(Name='Production', PDLM__order__c = 2, PDLM__Default_No_Change_Control__c = true, 
                                                        PDLM__lifecycle__c = lifecycleItem.id, PDLM__Next_Phases__c = '["On-Hold"]');
        phasesToInsert.add(secondPhase);
        PDLM__Phase__c thirdPhase = new PDLM__Phase__c(Name='On-Hold', PDLM__order__c = 3, PDLM__Default_No_Change_Control__c = true, 
                                                        PDLM__lifecycle__c = lifecycleItem.id);
        phasesToInsert.add(thirdPhase);
        insert phasesToInsert;

        PDLM__Category__c categoryForPartItem = new PDLM__Category__c(Name='Finished Good', PDLM__Type__c = 'Item', PDLM__Lifecycle__c = lifecycleItem.id);
        insert categoryForPartItem;

        //Create Items
        List<PDLM__Item__c> itemsListToInsert = new List<PDLM__Item__c>();
        PDLM__Item__c parentItem1 = new PDLM__Item__c(Name = 'Parent Item 1', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(parentItem1);
        PDLM__Item__c parentItem2 = new PDLM__Item__c(Name = 'Parent Item 2', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(parentItem2);
        PDLM__Item__c childItem1 = new PDLM__Item__c(Name = 'Child Item 1', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem1);
        PDLM__Item__c childItem2 = new PDLM__Item__c(Name = 'Child Item 2', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem2);
        insert itemsListToInsert;
       
        //Create Item Revisions
        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();
        parentItem1RevOnHold = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem1.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(parentItem1RevOnHold);
        parentItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem2.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'Production');
        revsListToInsert.add(parentItem2Rev);
        childItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem1.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'Prototype');
        revsListToInsert.add(childItem1Rev);
        childItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem2.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'Production');
        revsListToInsert.add(childItem2Rev);
        insert revsListToInsert;

        //Add Assemblies
        List<PDLM__Assembly__c> assListToInsert = new List<PDLM__Assembly__c>();
        PDLM__Assembly__c ass1 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1RevOnHold.Id, PDLM__Item__c = childItem1.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass1);
        PDLM__Assembly__c ass2 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1RevOnHold.Id, PDLM__Item__c = childItem2.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass2);
        PDLM__Assembly__c ass3 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem2Rev.Id, PDLM__Item__c = childItem1.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass3);
        PDLM__Assembly__c ass4 = new PDLM__Assembly__c(PDLM__Item_Revision__c = childItem1Rev.Id, PDLM__Item__c = childItem2.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass4);
        insert assListToInsert;
    }

    static PDLM__Item_Revision__c parentItem1RevOnHold;
    static PDLM__Item_Revision__c parentItem2Rev;
    static PDLM__Item_Revision__c childItem1Rev;
    static PDLM__Item_Revision__c childItem2Rev;

    @isTest public static void checkUponInsertError() {
        SetUpData();
        
        childItem1Rev.PDLM__Released__c = true;
        update childItem1Rev;

        PDLM__Item_Revision__c childItem1Rev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem1Rev.PDLM__Master_Item__c, PDLM__Revision__c = 'B', PDLM__Lifecycle_Phase__c = 'On-Hold');

        try {
            insert childItem1Rev2;
        } 
        catch( Exception e) {
            System.assertNotEquals(-1, e.getMessage().indexOf('You cannot set this Item Revision\'s Lifecycle Phase to On-Hold. Please make sure all the immediate parents are at the On-Hold Lifecycle Phase.'));
		}
    }

    @isTest public static void checkUponInsertSuccess() {
        SetUpData();
        
        childItem1Rev.PDLM__Released__c = true;
        update childItem1Rev;

        PDLM__Item_Revision__c childItem1Rev2 = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem1Rev.PDLM__Master_Item__c, PDLM__Revision__c = 'B', PDLM__Lifecycle_Phase__c = 'Production');

        try {
            insert childItem1Rev2;
        } 
        catch( Exception e) {
            System.assertEquals(-1, e.getMessage().indexOf('You cannot set this Item Revision\'s Lifecycle Phase to On-Hold. Please make sure all the immediate parents are at the On-Hold Lifecycle Phase.'));
		}
    }

    @isTest public static void checkUponUpdateError() {
        SetUpData();

        childItem1Rev.PDLM__Lifecycle_Phase__c = 'On-Hold';

        try {
            update childItem1Rev;
        } 
        catch( Exception e) {
            System.assertNotEquals(-1, e.getMessage().indexOf('You cannot set this Item Revision\'s Lifecycle Phase to On-Hold. Please make sure all the immediate parents are at the On-Hold Lifecycle Phase.'));
		}
    }

    @isTest public static void checkUponUpdateSuccess() {
        SetUpData();

        childItem1Rev.PDLM__Lifecycle_Phase__c = 'Production';

        try {
            update childItem1Rev;
        } 
        catch( Exception e) {
            System.assertEquals(-1, e.getMessage().indexOf('You cannot set this Item Revision\'s Lifecycle Phase to On-Hold. Please make sure all the immediate parents are at the On-Hold Lifecycle Phase.'));
		}
    }
}