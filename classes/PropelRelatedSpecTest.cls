@isTest
public with sharing class PropelRelatedSpecTest { 
    static void SetUpData(){
        //Create Custom Settings --> Configurations
        PDLM__Configuration__c config1 = new PDLM__Configuration__c(Name = 'RelatedSpecTrigger', PDLM__Value__c = 'true');
        insert config1;
        PDLM__Configuration__c config2 = new PDLM__Configuration__c(Name = 'RelatedSpecBatchScope', PDLM__Value__c = '200');
        insert config2;
        
        List<PDLM__Phase__c> phasesToInsert = new List<PDLM__Phase__c>();

        //Change Lifecycle and Category
        PDLM__Lifecycle__c lifecycleChange = new PDLM__Lifecycle__c(name='ECO');
        insert lifecycleChange;

        PDLM__Phase__c pendingPhase = new PDLM__Phase__c(Name='Pending', PDLM__Is_First_Phase__c = true, PDLM__order__c = 1, PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycleChange.id);
        phasesToInsert.add(pendingPhase);
        PDLM__Phase__c CCBPhase = new PDLM__Phase__c(Name='PLM Review', PDLM__order__c = 2, PDLM__Auto_Submit_For_Approval__c = true, PDLM__lifecycle__c = lifecycleChange.id);
        phasesToInsert.add(CCBPhase);
        PDLM__Phase__c approvedPhase = new PDLM__Phase__c(Name='Released', PDLM__order__c = 3, PDLM__No_Approval__c = true, PDLM__lifecycle__c = lifecycleChange.id);
        phasesToInsert.add(approvedPhase);
        
        PDLM__Category__c categoryForChange = new PDLM__Category__c(Name='ECO', PDLM__Type__c = 'Change', PDLM__Lifecycle__c = lifecycleChange.id);
        insert categoryForChange;

        //Create Change
        change = new PDLM__Change__c(Name = 'Test 123', PDLM__Category__c = categoryForChange.Id, PDLM__Title__c = 'Test');
        insert change;

        //Item Lifecycle and Category
        PDLM__Lifecycle__c lifecycleItem = new PDLM__Lifecycle__c(Name = 'Part');
        insert lifecycleItem;

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
        D1Item = new PDLM__Item__c(Name = 'D1 Item 1', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(D1Item);
        steamUSS2Item = new PDLM__Item__c(Name = 'Steam USS2 Item 1', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(steamUSS2Item);
       steamUSPCBAConfig1 = new PDLM__Item__c(Name = 'Steam US PCBA Config 1', PDLM__Category__c = categoryForPartItem.Id);
       itemsListToInsert.add(steamUSPCBAConfig1);
       steamUSPCBAConfig2 = new PDLM__Item__c(Name = 'Steam US PCBA Config 2', PDLM__Category__c = categoryForPartItem.Id);
       itemsListToInsert.add(steamUSPCBAConfig2);
               steamUSPCBAConfig3 = new PDLM__Item__c(Name = 'Steam US PCBA Config 3', PDLM__Category__c = categoryForPartItem.Id);
       itemsListToInsert.add(steamUSPCBAConfig3);
               steamUSPCBAConfig4 = new PDLM__Item__c(Name = 'Steam US PCBA Config 4', PDLM__Category__c = categoryForPartItem.Id);
       itemsListToInsert.add(steamUSPCBAConfig4);
               steamUSPCBAConfig5 = new PDLM__Item__c(Name = 'Steam US PCBA Config 5', PDLM__Category__c = categoryForPartItem.Id);
       itemsListToInsert.add(steamUSPCBAConfig5);
               steamUSPCBAConfig6 = new PDLM__Item__c(Name = 'Steam US PCBA Config 6', PDLM__Category__c = categoryForPartItem.Id);
       itemsListToInsert.add(steamUSPCBAConfig6);
        childItem1 = new PDLM__Item__c(Name = 'Child Item 1', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem1);
        childItem2 = new PDLM__Item__c(Name = 'Child Item 2', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem2);
        childItem3 = new PDLM__Item__c(Name = 'Child Item 3', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem3);
        childItem4 = new PDLM__Item__c(Name = 'Child Item 4', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem4);
        childItem5 = new PDLM__Item__c(Name = 'Child Item 5', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem5);
                childItem6 = new PDLM__Item__c(Name = 'Child Item 6', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem6);
                childItem7 = new PDLM__Item__c(Name = 'Child Item 7', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem7);
                childItem8 = new PDLM__Item__c(Name = 'Child Item 8', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem8);
                childItem9 = new PDLM__Item__c(Name = 'Child Item 9', PDLM__Category__c = categoryForPartItem.Id);
        itemsListToInsert.add(childItem9);
        insert itemsListToInsert;
       
        //Create Item Revisions
        List<PDLM__Item_Revision__c> revsListToInsert = new List<PDLM__Item_Revision__c>();
        parentItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = parentItem1.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(parentItem1Rev);
		PDLM__Item_Revision__c d1ItemRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = D1Item.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(d1ItemRev);
        PDLM__Item_Revision__c steamUSS2ItemRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = steamUSS2Item.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(steamUSS2ItemRev);
		        PDLM__Item_Revision__c steamUSPCBAConfig1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = steamUSPCBAConfig1.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(steamUSPCBAConfig1Rev);
        PDLM__Item_Revision__c steamUSPCBAConfig2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = steamUSPCBAConfig2.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(steamUSPCBAConfig2Rev);
        PDLM__Item_Revision__c steamUSPCBAConfig3Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = steamUSPCBAConfig3.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(steamUSPCBAConfig3Rev);
                PDLM__Item_Revision__c steamUSPCBAConfig4Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = steamUSPCBAConfig4.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(steamUSPCBAConfig4Rev);
                PDLM__Item_Revision__c steamUSPCBAConfig5Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = steamUSPCBAConfig5.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(steamUSPCBAConfig5Rev);
                PDLM__Item_Revision__c steamUSPCBAConfig6Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = steamUSPCBAConfig6.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(steamUSPCBAConfig6Rev);
 
        /*
        PDLM__Item_Revision__c jagItemRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = jagItem.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(jagItemRev);
        PDLM__Item_Revision__c whitneyItemRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = whitneyItem.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(whitneyItemRev);
        PDLM__Item_Revision__c steamItemRev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = steamItem.Id, PDLM__Revision__c = 'A', PDLM__Lifecycle_Phase__c = 'On-Hold');
        revsListToInsert.add(steamItemRev); */
        PDLM__Item_Revision__c childItem1Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem1.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Prototype',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                                          Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                          Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true
                                                                          );
        revsListToInsert.add(childItem1Rev);
        PDLM__Item_Revision__c childItem2Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem2.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Production',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                                          Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                          Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true);
        revsListToInsert.add(childItem2Rev);
        PDLM__Item_Revision__c childItem3Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem3.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Production',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                   						  Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                          Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true);
        revsListToInsert.add(childItem3Rev);
        PDLM__Item_Revision__c childItem4Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem4.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Production',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                   						  Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                          Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true);
        revsListToInsert.add(childItem4Rev);
        PDLM__Item_Revision__c childItem5Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem5.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Production',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                   						  Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                          Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true);
        revsListToInsert.add(childItem5Rev);
                PDLM__Item_Revision__c childItem6Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem6.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Production',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                   						  Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                                  Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true);
        revsListToInsert.add(childItem6Rev);
                PDLM__Item_Revision__c childItem7Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem7.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Production',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                   						  Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                          Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true);
        revsListToInsert.add(childItem7Rev);
                PDLM__Item_Revision__c childItem8Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem8.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Production',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                   						  Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                          Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true);
        revsListToInsert.add(childItem8Rev);
                PDLM__Item_Revision__c childItem9Rev = new PDLM__Item_Revision__c(PDLM__Master_Item__c = childItem9.Id, 
                                                                          PDLM__Revision__c = 'A', 
                                                                          PDLM__Lifecycle_Phase__c = 'Production',
                                                                          D1_Spec__c = D1Item.Id,
                                                                          Steam_US_S2_Spec__c = steamUSS2Item.Id,
                                                   						  Steam_US_PCBA_Config_1__c = steamUSPCBAConfig1.Id,
                                                                          Steam_US_PCBA_Config_2__c = steamUSPCBAConfig2.Id,
                                                                          Steam_US_PCBA_Config_3__c = steamUSPCBAConfig3.Id,
                                                                          Steam_US_PCBA_Config_4__c = steamUSPCBAConfig4.Id,
                                                                          Steam_US_PCBA_Config_5__c = steamUSPCBAConfig5.Id,
                                                                          Steam_US_PCBA_Config_6__c = steamUSPCBAConfig6.Id,
                                                                          PDLM__Released__c = true);
        revsListToInsert.add(childItem9Rev);
        insert revsListToInsert;

        //Add Assemblies
        List<PDLM__Assembly__c> assListToInsert = new List<PDLM__Assembly__c>();
        PDLM__Assembly__c ass1 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem1.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass1);
        ass2 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem2.Id, PDLM__Quantity__c = 1);
        assListToInsert.add(ass2);
        PDLM__Assembly__c ass3 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem4.Id, PDLM__Quantity__c = 1,Related_document__c=steamUSPCBAConfig1.Id);
        assListToInsert.add(ass3);
        PDLM__Assembly__c ass4 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem5.Id, PDLM__Quantity__c = 1,Related_document__c=steamUSPCBAConfig2.Id);
        assListToInsert.add(ass4);
                PDLM__Assembly__c ass5 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem6.Id, PDLM__Quantity__c = 1,Related_document__c=steamUSPCBAConfig3.Id);
        assListToInsert.add(ass5);
                PDLM__Assembly__c ass6 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem7.Id, PDLM__Quantity__c = 1,Related_document__c=steamUSPCBAConfig4.Id);
        assListToInsert.add(ass6);
                PDLM__Assembly__c ass7 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem8.Id, PDLM__Quantity__c = 1,Related_document__c=steamUSPCBAConfig5.Id);
        assListToInsert.add(ass7);
                PDLM__Assembly__c ass8 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem9.Id, PDLM__Quantity__c = 1,Related_document__c=steamUSPCBAConfig6.Id);
        assListToInsert.add(ass8);
        insert assListToInsert;
    }

    static PDLM__Item_Revision__c parentItem1Rev;
    static PDLM__Item_Revision__c childItem3Rev;
    static PDLM__Item__c d1Item;
    static PDLM__Item__c steamUSS2Item ;
    static PDLM__Item__c steamUSPCBAConfig1;
    static PDLM__Item__c steamUSPCBAConfig2;
        static PDLM__Item__c steamUSPCBAConfig3;
        static PDLM__Item__c steamUSPCBAConfig4;
        static PDLM__Item__c steamUSPCBAConfig5;
        static PDLM__Item__c steamUSPCBAConfig6;
    static PDLM__Item__c childItem1;
    static PDLM__Item__c childItem2;
    static PDLM__Item__c childItem3;
    static PDLM__Item__c childItem4;
    static PDLM__Item__c childItem5;
        static PDLM__Item__c childItem6;
        static PDLM__Item__c childItem7;
        static PDLM__Item__c childItem8;
        static PDLM__Item__c childItem9;
    static PDLM__Assembly__c ass2;
    static PDLM__Change__c change;

    @isTest static void testD1Update(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'D1 Spec';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, d1Item.Id);
        }
    }
	
	    @isTest static void testSteamUSS2Update(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US/S2 Spec';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSS2Item.Id);
        }
    }
    
    	    @isTest static void testSteamUSConfig1Update(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US PCBA Config 1';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSPCBAConfig1.Id);
        }
    }
    
        	    @isTest static void testSteamUSConfig2Update(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US PCBA Config 2';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSPCBAConfig2.Id);
        }
    }
    
            	    @isTest static void testSteamUSConfig3Update(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US PCBA Config 3';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSPCBAConfig3.Id);
        }
    }
	        	    @isTest static void testSteamUSConfig4Update(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US PCBA Config 4';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSPCBAConfig4.Id);
        }
    }
            	    @isTest static void testSteamUSConfig5Update(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US PCBA Config 5';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSPCBAConfig5.Id);
        }
    }
            	    @isTest static void testSteamUSConfig6Update(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US PCBA Config 6';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSPCBAConfig6.Id);
        }
    }
    
  /*  @isTest static void testJagUpdate(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Jag';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, jagItem.Id);
        }
    }

    @isTest static void testWhitneyUpdate(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Whitney';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, whitneyItem.Id);
        }
    }

    @isTest static void testSteamUpdate(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam';
        update parentItem1Rev;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamItem.Id);
        }
    }
*/
    @isTest static void testAssemblyInsert(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US/S2 Spec';
        update parentItem1Rev;

        PDLM__Assembly__c ass1 = new PDLM__Assembly__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Item__c = childItem3.Id, PDLM__Quantity__c = 1);
        insert ass1;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSS2Item.Id);
        }
    }

    @isTest static void testAssemblyReplace(){
        SetUpData();

        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US/S2 Spec';
        update parentItem1Rev;

        ass2.PDLM__Item__c = childItem3.Id;
        update ass2;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentItem1Rev.Id]){
            System.assertEquals(ass.Related_document__c, steamUSS2Item.Id);
        }
    }

    @isTest static void testChangeRelease(){
        SetUpData();
        
        Test.StartTest();

        parentItem1Rev.PCBA_Project_Type__c = 'Steam US/S2 Spec';
        update parentItem1Rev;

        ass2.PDLM__Item__c = childItem3.Id;
        update ass2;
        
        /*childItem3Rev.Steam_Spec__c = SteamUSS2Item.Id;
        update childItem3Rev;*/

        PDLM__Affected_Item__c ai = new PDLM__Affected_Item__c(PDLM__Item_Revision__c = parentItem1Rev.Id, PDLM__Change_Order_lk__c = change.Id);
        insert ai;

        PDLM__Change_Event__e event = new PDLM__Change_Event__e(PDLM__Record_Id__c = change.Id, PDLM__Is_Approved__c = true);
        List<Database.SaveResult> srs = Eventbus.publish(new List<PDLM__Change_Event__e> {event});

        Id parentRevId = parentItem1Rev.Id;
        Id childItemId = childItem3.Id;
        Id d1ItemId = D1Item.Id;
        Id steamUSS2ItemId = steamUSS2Item.Id;

        Test.stopTest();

        for (PDLM__Assembly__c ass : [SELECT Id, PDLM__Item__c, Related_document__c FROM PDLM__Assembly__c WHERE PDLM__Item_Revision__c = :parentRevId]){
            if (ass.PDLM__Item__c == childItemId){
                System.assertEquals(ass.Related_document__c, steamUSS2ItemId);
            }
            else{
                System.assertEquals(ass.Related_document__c, steamUSS2ItemId);
            }   
        }
    }

}