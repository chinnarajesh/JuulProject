/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Gunjan Sidhwani        06-19-2020                     */
/* Class Name: KamAccountPlanning                       */
/* Description: To Manage Account Planning process via Manage Action Plan Template quick action on Action Plan Template object */
/**********************************************************************/
Global class KAMAccountPlanning {
    public static String class_Name ='KAMAccountPlanning';
    Public static ID BatchID;
   
    public static string CommercialActivityIdSet {set;get;}
    
    //Method to get all associated retail store groups along with planogram,planogram products,assortment products, commercial activity items and mission tasks on Action Plan Template.
    @AuraEnabled
    public static string getALLRetailGroups(Id apt){
        
        
        Map<String,PricingMatrix__c> pricingMatricData2 = new Map<String,PricingMatrix__c>();        
        
        List<WrapperData> WrapList = new List<WrapperData>();
        List<Planogram__c> planogramList = new List<Planogram__c>();
        //Changed by jyoti
        Map<String,CommercialActivityProduct__c> caItems = new Map<String,CommercialActivityProduct__c>();//end
        List<AssortmentProduct__c> additionalProducts = new List<AssortmentProduct__c>();
        List<InStoreLocation__c> activeStoreLocations = new List<InStoreLocation__c>();
        Map<String,PricingMatrix__c> pricingMatricData = new Map<String,PricingMatrix__c>();
        Map<String,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPrice = new Map<string,Commercial_Activity_Product_Pricing__c>();
        Map<String,StoreProduct__c> stateMaintainData = new Map<String,StoreProduct__c>();
        Id assortmentId;
        Map<id,List<PlanogramProductFacing__c>> ppfMap = new Map<id,List<PlanogramProductFacing__c>>();
        Map<id,RetailLocationGroup__c> rsgMap = new Map<id,RetailLocationGroup__c>();
        
        //Added below for Image URL function
        Id currentPlanogramId;
        //  Id plannedPlanogramId;
        //  String currentPlanogramImgURL;
        // List<Planogram__c> currentPlanogram = new List<Planogram__c>();
        // String plannedPlanogramImgURL;
        //  List<Planogram__c> plannedPlanogram = new List<Planogram__c>();
        
        
        Map<Id,Id> retailGroupRetailTemplateMap= new Map<Id,Id>();
        Map<Id,String> retailTemplateStoreMap = new Map<Id,String>();
        String storeCategory;
        Map<Id,InStoreLocation__c> allStoreLocationsWithjunctionId = new Map<Id,InStoreLocation__c>();
        Map<Id,List<StoreProduct__c>> relatedSP = new Map<Id,List<StoreProduct__c>>();
        Map<Id,List<Asset>> relatedAsset = new Map<Id,List<Asset>>();
        Map<Id,List<MissionTask__c>> relatedMtasks = new Map<Id,List<MissionTask__c>>();
        Boolean OverrideField = false;
        Boolean APTChanges = false;
        //Added by Jyoti SFDC - 0000004342
        //start
        Map<Id,List<Asset__c>> relatedCustomAsset = new Map<Id,List<Asset__c>>();
        //end
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        ActionPlanTemplate__c selectedAPTQueried = [Select Id,APT_Changes__c,ISL_Batch_Flag__c,CurrencyIsoCode,CascadeFlag__c,Cascade_Changes__c,RecordType.Name,StoreAssortment__r.AssortmentId__c,CommercialActivityId__c,RequestedStartDate__c,CommercialActivityId__r.Strategy_Start_Date__c,
                                                    RequestedEndDate__c,Status__c,Override__c,In_Store_Locations_Created__c,Missions_Created__c from ActionPlanTemplate__c where Id =:apt];
        CommercialActivityIdSet=selectedAPTQueried.CommercialActivityId__c;
         String selectedAPTQueriedType = selectedAPTQueried.RecordType.Name; 
        String SelectedAPTStatus = selectedAPTQueried.Status__c;
        Boolean CascadeFlag = selectedAPTQueried.CascadeFlag__c;
        if(selectedAPTQueried.Override__c==true && selectedAPTQueried.Status__c =='Execution' )
        OverrideField = selectedAPTQueried.Override__c;
        APTChanges = selectedAPTQueried.APT_Changes__c;
        Boolean CascadeChanges = selectedAPTQueried.Cascade_Changes__c;
        Boolean ISLFlag = selectedAPTQueried.ISL_Batch_Flag__c;
        Boolean InstoreLocationsCreated =selectedAPTQueried.In_Store_Locations_Created__c;
        Boolean CommercialStrategyDate = selectedAPTQueried.CommercialActivityId__r.Strategy_Start_Date__c < Date.newInstance(2025, 01, 01);
        Boolean ProfileSalesOppAdmin =false;
        if(profileName =='Sales Ops Admin'){
            ProfileSalesOppAdmin =true;
        }
        Boolean MissionsCreated =selectedAPTQueried.Missions_Created__c;
        String CurrencyISOCode = selectedAPTQueried.CurrencyIsoCode;
        
        if(selectedAPTQueriedType == 'Account Plan')
            storeCategory ='Account Plan';
        if(selectedAPTQueriedType == 'Promotional Activity Process')
            storeCategory='Promotion';
        if(selectedAPTQueriedType == 'Reset Activity Process')
            storeCategory ='Reset';
        
        Map<ID,InStoreLocation__c> ISL = new Map<ID,InStoreLocation__c>();
        for(InStoreLocation__c i: [select RetailLocationId__c,id from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.id=:apt and RetailLocationId__r.Type != 'HQ'])
        {
            ISL.put(i.RetailLocationId__c,i);
        }
        
        //SOQL to get related Retail Store Groups on Action Plan Template via junction object AccountActionPlanTemplate__c
        //Added ActionPlanTemplateId__r.Override__c and ActionPlanTemplateId__r.Status__c in SOQL query for JPT-167 
        List<AccountActionPlanTemplate__c>  aapt =  new List<AccountActionPlanTemplate__c>([Select Id,cascadeToDoor__c,RetailLocationId__c,RetailLocationId__r.Name,ActionPlanTemplateId__r.Status__c,ActionPlanTemplateId__r.CommercialActivityId__r.Name,
                                                                                            RetailLocationId__r.Pricing_State__c,RetailLocationId__r.PlanogramId__r.Id,ActionPlanTemplateId__r.CommercialActivityId__r.Set_PTC_Modifier_Read_Only__c,
                                                                                            RetailLocationId__r.PlanogramId__r.Name,ActionPlanTemplateId__r.Override__c,Account__r.name,Grouped_State__c,Account__c from AccountActionPlanTemplate__c 
                                                                                            where ActionPlanTemplateId__c = :apt AND Grouped_State__c !=null AND Account__c !=null]);
        
        for(InStoreLocation__c s: [Select id,RetailStoreGroupActionPlanTemplate__c,PlanogramId__c,PlanogramId__r.Name,InStoreLocationType__c,(Select id, Product_Bundle__c,Product_Bundle_Description__c,STD_JUUL_Funding__c ,Retailer_Funding__c,Final_PTC__c,JUUL_Tax_Funding__c,Differentiator__c,DefaultOrderQuantity__c,SuggestedMSRP__c,Source_Product_Id__c from Store_Products__r where Active__c = true ),(Select Id,Quantity,Differentiator__c,Source_Product_Id__c,Unit_Price__c,CostForCollateral__c  From Assets__r where Active__c = true ),(Select Id,Quantity__c,Differentiator__c,Source_Product_Id__c,Unit_Price__c,CostForCollateral__c  From Assets1__r where Active__c = true) from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c IN :aapt AND Active__c = True AND Status__c = 'Planned' AND Category__c=:storeCategory]){
            system.debug('in instorelocation for loop');
            system.debug('action plan template '+s.RetailStoreGroupActionPlanTemplate__c);
            allStoreLocationsWithjunctionId.put(s.RetailStoreGroupActionPlanTemplate__c,s);
            if(s.Store_Products__r != null && s.Store_Products__r.size()>0)
                relatedSP.put(s.id,s.Store_Products__r);
            if(s.Assets__r != null && s.Assets__r.size()>0)
                relatedAsset.put(s.id,s.Assets__r);
            if(s.Assets1__r != null && s.Assets1__r.size()>0)
                relatedCustomAsset.put(s.id,s.Assets1__r);
        }
        system.debug('out instorelocation for loop');
        for(Mission__c m:[Select id,RetailStoreGroupActionPlanTemplate__c,(Select id,Source_Item_Id__c from Assessment_Tasks__r) from Mission__c where RetailStoreGroupActionPlanTemplate__c IN: aapt AND StartDate__c = :selectedAPTQueried.RequestedStartDate__c AND EndDate__c = :selectedAPTQueried.RequestedEndDate__c AND MissionType__c ='Strategy' AND Status__c = 'Planned']){
            relatedMtasks.put(m.RetailStoreGroupActionPlanTemplate__c,m.Assessment_Tasks__r);
        }
        
        //SOQL to get Planograms
        if(selectedAPTQueriedType == 'Reset Activity Process')
            planogramList = [Select id,Name,Name_of_POG__c from Planogram__c  where Active__c =True AND Country__c = 'US'];
        
        //SOQL to get products
        if(selectedAPTQueriedType != 'Promotional Activity Process'){
            if(selectedAPTQueried.StoreAssortment__r.AssortmentId__c != null){
                assortmentId = selectedAPTQueried.StoreAssortment__r.AssortmentId__c;
                additionalProducts =[Select id,ProductId__c ,ProductId__r.Name,AssortmentId__c from AssortmentProduct__c where AssortmentId__c =:assortmentId];
            }
        }
        
        //SOQL to get PricingMatrix Column values
        //Removed ListPrice__c after PriceMatrix update
        //Modified by Ramya -ticket SFDC-0000004199, SFDC-0000004200
        System.debug('selectedAPTQueried.RequestedStartDate__c-->' +selectedAPTQueried.RequestedStartDate__c);  //rm01
        
        DateTime dt = selectedAPTQueried.RequestedStartDate__c;  //rm02
        DateTime dtEnd = selectedAPTQueried.RequestedEndDate__c; //sr01
        system.debug('Date Instance-->'+dt);  //rm03
        Date newD = Date.valueOf(dt);         //rm04
        Date EndD = Date.valueOf(dtEnd);      //sr02
        Date Today = Date.valueOf(System.today()); //sr03
        system.debug('Date newD-->'+newD);    //rm05
        //For Pricing matrix 180 days warning
        Date ThreeMonthsDate = Date.today().addDays(180);
       
        Date pricingDate = Date.valueOf(ThreeMonthsDate);
        System.debug('** ThreeMonthsDate'+ThreeMonthsDate);
        System.debug('** pricingDate'+pricingDate);
        System.debug('** Today'+Today);
        
        for(PricingMatrix__c prm: [Select id,combo__c,GetxSavex__c,Start_Date__c,End_Date__c,MinimumMSRP2__c,ExpectedMaximumMSRP__c,PriceByState__c,StateTerritoryISO2__c,ProductId__c,
                                   ProductId__r.Name from PricingMatrix__c WHERE Start_Date__c < Today and End_Date__c > Today]){ //Active__c = True //rm06
                                       if(prm.ProductId__c !=null && prm.StateTerritoryISO2__c != null){
                                           String s = prm.ProductId__c + '-' + prm.StateTerritoryISO2__c;
                                           pricingMatricData.put(s,prm);
                                       }
                                   }

        Map<Id,CommercialActivityProduct__c> commercialActivityProductMap = new Map<id,CommercialActivityProduct__c>([select id,name,ProductId__c from CommercialActivityProduct__c where CommercialActivityId__c =: selectedAPTQueried.CommercialActivityId__c]);

        for(Commercial_Activity_Product_Pricing__c capp : [select id,name,State__c,Commercial_Activity_Product__r.ProductId__c,
       State_ISO2__c,Price__c  from Commercial_Activity_Product_Pricing__c where Commercial_Activity_Product__c IN: commercialActivityProductMap.keyset() AND Price__c != null ]){
                if(capp.Commercial_Activity_Product__r.ProductId__c !=null && capp.State_ISO2__c != null){
                    string  s = capp.Commercial_Activity_Product__r.ProductId__c+'-'+capp.State_ISO2__c;
                    //system.debug('commercial price data++ '+s);
                    commercialAcitvityProductPrice.put(s,capp);
                  }
             }
        
       /* for(ThreeMonthsDate prm: [Select id,combo__c,GetxSavex__c,Start_Date__c,End_Date__c,MinimumMSRP2__c,ExpectedMaximumMSRP__c,PriceByState__c,StateTerritoryISO2__c,ProductId__c,
                                   ProductId__r.Name from PricingMatrix__c WHERE  End_Date__c < ThreeMonthsDate ]){ 
                                       if(prm.ProductId__c !=null && prm.StateTerritoryISO2__c != null){
                                           String s = prm.ProductId__c + '-' + prm.StateTerritoryISO2__c;
                                           pricingMatricData2.put(s,prm);
                                       }
                                   }*/
        
       
        system.debug('commercialAcitvityProductPrice '+commercialAcitvityProductPrice.size());
        system.debug('@@pricingMatricData : '+pricingMatricData);
        system.debug('@@pricingMatricData size: '+pricingMatricData.size());
        
        //SOQL to get Commercial Activity Items
        //Added Product bundle and Description field in SOQL for SFDC - 0000004228
        //Changed by jyoti
       if(selectedAPTQueried.CommercialActivityId__c != null){
           caItems = new Map<String, CommercialActivityProduct__c>([Select Product_bundle_Description__c,id,ProductId__c ,ProductId__r.Name,ProductType__c,CommercialActivityId__c,HideItemWhilePlanning__c,CollateralUnitCost__c,Product_Bundle__c from CommercialActivityProduct__c  where CommercialActivityId__c= :selectedAPTQueried.CommercialActivityId__c order by ProductType__c asc]);
        }//end
        //SOQL to get Action Plan Template Items for an Action Plan Template
        List<ActionPlanTemplateItem__c> aptItems =new List<ActionPlanTemplateItem__c>([Select id,Name,Priority__c, Subject__c from ActionPlanTemplateItem__c where ActionPlanTemplateId__c =:apt]);
        
        if(aapt.size()>0){
            
            Set<id> planogramIds = new Set<id>();
            Set<id> rsgID = new Set<id>();
            
            //Check to remove null pointer exception (SFDC - 0000003169)
            for(AccountActionPlanTemplate__c a: aapt){
                if(allStoreLocationsWithjunctionId.size()>0 && allStoreLocationsWithjunctionId.containsKey(a.Id)){
                    planogramIds.add(allStoreLocationsWithjunctionId.get(a.id).PlanogramId__c);
                }
                rsgID.add(a.RetailLocationId__c);
            }
            //Check ended
            
            List<PlanogramProductFacing__c> planogramProducts = new List<PlanogramProductFacing__c>([Select id,ProductName__c,ProductName__r.Name,Facings__c,PlanogramName__c from PlanogramProductFacing__c where PlanogramName__c =:planogramIds]);
            for(PlanogramProductFacing__c ppf : planogramProducts){
                if(!ppfMap.containsKey(ppf.PlanogramName__c)){
                    List<PlanogramProductFacing__c> ppfList = new List<PlanogramProductFacing__c>();
                    ppfList.add(ppf);
                    ppfMap.put(ppf.PlanogramName__c,ppfList);
                }
                else{
                    List<PlanogramProductFacing__c> ppList = new List<PlanogramProductFacing__c>();
                    ppList = ppfMap.get(ppf.PlanogramName__c);
                    ppList.add(ppf);
                    ppfMap.put(ppf.PlanogramName__c,ppList);
                }
            }
            
            
            rsgMap = new Map<id,RetailLocationGroup__c>([Select id,Pricing_State__c from RetailLocationGroup__c where Id = :rsgID]);
            
            
            for(AccountActionPlanTemplate__c a: aapt){
                String accountState = '-' + a.Grouped_State__c;
                WrapperData Wraper = new WrapperData();
                Wraper.junctionId = a.Id;
                //Wraper.Id = a.RetailLocationId__c;
                Wraper.Id=a.id;
                Wraper.accountId=a.Account__c;
                //Wraper.name = a.RetailLocationId__r.Name;
                Wraper.name =a.Account__r.name+' - '+a.Grouped_State__c;
                Wraper.selected = True; 
                Wraper.expanded = True;
                System.debug('a.ActionPlanTemplateId__r.Override__c'+a.ActionPlanTemplateId__r.Override__c);
                //Added 'a.ActionPlanTemplateId__r.Override__c==false' for JPT 167
                if((a.cascadeToDoor__c == true && a.ActionPlanTemplateId__r.Status__c !='Execution') || (a.cascadeToDoor__c == true && a.ActionPlanTemplateId__r.Status__c=='Execution' && a.ActionPlanTemplateId__r.Override__c==false)){
                    Wraper.readOnly = true;
                    //Wraper.expanded = True;
                    Wraper.disablePog = True;
                }
                
                
                //Updated Name to be Name_of_POG__c
                //  Wraper.currentplanogram = allStoreLocationsWithjunctionId.get(a.Id).PlanogramId__r.Name_of_POG__c;
                
                //added below to query for the associated POG image
                currentPlanogramId = a.RetailLocationId__r.PlanogramId__r.Id;
                if(currentPlanogramId != null) {
                    Wraper.currentPlanogramId = currentPlanogramId;
                    Wraper.currentPlanogramURL = getPlanogramImgUrl(currentPlanogramId);
                }
                if(a.RetailLocationId__r.PlanogramId__r.Name != null)
                    Wraper.currentplanogram = a.RetailLocationId__r.PlanogramId__r.Name;
                
                List<Planograms> pList = new List<Planograms>();
                if(planogramList.size()>0){
                    //Add Planograms to wrapper
                    for(Planogram__c p  : planogramList){
                        Planograms planoWrapp = new Planograms();
                        planoWrapp.value = p.Id;
                        planoWrapp.label = p.Name;
                        pList.add(planoWrapp);
                    }
                }
                
                Wraper.selectedPlanogram = pList;
                if(allStoreLocationsWithjunctionId.get(a.Id)!=null){
                    Wraper.selected = True; 
                    Wraper.expanded = True;
                    if(selectedAPTQueriedType == 'Reset Activity Process')
                        Wraper.plannedPlanogramId = allStoreLocationsWithjunctionId.get(a.Id).PlanogramId__c;
                }
                
                //JJ Added below for testing Planned POG Image
                if(Wraper.plannedPlanogramId != null) {
                    Wraper.plannedPlanogramURL = getPlanogramImgUrl(Wraper.plannedPlanogramId);
                }
                //JJ Added above for testing Planned POG Image
                
                if(!Wraper.readOnly && Wraper.plannedPlanogramId!=null){
                    Wraper.disablePOG = False;
                    //JJ Added POG Img Below
                    Wraper.plannedPlanogramURL = getPlanogramImgUrl(Wraper.plannedPlanogramId);
                }
                //JJ Added POG Img Above
                else if(Wraper.readOnly)
                    Wraper.disablePOG = True;
                if(selectedAPTQueriedType == 'Reset Activity Process'){
                    List<Products> plannedPlanogramProducts = new List<Products>();
                    if(allStoreLocationsWithjunctionId.get(a.Id) != null && allStoreLocationsWithjunctionId.get(a.Id).InStoreLocationType__c =='Planogram Specific' && allStoreLocationsWithjunctionId.get(a.Id).PlanogramId__c != null && relatedSP.get(allStoreLocationsWithjunctionId.get(a.Id).id) != null){
                        for(StoreProduct__c s:relatedSP.get(allStoreLocationsWithjunctionId.get(a.Id).id)){
                            Wraper.plannedPlanogramId = allStoreLocationsWithjunctionId.get(a.Id).PlanogramId__c;
                            if(!Wraper.readOnly && Wraper.plannedPlanogramId!=null)
                                Wraper.disablePOG = False;
                            else if(Wraper.readOnly)
                                Wraper.disablePOG = True;
                            system.debug('@@plannedPlanogramId'+ Wraper.plannedPlanogramId);
                            
                            
                            String planogramProductJson = getPlanogramProductsforReset(ppfMap.get(allStoreLocationsWithjunctionId.get(a.Id).PlanogramId__c),rsgMap.get(a.RetailLocationId__c),pricingMatricData,commercialAcitvityProductPrice);
                            system.debug('@@planogramProductJson'+planogramProductJson);
                            List<Products> planogramProductList = (List<Products>) JSON.deserialize(planogramProductJson, List<Products>.class);
                            
                            for(Products ppf: planogramProductList){
                                if(ppf.parentId == s.Source_Product_Id__c){
                                    //Added by Shreya-pooja for ticket SFDC - 0000003131
                                    ppf.STDFunding = s.STD_JUUL_Funding__c;       //sr01
                                    ppf.TaxFunding = s.JUUL_Tax_Funding__c;       //sr02
                                    ppf.RetailerFunding = s.Retailer_Funding__c;  //sr03
                                    ppf.FinalPTC = s.final_PTC__c;                //sr04
                                    //ppf.differentiator = s.Differentiator__c;
                                    ppf.quantity = s.DefaultOrderQuantity__c;
                                    ppf.plannedPrice = s.SuggestedMSRP__c;
                                    plannedPlanogramProducts.add(ppf);
                                    system.debug('plannedPlanogramProducts'+plannedPlanogramProducts);
                                }
                                
                            }
                            system.debug('plannedPlanogramProducts'+plannedPlanogramProducts);
                            
                            if(plannedPlanogramProducts != null && plannedPlanogramProducts.size()>0){
                                Wraper.standardPog = True;
                                Wraper.planogramProducts = plannedPlanogramProducts;
                            }
                            
                        }
                        
                    }
                }
                //Add Products to wrapper
                if(selectedAPTQueriedType != 'Promotional Activity Process'){
                    List<Products> prdList = new List<Products>();
                    if(additionalProducts != null && additionalProducts.size()>0){
                        for(AssortmentProduct__c aptprd : additionalProducts){
                            Products aptpWrapp = new Products();
                            aptpWrapp.id = aptprd.ProductId__c;
                            aptpWrapp.name = aptprd.ProductId__r.Name;
                            aptpWrapp.parentId = aptprd.Id;
                            //Making selected false for ticket SFDC - 0000004464
                            aptpWrapp.selected = False;  //sr01
                            System.debug('aptpWrapp.selected 1'+aptpWrapp.selected);
                            if(allStoreLocationsWithjunctionId.get(a.Id) != null)
                                aptpWrapp.selected = False;
                            System.debug('aptpWrapp.selected 2'+aptpWrapp.selected);
                            //commented by juturi
                            // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(aptprd.ProductId__c + accountState)){
                            //     aptpWrapp.pricingId =pricingMatricData.get(aptprd.ProductId__c + accountState).Id;
                            //     Date startDate = Date.today();
                            //     Date endDate = pricingMatricData.get(aptprd.ProductId__c + accountState).End_Date__c;
                            //     Integer noOfDays = startDate.daysBetween( endDate );
                            //     system.debug('noOfDays'+noOfDays);
                            //     aptpWrapp.maximumExpectedMSRP = pricingMatricData.get(aptprd.ProductId__c + accountState).ExpectedMaximumMSRP__c;
                            //     // commented by juturi 
                            //     //aptpWrapp.minimumMSRP = pricingMatricData.get(aptprd.ProductId__c + accountState).MinimumMSRP2__c;
                            //     //aptpWrapp.listPrice = pricingMatricData.get(aptprd.ProductId__c + accountState).PriceByState__c;
                            //     //aptpWrapp.plannedPrice = aptpWrapp.listPrice;
                            //     if(noOfDays <180)
                            //     aptpWrapp.PriceMatrixExpiring = True;
                                
                            // }
                            //// added by juturi
                            if(!commercialAcitvityProductPrice.isEmpty() && commercialAcitvityProductPrice.containsKey(aptprd.ProductId__c + accountState)){
                                aptpWrapp.pricingId =commercialAcitvityProductPrice.get(aptprd.ProductId__c + accountState).Id;
                                aptpWrapp.listPrice = commercialAcitvityProductPrice.get(aptprd.ProductId__c + accountState).Price__c;
                                aptpWrapp.plannedPrice = aptpWrapp.listPrice;
                            }
                            //////
                            if(allStoreLocationsWithjunctionId.get(a.Id) != null && relatedSP.get(allStoreLocationsWithjunctionId.get(a.Id).id) != null){
                                for(StoreProduct__c s:relatedSP.get(allStoreLocationsWithjunctionId.get(a.Id).id)){
                                    if(aptprd.Id == s.Source_Product_Id__c){
                                        aptpWrapp.selected = True;   
                                        System.debug('aptpWrapp.selected 3'+aptpWrapp.selected);
                                        //Added by Shreya-pooja for ticket SFDC - 0000003131
                                        aptpWrapp.STDFunding = s.STD_JUUL_Funding__c;      //sr01
                                        aptpwrapp.TaxFunding = s.JUUL_Tax_Funding__c;      //sr02
                                        aptpwrapp.RetailerFunding = s.Retailer_Funding__c; //sr03
                                        aptpwrapp.FinalPTC = s.final_PTC__c;               //sr04
                                        //aptpWrapp.differentiator = s.Differentiator__c;
                                        aptpWrapp.quantity = s.DefaultOrderQuantity__c;
                                        aptpWrapp.plannedPrice = s.SuggestedMSRP__c;
                                    } 
                                    
                                }
                            }
                            system.debug('aptpWrapp.minimumMSRP'+aptpWrapp.minimumMSRP);
                            
                            prdList.add(aptpWrapp);
                        }
                        Wraper.Products = prdList;
                    }
                }
                //Add Commercial activity items to wrapper
                //Added by Jyoti for PB changes
                Set<String> pbDescriptionSet = new Set<String>();
                List<CommercialActivityProduct__c> catProductlist= new List<CommercialActivityProduct__c>();
                List<CommercialActivityItems> commItemList = new List<CommercialActivityItems>();
                String pbDesc;
                for(CommercialActivityProduct__c c : caItems.values())
                {
                    if(c.Product_bundle_Description__c != null)
                    {
                        pbDesc=c.Product_bundle_Description__c.toUppercase()+c.Product_Bundle__c;
                        pbDescriptionSet.add(pbDesc);
                    }
                    if(c.Product_bundle_Description__c == null)
                    {
                        catProductlist.add(c);
                    }
                }
                // System.debug('pbDescriptionSet ==> '+pbDescriptionSet);
                // System.debug('catProductlist'+ catProductlist);
                if(pbDescriptionSet!= null && pbDescriptionSet.size()>0)
                {
                    for(String d : pbDescriptionSet)
                    {
                        decimal liPrice=0;
                        String pId;
                        String parentId;
                        String pricingId;
                        CommercialActivityItems ciWrapp = new CommercialActivityItems();
                        if(caItems != null && caItems.size()>0 && d != null){
                            for(CommercialActivityProduct__c cap : caItems.values()){
                                if(cap.Product_bundle_Description__c+cap.Product_Bundle__c == d)
                                {
                                    pId = cap.ProductId__c+','+pId;
                                    parentId = cap.Id+','+parentId;
                                    //ciWrapp.name = cap.ProductId__r.Name ;
                                    ciWrapp.name = cap.Product_bundle_Description__c;
                                    
                                    liPrice=liPrice+cap.CollateralUnitCost__c;
                                    //Making selected false for ticket SFDC - 0000004464 
                                    ciWrapp.selected = False;   //sr01
                                    system.debug(' ciWrapp.selected 1'+ciWrapp.selected);
                                    //Added by Shreya for SFDC - 0000004228 
                                    ciWrapp.ProductBundle = cap.Product_Bundle__c;  //sr01
                                    ciWrapp.ProductDescription = cap.Product_bundle_Description__c;  //sr02
                                    if(allStoreLocationsWithjunctionId.get(a.Id) != null)
                                        ciWrapp.selected = False;
                                    system.debug(' ciWrapp.selected 2'+ciWrapp.selected);
                                    //commented by juturi
                                    // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(cap.ProductId__c + accountState)){
                                    //     pricingId =(pricingMatricData.get(cap.ProductId__c + accountState).Id)+','+pricingId;
                                    //     ciWrapp.maximumExpectedMSRP = pricingMatricData.get(cap.ProductId__c + accountState).ExpectedMaximumMSRP__c;
                                    //     Date startDate = Date.today();
                                    //     Date endDate = pricingMatricData.get(cap.ProductId__c + accountState).End_Date__c;
                                    //     Integer noOfDays = startDate.daysBetween( endDate );
                                    //     system.debug('noOfDays'+noOfDays);
                                    //      if(noOfDays <180)
                                    //      ciWrapp.PriceMatrixExpiring = True;
                                    //     //commented by jyoti
                                    //     //ciWrapp.listPrice=pricingMatricData.get(cap.ProductId__c + accountState).Id
                                    //     //ciWrapp.plannedPrice = ciWrapp.listPrice;
                                    //     //commented by juturi
                                    //     //ciWrapp.minimumMSRP = pricingMatricData.get(cap.ProductId__c + accountState).MinimumMSRP2__c;

                                    // }else {
                                    //     pricingId =null+','+pricingId;
                                    // }
                                    pricingId =null+','+pricingId;
                                    if(cap.ProductType__c == 'JUUL Product'){
                                        //Added by Shreya for SFDC - 0000004228 
                                        //commeted by juturi Sep 09-11-2023
                                        // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(cap.ProductId__c + accountState)){
                                        //     if(cap.Product_Bundle__c=='Combo')
                                        //     {    
                                        //         if(pricingMatricData.get(cap.ProductId__c + accountState).combo__c!=null){
                                        //             //liPrice = liPrice+pricingMatricData.get(cap.ProductId__c + accountState).combo__c;
                                        //             if(liprice < pricingMatricData.get(cap.ProductId__c + accountState).combo__c)  //sr01
                                        //             liPrice = pricingMatricData.get(cap.ProductId__c + accountState).combo__c;     //sr02
                                        //         } else{liPrice = 0;}
                                        //         System.debug('ciWrapp.listPrice Combo'+liPrice);
                                        //         //ciWrapp.plannedPrice = ciWrapp.listPrice;
                                        //     }
                                        //     else if(cap.Product_Bundle__c=='GetxSavex'){
                                        //         if(pricingMatricData.get(cap.ProductId__c + accountState).GetxSavex__c!=null){
                                        //            //liPrice = liPrice+pricingMatricData.get(cap.ProductId__c + accountState).GetxSavex__c;
                                        //             if(liprice < pricingMatricData.get(cap.ProductId__c + accountState).GetxSavex__c)  //sr01
                                        //             liPrice = pricingMatricData.get(cap.ProductId__c + accountState).GetxSavex__c;     //sr02
                                                    
                                        //         } else{liPrice = 0;}
                                        //         System.debug('ciWrapp.listPrice GetxSavex'+liPrice);
                                        //         //ciWrapp.plannedPrice = ciWrapp.listPrice;
                                        //     }
                                        //     else
                                        //     {
                                        //         //commented by juturi
                                        //         //liPrice = liPrice + pricingMatricData.get(cap.ProductId__c + accountState).PriceByState__c;
                                        //     }

                                        // }
                                        // added by juturi
                                        if(!commercialAcitvityProductPrice.isEmpty() && commercialAcitvityProductPrice.containsKey(cap.ProductId__c + accountState)){
                                            pricingId =(commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Id)+','+pricingId;
                                            System.debug('accountState '+accountState);
                                            System.debug('cap.ProductId__c '+cap.ProductId__c);
                                            System.debug('commercialAcitvityProductPrice '+commercialAcitvityProductPrice);

                                            liPrice = liPrice +commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Price__c;
                                        }
                                        //End of code for SFDC - 0000004228 
                                        ciWrapp.quantity = 1;
                                        ciWrapp.quantityDisabled = True;
                                        //ciWrapp.differentiatorDisabled = False;\
                                        //commenting below three lines for JTP 167
                                        //ciWrapp.STDFundingDisabled = False;
                                        //ciWrapp.TaxFundingDisabled = False;
                                        //ciWrapp.RetailerFundingDisabled = False;
                                        if(allStoreLocationsWithjunctionId.get(a.Id) != null && relatedSP.get(allStoreLocationsWithjunctionId.get(a.Id).id) != null){
                                            for(StoreProduct__c s:relatedSP.get(allStoreLocationsWithjunctionId.get(a.Id).id)){
                                                if(cap.Id == s.Source_Product_Id__c){
                                                    //Added by Shreya-pooja for ticket SFDC - 0000003131
                                                    ciWrapp.STDFunding = s.STD_JUUL_Funding__c;       //sr01
                                                    ciWrapp.TaxFunding = s.JUUL_Tax_Funding__c;       //sr02
                                                    ciWrapp.RetailerFunding = s.Retailer_Funding__c;  //sr03
                                                    ciwrapp.FinalPTC = s.Final_PTC__c;                //sr04
                                                    ciWrapp.selected = True;   
                                                    system.debug(' ciWrapp.selected 3'+ciWrapp.selected);
                                                    //ciWrapp.differentiator = s.Differentiator__c;
                                                    ciWrapp.quantity = s.DefaultOrderQuantity__c;
                                                    ciWrapp.plannedPrice = s.SuggestedMSRP__c;
                                                }
                                                
                                            }
                                        }
                                    }//Commented by Jyoti for Product Bundle
                                    /*if(cap.ProductType__c == 'Trade Collateral'){
                                    ciWrapp.quantityDisabled = False;
                                    ciWrapp.differentiatorDisabled = True;
                                    //for ticket SFDC - 0000003131
                                    ciWrapp.STDFundingDisabled = True;
                                    ciWrapp.TaxFundingDisabled = True;
                                    ciWrapp.RetailerFundingDisabled = True;
                                    if(allStoreLocationsWithjunctionId.get(a.Id) != null && relatedAsset.get(allStoreLocationsWithjunctionId.get(a.Id).id) != null){
                                    for(Asset at:relatedAsset.get(allStoreLocationsWithjunctionId.get(a.Id).id)){
                                    if(cap.Id == at.Source_Product_Id__c){
                                    ciWrapp.selected = True;   
                                    ciWrapp.STDFunding = at.Differentiator__c;
                                    ciWrapp.quantity = at.quantity;
                                    liPrice = liPrice+at.Unit_Price__c;
                                    ciWrapp.plannedPrice = at.CostForCollateral__c;
                                    }

                                    }
                                    }

                                    }*/
                                    if(a.cascadeToDoor__c == True){
                                        ciWrapp.differentiatorDisabled = True;
                                        ciWrapp.quantityDisabled = True;
                                        //for ticket SFDC - 0000003131
                                        ciWrapp.STDFundingDisabled = True;
                                        ciWrapp.PTCModifierDisabled = True;
                                        ciWrapp.TaxFundingDisabled = True;
                                        ciWrapp.RetailerFundingDisabled = True;
                                        
                                    }
                                    //Start- added by JC for SFDC - 0000005444
                                    if(a.cascadeToDoor__c == True || SelectedAPTStatus == 'APT Approved & Locked' || SelectedAPTStatus == 'Execution'){
                                    ciWrapp.STDFundingDisabled = True;
                                    }
                                    // added by juturi rajesh JTP-1987
                                    if(a.ActionPlanTemplateId__r.CommercialActivityId__r.Set_PTC_Modifier_Read_Only__c){
                                    ciWrapp.PTCModifierDisabled = True;
                                    }
                                    //End - added by JC for SFDC - 0000005444
                                    ciWrapp.productType = cap.Product_Bundle__c;
                                    //system.debug('pricingMatricData'+pricingMatricData);
                                }
                            }
                            ciWrapp.listPrice = liPrice;
                            ciWrapp.plannedPrice =  ciWrapp.listPrice;
                            ciWrapp.id = pId.removeEnd(',null');
                            ciWrapp.parentId =parentId.removeEnd(',null');
                            ciWrapp.pricingId = pricingId.removeEnd(',null');
                            // System.debug('ciWrapp.id==>'+ciWrapp.id);
                            // System.debug('ciWrapp.parentId==>'+ciWrapp.parentId);
                            // System.debug('ciWrapp.pricingId==>'+ciWrapp.pricingId);
                            // System.debug('ciWrapp==>'+ciWrapp);
                            commItemList.add(ciWrapp);
                            System.debug('commItemList==>'+commItemList);
                        }
                    }
                    //Wraper.commercialActivityItems = commItemList;
                }
                // To add all the products without Product Bundle
                if(catProductlist != null && catProductlist.size()>0){
                    for(CommercialActivityProduct__c cap : catProductlist){
                        {
                            if(!cap.HideItemWhilePlanning__c){
                                
                                CommercialActivityItems ciWrapp = new CommercialActivityItems();
                                ciWrapp.id = cap.ProductId__c;
                                ciWrapp.name = cap.ProductId__r.Name ;
                                ciWrapp.parentId = cap.Id;
                                ciWrapp.listPrice = cap.CollateralUnitCost__c;
                                ciWrapp.plannedPrice =  ciWrapp.listPrice;
                                //Making selected false for ticket SFDC - 0000004464 
                                ciWrapp.selected = False;   //sr01
                                system.debug(' ciWrapp.selected 1'+ciWrapp.selected);
                                //Added by Shreya for SFDC - 0000004228 
                                ciWrapp.ProductBundle = cap.Product_Bundle__c;  //sr01
                                ciWrapp.ProductDescription = cap.Product_bundle_Description__c;  //sr02
                                if(allStoreLocationsWithjunctionId.get(a.Id) != null)
                                    ciWrapp.selected = False;
                                system.debug(' ciWrapp.selected 2'+ciWrapp.selected);
                                // commented by juturi
                                // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(cap.ProductId__c + accountState)){
                                //     ciWrapp.pricingId =pricingMatricData.get(cap.ProductId__c + accountState).Id;
                                //     Date startDate = Date.today();
                                //         Date endDate = pricingMatricData.get(cap.ProductId__c + accountState).End_Date__c;
                                //         Integer noOfDays = startDate.daysBetween( endDate );
                                //         system.debug('noOfDays'+noOfDays);
                                //     if(noOfDays <180)
                                //     ciWrapp.PriceMatrixExpiring = True;
                                //     ciWrapp.minimumMSRP = pricingMatricData.get(cap.ProductId__c + accountState).MinimumMSRP2__c;
                                //     ciWrapp.maximumExpectedMSRP = pricingMatricData.get(cap.ProductId__c + accountState).ExpectedMaximumMSRP__c;
                                //     // commented by juturi
                                //     // ciWrapp.listPrice = pricingMatricData.get(cap.ProductId__c + accountState).PriceByState__c;
                                //     // ciWrapp.plannedPrice = ciWrapp.listPrice;
                                // } 
                                // added by juturi this data displaying
                                // system.debug('state data +'+cap.ProductId__c + accountState);
                                if(!commercialAcitvityProductPrice.isEmpty() && commercialAcitvityProductPrice.containsKey(cap.ProductId__c + accountState)){
                                    ciWrapp.pricingId =commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Id;
                                    ciWrapp.listPrice = commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Price__c;
                                    system.debug('data set '+cap.ProductId__c + accountState +' commercial Id '+commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).id);
                                    //system.debug('map data++'+ commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Price__c);
                                    system.debug('comerical price++'+ciWrapp.listPrice);
                                    ciWrapp.plannedPrice = ciWrapp.listPrice;
                                }
                                if(cap.ProductType__c == 'JUUL Product'){
                                    system.debug('Juul Product++');
                                    //Added by Shreya for SFDC - 0000004228 
                                    // commented by juturi
                                    // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(cap.ProductId__c + accountState)){
                                    //     if(cap.Product_Bundle__c=='Combo')
                                    //     {    
                                    //         if(pricingMatricData.get(cap.ProductId__c + accountState).combo__c!=null){
                                    //             ciWrapp.listPrice = pricingMatricData.get(cap.ProductId__c + accountState).combo__c;
                                    //         } else{
                                    //             ciWrapp.listPrice = 0;
                                    //         }
                                    //         System.debug('ciWrapp.listPrice Combo'+ciWrapp.listPrice);
                                    //         ciWrapp.plannedPrice = ciWrapp.listPrice;
                                    //     }
                                    //     else if(cap.Product_Bundle__c=='GetxSavex'){
                                    //         if(pricingMatricData.get(cap.ProductId__c + accountState).GetxSavex__c!=null){
                                    //             ciWrapp.listPrice = pricingMatricData.get(cap.ProductId__c + accountState).GetxSavex__c;
                                    //         } else{
                                    //             ciWrapp.listPrice = 0;
                                    //         }
                                    //         System.debug('ciWrapp.listPrice GetxSavex'+ciWrapp.listPrice);
                                    //         ciWrapp.plannedPrice = ciWrapp.listPrice;
                                    //     }
                                    // }
                                    //added by juturi
                                    if(!commercialAcitvityProductPrice.isEmpty() && commercialAcitvityProductPrice.containsKey(cap.ProductId__c + accountState)){
                                        ciWrapp.listPrice = commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Price__c;
                                        ciWrapp.plannedPrice = ciWrapp.listPrice;
                                    }
                                    //End of code for SFDC - 0000004228 
                                    ciWrapp.quantity = 1;
                                    ciWrapp.quantityDisabled = True;
                                    //ciWrapp.differentiatorDisabled = False;
                                    ciWrapp.STDFundingDisabled = False;
                                    ciWrapp.TaxFundingDisabled = False;
                                    ciWrapp.RetailerFundingDisabled = False;
                                    if(allStoreLocationsWithjunctionId.get(a.Id) != null && relatedSP.get(allStoreLocationsWithjunctionId.get(a.Id).id) != null){
                                        for(StoreProduct__c s:relatedSP.get(allStoreLocationsWithjunctionId.get(a.Id).id)){
                                            if(cap.Id == s.Source_Product_Id__c){
                                                //Added by Shreya-pooja for ticket SFDC - 0000003131
                                                ciWrapp.STDFunding = s.STD_JUUL_Funding__c;       //sr01
                                                ciWrapp.TaxFunding = s.JUUL_Tax_Funding__c;       //sr02
                                                ciWrapp.RetailerFunding = s.Retailer_Funding__c;  //sr03
                                                ciwrapp.FinalPTC = s.Final_PTC__c;                //sr04
                                                ciWrapp.selected = True;   
                                                //system.debug(' ciWrapp.selected 3'+ciWrapp.selected);
                                                //system.debug(s.Source_Product_Id__c +' s.STD_JUUL_Funding__c'+s.STD_JUUL_Funding__c);
                                                //ciWrapp.differentiator = s.Differentiator__c;
                                                ciWrapp.quantity = s.DefaultOrderQuantity__c;
                                                ciWrapp.plannedPrice = s.SuggestedMSRP__c;
                                            }
                                            
                                        }
                                    }
                                }
                                if(cap.ProductType__c == 'Trade Collateral'){
                                    system.debug('Trade Collateral +++');
                                    ciWrapp.quantityDisabled = False;
                                    ciWrapp.differentiatorDisabled = True;
                                    //for ticket SFDC - 0000003131
                                    ciWrapp.STDFundingDisabled = True;
                                    ciWrapp.TaxFundingDisabled = True;
                                    ciWrapp.RetailerFundingDisabled = True;
                                    if(allStoreLocationsWithjunctionId.get(a.Id) != null && relatedAsset.get(allStoreLocationsWithjunctionId.get(a.Id).id) != null){
                                        System.debug('InstoreLocation++ '+allStoreLocationsWithjunctionId.get(a.Id).id);
                                        for(Asset at:relatedAsset.get(allStoreLocationsWithjunctionId.get(a.Id).id)){
                                            System.debug('asset id++'+at.id);
                                            if(cap.Id == at.Source_Product_Id__c){
                                                ciWrapp.selected = True;   
                                                ciWrapp.STDFunding = at.Differentiator__c;
                                                ciWrapp.quantity = at.quantity;
                                                ciWrapp.listPrice = at.Unit_Price__c;
                                                ciWrapp.plannedPrice = at.CostForCollateral__c;
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                if(a.cascadeToDoor__c == True){
                                    ciWrapp.differentiatorDisabled = True;
                                    ciWrapp.quantityDisabled = True;
                                    //for ticket SFDC - 0000003131
                                    ciWrapp.STDFundingDisabled = True;
                                    ciWrapp.TaxFundingDisabled = True;
                                    ciWrapp.RetailerFundingDisabled = True;
                                    
                                }
                                //Start- added by JC for SFDC - 0000005444
                                if(a.cascadeToDoor__c == True || SelectedAPTStatus == 'APT Approved & Locked' || SelectedAPTStatus == 'Execution'){
                                    ciWrapp.STDFundingDisabled = True;
                                }
                                // added by juturi rajesh JTP-1987
                                if(a.ActionPlanTemplateId__r.CommercialActivityId__r.Set_PTC_Modifier_Read_Only__c){
                                ciWrapp.PTCModifierDisabled = True;
                                }
                                //End - added by JC for SFDC - 0000005444
                                ciWrapp.productType = cap.ProductType__c;
                                //system.debug('pricingMatricData'+pricingMatricData);
                                
                                commItemList.add(ciWrapp);
                            }
                        }}
                    //Wraper.commercialActivityItems = commItemList;
                }
                Wraper.commercialActivityItems = commItemList;
                System.debug('commItemList'+commItemList);
                //Add Items to wrapper
                //Commented by juturi rajesh JTP-1570
                // List<Items> aptiList = new List<Items>();
                // if(aptItems != null && aptItems.size()>0){
                //     for(ActionPlanTemplateItem__c aptItem : aptItems){
                //         Items aptiWrapp = new Items();
                //         aptiWrapp.id = aptItem.id;
                //         aptiWrapp.name = aptItem.Name;
                //         aptiWrapp.priority =aptItem.Priority__c;
                //         aptiWrapp.subject =aptItem.Subject__c;
                //         //Making selected false for ticket SFDC - 0000004464
                //         aptiWrapp.selected = False;  //sr01
                //         System.debug('aptiWrapp.selected 1'+aptiWrapp.selected);
                //         if(!relatedMtasks.isEmpty() && relatedMtasks.containsKey(a.Id)){
                //             aptiWrapp.selected = false;
                //             if(relatedMtasks.get(a.Id).size()>0){
                //                 for(MissionTask__c mt: relatedMtasks.get(a.Id)){
                //                     if(aptiWrapp.id == mt.Source_Item_Id__c)
                //                         aptiWrapp.selected = True; 
                //                     System.debug('aptiWrapp.selected 2'+aptiWrapp.selected);
                //                 }
                //             }
                //         }
                //         aptiList.add(aptiWrapp);
                //     }
                //     Wraper.items = aptiList;
                // }
                
                WrapList.add(Wraper);
                system.debug('Wraper'+Wraper);
            }
        }
        
        WraperDataWithAPTInfo wda= new WraperDataWithAPTInfo();
        wda.recordTypeName = selectedAPTQueriedType;
        wda.APTstatus = SelectedAPTStatus;
        wda.CascadeFlag = CascadeFlag;
        wda.CascadeChanges = CascadeChanges;
        wda.ISLFlag = ISLFlag;
        wda.InstoreLocationsCreated=InstoreLocationsCreated;
        wda.ProfileSalesOppAdmin=ProfileSalesOppAdmin;
        wda.MissionsCreated=MissionsCreated;
        wda.OverrideField = OverrideField;
        wda.APTChanges = APTChanges;
        wda.CommercialStrategyDate = CommercialStrategyDate;
        wda.CurrencyISOCode = CurrencyISOCode;
        wda.wraperList = WrapList;
             
        if(selectedAPTQueried.Status__c == 'APT Approved & Locked' && selectedAPTQueried.In_Store_Locations_Created__c==true && selectedAPTQueried.Missions_Created__c==false )
            wda.cascadeToDoorDisable = False;
        else
            wda.cascadeToDoorDisable = True;
        if(selectedAPTQueriedType == 'Promotional Activity Process'){
            wda.storeProductsVisible  = False;
            wda.planogramVisible = False;
        }
        
        if(selectedAPTQueriedType == 'Account Plan'){
            wda.planogramVisible = False;
            wda.storeProductsVisible  = True;
        }
        if(selectedAPTQueriedType == 'Reset Activity Process'){
            wda.planogramVisible = True;
            wda.storeProductsVisible  = True;
        }
        
        system.debug('Wraper'+JSON.serializePretty(wda));
        return JSON.serializePretty(wda);
    }
    // Method to create planned records(Mission,InstoreLocation, Store Product, Assets,Misson Tasks) for HQ accounts of selected retail store groups on APT record.
    @AuraEnabled
    public static void saveData(Id aptId, List<WrapperData> selectedData){
        String method_Name='saveData';
        String operationType = 'Database.Insert_Failed';
        List<WrapperData> partialData = new List<WrapperData>();
        system.debug('selectedData'+selectedData);
        List<InStoreLocation__c> slList = new List<InStoreLocation__c>();
        List<StoreProduct__c> spToInsert = new List<StoreProduct__c>();
        List<Asset> assetToInsert = new List<Asset>();
        //Added for ticket SFDC - 0000003394    
        List<Mission__c> missionToInsert = new List<Mission__c>();//commented for reversed approach
        Map<id,id> rgMap = new Map<Id,id>();
        Set<id> selectedRsgList = new Set<Id>();
        Set<Id> junctionIds = new Set<Id>();
        Map<StoreProduct__c,InStoreLocation__c> storeProductStoreLocation = new Map<StoreProduct__c,InStoreLocation__c>();
        Map<Asset,InStoreLocation__c> assetStoreLocation = new Map<Asset,InStoreLocation__c>();
        Map<String,InStoreLocation__c> allStoreLocationsWithjunctionId = new Map<String,InStoreLocation__c>();
        Set<InStoreLocation__c> storeLocationsSetToUpsert = new Set<InStoreLocation__c>();
        //List<InStoreLocation__c> storeLocationsListToUpsert = new List<InStoreLocation__c>();
        Map<id,List<StoreProduct__c>> existingRelatedStoreProducts = new Map<id,List<StoreProduct__c>>();
        List<StoreProduct__c> RelatedStoreProductstoDelete = new List<StoreProduct__c>();
        List<Asset> RelatedAssetstoDelete = new List<Asset>();
        Map<id,List<Asset>> existingAssets = new Map<id,List<Asset>>();
        List<Mission__c> existingMissions = new List<Mission__c>();
        Map<id,String> accComplianceMap = new Map<id,String>();
        Map<id,String> rsgAccountStateMap = new Map<id,String>();
        Map<id,Product2> banProductList;
        Set<Id> allSelectedProducts = new Set<Id>();
        List<InStoreLocation__c> sltoDeactivateList = new List<InStoreLocation__c>();
        List<Data_Mapping__mdt> APTMissionMapping = new List<Data_Mapping__mdt>();
        List<Data_Mapping__mdt> aptiMtaskMapping = new List<Data_Mapping__mdt>();
        Map<String,String> APTMissionFieldsMap = new Map<String,String>();
        Map<String,String> APTIMtaskFieldsMap = new Map<String,String>();
        List<ActionPlanTemplateItem__c> selectedAPTIListQueried = new List<ActionPlanTemplateItem__c>();
        Map<Id,ActionPlanTemplateItem__c> aptItemsMap = new Map<Id,ActionPlanTemplateItem__c>();
        Map<Id,List<Items>> rsgAptItems = new  Map<Id,List<Items>>();
        Map<String,Mission__c> mapKeyMission = new Map<String,Mission__c>();
        Set<Id> allAPTIList = new Set<Id>();
        Map<Id,Id> rsgPlanogramsToUpdate = new Map<Id,Id>();
        List<CommercialActivityProduct__c> caItems = new List<CommercialActivityProduct__c>();
        Map<Id,CommercialActivityProduct__c> caItemsSTDfunding = new  Map<Id,CommercialActivityProduct__c>();//added by JC for SFDC - 0000005444
        Map<String,PricingMatrix__c> pricingMatricData = new Map<String,PricingMatrix__c>();
        Map<String,List<StoreProduct__c>> StoreLocationStoreProductMap = new Map<String,List<StoreProduct__c>>();
        Map<String,List<Asset>> StoreLocationAssetMap = new Map<String,List<Asset>>();
        Map<String, InStoreLocation__c> storeLocationsListToUpsert = new Map<String,InStoreLocation__c>();
        // added by juturi
        Map<String,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPrice = new Map<string,Commercial_Activity_Product_Pricing__c>();



        //Added by Jyoti SFDC - 0000004342
        //start
        List<Asset__c> customAssetToInsert = new List<Asset__c>();
        Map<Asset__c,InStoreLocation__c> customAssetStoreLocation = new Map<Asset__c,InStoreLocation__c>();
        List<Asset__c> RelatedCustomAssetstoDelete = new List<Asset__c>();
        Map<id,List<Asset__c>> existingCustomAssets = new Map<id,List<Asset__c>>();
        Map<String,List<Asset__c>> StoreLocationCustomAssetMap = new Map<String,List<Asset__c>>();
        //end
        boolean isTrue = false;//added by JC for SFDC - 0000005444
        //Added for ticket SFDC - 0000003394    
        Map<String,List<Mission__c>> StoreLocationMissionMap = new Map<String,List<Mission__c>>();//commented for reversed approach  
        String storeCategory='';
        String sourceAPT = '';
        String sourceAPTI ='';
        String APTRecordType;
        Id APRecordType;
        Id missionRecordType;
        
        //Get Action plan fields mappings from custom metadata types.
        APTMissionMapping=[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt where Source_Object__c='ActionPlanTemplate__c' AND Target_Object__c ='Mission__c'];
        for(Data_Mapping__mdt data: APTMissionMapping){
            APTMissionFieldsMap.put(data.Source_Field__c,data.Target_Field__c);
            sourceAPT += data.Source_Field__c+',';
        }
        if(sourceAPT.endsWith(',')){
            sourceAPT = sourceAPT.substring(0, sourceAPT.length() - 1);
        }
        
        String queryAPT = 'Select Id,RecordType.DeveloperName,CommercialActivityId__c,STD_JUUL_Funding_Check__c,'  +sourceAPT+' From ActionPlanTemplate__c Where id =:aptId';//Start- added STD_JUUL_Funding_Check__c in query by JC for SFDC - 0000005444
        ActionPlanTemplate__c selectedAPTQueried =Database.query(queryAPT);
        APTRecordType = selectedAPTQueried.recordType.DeveloperName;
        APRecordType =  Schema.SObjectType.ActionPlan__c.getRecordTypeInfosByDeveloperName().get(APTRecordType).getRecordTypeId();
        missionRecordType = Schema.SObjectType.Mission__c.getRecordTypeInfosByDeveloperName().get(APTRecordType).getRecordTypeId();
        if(APTRecordType == 'AccountPlan')
            storeCategory = 'Account Plan';
        if(APTRecordType == 'PromotionalActivityProcess')
            storeCategory='Promotion';
        if(APTRecordType == 'ResetActivityProcess')
            storeCategory ='Reset';
        
        //Get Mapping of Action plan template items.
        aptiMtaskMapping =[Select Source_Field__c,Target_Field__c from Data_Mapping__mdt where Source_Object__c='ActionPlanTemplateItem__c' AND Target_Object__c ='MissionTask__c'];
        for(Data_Mapping__mdt data :aptiMtaskMapping){
            aptiMtaskFieldsMap.put(data.Source_Field__c,data.Target_Field__c);
            sourceAPTI += data.Source_Field__c+',';
        }
        if(sourceAPTI.endsWith(',')){
            sourceAPTI = sourceAPTI.substring(0, sourceAPTI.length() - 1);
        }
        
        String queryAPIMapping = 'Select Id,'  +sourceAPTI+' From ActionPlanTemplateItem__c Where ActionPlanTemplateId__c = \''+selectedAPTQueried.Id+'\'';
        system.debug('queryAPIMapping'+queryAPIMapping);
        selectedAPTIListQueried =Database.query(queryAPIMapping);
        aptItemsMap = new Map<Id,ActionPlanTemplateItem__c>(selectedAPTIListQueried);
        
        //Modified by Ramya -ticket SFDC-0000004199, SFDC-0000004200
        System.debug('selectedAPTQueried.RequestedStartDate__c on save--------> ' +selectedAPTQueried.RequestedStartDate__c);  //rm01
        DateTime dt = selectedAPTQueried.RequestedStartDate__c;  //rm02
        DateTime dtEnd = selectedAPTQueried.RequestedEndDate__c; //sr01
        system.debug('Date Instance-->'+dt);  //rm03
        Date newD = Date.valueOf(dt);         //rm04
        Date EndD = Date.valueOf(dtEnd);      //sr02
        Date Today = Date.valueOf(System.today()); //sr03
        system.debug('Date newD-->'+newD);    //rm05
        system.debug('Date  Today-->'+Today);    //sr04
        // added bu juturi
        Map<Id,CommercialActivityProduct__c> commercialActivityProductMap = new Map<id,CommercialActivityProduct__c>([select id,name,ProductId__c from CommercialActivityProduct__c where CommercialActivityId__c =:selectedAPTQueried.CommercialActivityId__c]);

        for(Commercial_Activity_Product_Pricing__c capp : [select id,name,State__c,Commercial_Activity_Product__r.ProductId__c,State_ISO2__c,Price__c  from Commercial_Activity_Product_Pricing__c where Commercial_Activity_Product__c IN: commercialActivityProductMap.keyset()]){
                if(capp.Commercial_Activity_Product__r.ProductId__c !=null && capp.State_ISO2__c != null){
                    string  s = capp.Commercial_Activity_Product__r.ProductId__c+'-'+capp.State_ISO2__c;
                    commercialAcitvityProductPrice.put(s,capp);
                  }
             }
        // ended by juturi     
        //Updated query to fetch product bundle data for ticket SFDC - 0000004228 by shreya
        for(PricingMatrix__c prm: [Select id,Start_Date__c,End_Date__c,MinimumMSRP2__c,ExpectedMaximumMSRP__c,PriceByState__c,StateTerritoryISO2__c,ProductId__c,combo__c,GetxSavex__c from PricingMatrix__c WHERE Start_Date__c < Today and End_Date__c > Today]){    //rm06
            if(prm.ProductId__c !=null && prm.StateTerritoryISO2__c != null)
            { String s = prm.ProductId__c + '-' + prm.StateTerritoryISO2__c;
             pricingMatricData.put(s,prm);
            }
        }
        if(selectedAPTQueried.CommercialActivityId__c != null){
            caItems = [Select id,ProductId__c ,ProductId__r.Name,ProductType__c,CommercialActivityId__c,CollateralUnitCost__c  from CommercialActivityProduct__c  where CommercialActivityId__c= :selectedAPTQueried.CommercialActivityId__c AND HideItemWhilePlanning__c = true ];
        }
        //Start - added by JC for SFDC - 0000005444
        if(selectedAPTQueried.CommercialActivityId__c != null){
            caItemsSTDfunding = new Map<Id,CommercialActivityProduct__c>([Select id,ProductId__c ,ProductId__r.Name,ProductType__c,CommercialActivityId__c,CollateralUnitCost__c,Max_STD_JUUL_Funding__c, Min_STD_JUUL_Funding__c  from CommercialActivityProduct__c  where CommercialActivityId__c= :selectedAPTQueried.CommercialActivityId__c]);
        }//end - added by JC for SFDC - 0000005444
        
        for(WrapperData wd: selectedData){
            if(wd.selected && !wd.readOnly){
                system.debug('wd'+wd);
                
                selectedRsgList.add(wd.Id);
                junctionIds.add(wd.junctionId);
                //commented by juturi rajesh JTP-1570
                // if(wd.Items != null && wd.Items.size()>0){
                //     for(Items i: wd.Items){
                //         if(i.selected){
                //             allAPTIList.add(i.Id);
                //             if(!rsgAptItems.containsKey(wd.Id))
                //                 rsgAptItems.put(wd.Id,new List<KAMAccountPlanning.Items>());
                //             rsgAptItems.get(wd.Id).add(i);
                //         }
                //     }
                // }
                if(wd.planogramProducts != null && wd.planogramProducts.size()>0){
                    for(Products p : wd.planogramProducts){
                        allSelectedProducts.add(p.id);
                    }
                }
                
                if(wd.products != null &&  wd.products.size()>0){
                    for(Products p: wd.products){
                        if(p.selected)
                            allSelectedProducts.add(p.id);
                    }
                }
                if(wd.CommercialActivityItems != null && wd.CommercialActivityItems.size()>0){
                    for(CommercialActivityItems c: wd.CommercialActivityItems){
                        if(c.selected)
                            allSelectedProducts.add(c.id);
                    }
                }
                if(caItems.size()>0){
                    for(CommercialActivityProduct__c c:caItems){
                        allSelectedProducts.add(c.ProductId__c);
                    }
                }
                partialData.add(wd);
            }
        }
        system.debug('selectedRsgList'+selectedRsgList);
        system.debug('** test allSelectedProducts'+allSelectedProducts);
        
        //Get all products
        banProductList =new Map<Id,Product2>([Select id,Flavor_Family__c,Pod_Strength__c From Product2 where id In: allSelectedProducts]);

        //Commeted by juturi
        // for(RetailLocationGroup__c rs: [Select id, AccountId__c,AccountId__r.ComplianceMechanism__c,Pricing_State__c from RetailLocationGroup__c where id IN: selectedRsgList]){
        //     if(rs.AccountId__c != null){
        //         rgMap.put(rs.id,rs.AccountId__c);
        //         if(rs.Pricing_State__c != null)
        //             rsgAccountStateMap.put(rs.id,rs.Pricing_State__c);
        //         if(rs.AccountId__r.ComplianceMechanism__c != null)
        //             accComplianceMap.put(rs.AccountId__c,rs.AccountId__r.ComplianceMechanism__c);
        //         else
        //             accComplianceMap.put(rs.AccountId__c,'');
        //     }
            
        // }
        //Added by juturi rajesh 
        for(AccountActionPlanTemplate__c rs: [Select id, Account__c,Account__r.ComplianceMechanism__c,Grouped_State__c from AccountActionPlanTemplate__c where id IN: selectedRsgList]){
            if(rs.Account__c != null){
                rgMap.put(rs.id,rs.Account__c);
                if(rs.Grouped_State__c != null)
                    rsgAccountStateMap.put(rs.id,rs.Grouped_State__c);
                if(rs.Account__r.ComplianceMechanism__c != null)
                    accComplianceMap.put(rs.Account__c,rs.Account__r.ComplianceMechanism__c);
                else
                    accComplianceMap.put(rs.Account__c,'');
            }
            
        }
        
        for(InStoreLocation__c s: [Select id,RetailStoreGroupActionPlanTemplate__c,RetailLocationId__c,StartDate__c,EndDate__c,Active__c,(Select id from Store_Products__r where Active__c = true ),(Select id from Assets__r where Active__c = true ),(Select id from Assets1__r where Active__c = true ) from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c IN :junctionIds AND Category__c =:storeCategory AND Active__c = True AND Status__c = 'Planned']){
            if(s.RetailStoreGroupActionPlanTemplate__c != null && s.RetailLocationId__c != null)
                allStoreLocationsWithjunctionId.put(s.RetailStoreGroupActionPlanTemplate__c+'-'+s.RetailLocationId__c,s);
            if(s.StartDate__c == selectedAPTQueried.RequestedStartDate__c && s.EndDate__c == selectedAPTQueried.RequestedEndDate__c){
                if(s.Store_Products__r != null && s.Store_Products__r.size() >0)
                    existingRelatedStoreProducts.put(s.id,s.Store_Products__r);
                if(s.Assets__r != null && s.Assets__r.size() >0)
                    existingAssets.put(s.id,s.Assets__r);
                //added by Jyoti SFDC - 0000004342
                //start
                if(s.Assets1__r != null && s.Assets1__r.size() >0)
                    existingCustomAssets.put(s.id,s.Assets1__r);
                //end
            }
        }
        List<ActionPlan__c> existingActionPlans = new List<ActionPlan__c>();
        for(Mission__c mt:[Select id,(Select Id from Action_Plans__r) from Mission__c where RetailStoreGroupActionPlanTemplate__c IN: junctionIds AND StartDate__c = :selectedAPTQueried.RequestedStartDate__c AND EndDate__c = :selectedAPTQueried.RequestedEndDate__c AND MissionType__c ='Strategy' AND Status__c = 'Planned']){
            existingActionPlans.addALL(mt.Action_Plans__r);
            existingMissions.add(mt);
        }
        
        //Delete Missions
        if(existingMissions.size()>0)
            Delete existingActionPlans;
        Delete existingMissions;
        
        
        for(WrapperData wd: partialData){
            String storeLocationKey ='';
            if(rgMap.containsKey(wd.id))
                storeLocationKey = wd.junctionId+'-'+rgMap.get(wd.Id);
            String accountState='';
            if(rsgAccountStateMap.containsKey(wd.Id))
                accountState = '-' + rsgAccountStateMap.get(wd.Id);
            InStoreLocation__c sl;
            InStoreLocation__c sltoDeactivate;
            system.debug('allStoreLocationsWithjunctionId'+allStoreLocationsWithjunctionId.containsKey(storeLocationKey));
            if(!allStoreLocationsWithjunctionId.isEmpty() && allStoreLocationsWithjunctionId.containsKey(storeLocationKey)){
                InStoreLocation__c existingStoreLocation = allStoreLocationsWithjunctionId.get(storeLocationKey);
                
                if(existingStoreLocation.StartDate__c == selectedAPTQueried.RequestedStartDate__c && existingStoreLocation.EndDate__c == selectedAPTQueried.RequestedEndDate__c){
                    sl=existingStoreLocation;
                    //Added by JJ to fix null error when missing products or assets 
                    if(existingRelatedStoreProducts.size() > 0 && existingRelatedStoreProducts.containsKey(sl.id)) {
                        RelatedStoreProductstoDelete.addAll(existingRelatedStoreProducts.get(sl.id));
                    }
                    //Added by JJ to fix null error when missing products or assets 
                    if(existingAssets.size() > 0 && existingAssets.containsKey(sl.id)) {
                        RelatedAssetstoDelete.addAll(existingAssets.get(sl.id));
                    } 
                    //added by Jyoti SFDC - 0000004342
                    //start
                    if(existingCustomAssets.size() > 0 && existingCustomAssets.containsKey(sl.id)) {
                        RelatedCustomAssetstoDelete.addAll(existingCustomAssets.get(sl.id));
                    }
                    //end
                }
                else if(selectedAPTQueried.RequestedStartDate__c == existingStoreLocation.EndDate__c){
                    //Create new store location
                    sl = new InStoreLocation__c();
                    sl.RetailStoreGroupActionPlanTemplate__c = wd.junctionId;
                    sl.RetailLocationId__c = rgMap.get(wd.Id);
                    sl.Active__c = True;
                    sl.Category__c = storeCategory;
                    sl.StartDate__c = selectedAPTQueried.RequestedStartDate__c;
                    sl.EndDate__c =selectedAPTQueried.RequestedEndDate__c;
                    sl.Status__c ='Planned';
                }
                else if((selectedAPTQueried.RequestedStartDate__c >= existingStoreLocation.StartDate__c && selectedAPTQueried.RequestedStartDate__c < existingStoreLocation.EndDate__c) || (selectedAPTQueried.RequestedEndDate__c > existingStoreLocation.StartDate__c && selectedAPTQueried.RequestedEndDate__c <= existingStoreLocation.EndDate__c)){
                    //Deactivate if overlapping date range
                    //added by JJ to fix null error when missing products or assets 
                    if(existingStoreLocation != null) {
                        sltoDeactivate = existingStoreLocation;
                        sltoDeactivate.Active__c = False;
                        sltoDeactivateList.add(sltoDeactivate);
                    }
                    //Create new store location
                    sl = new InStoreLocation__c();
                    sl.RetailStoreGroupActionPlanTemplate__c = wd.junctionId;
                    sl.RetailLocationId__c = rgMap.get(wd.Id);
                    sl.Active__c = True;
                    sl.Category__c = storeCategory;
                    sl.StartDate__c = selectedAPTQueried.RequestedStartDate__c;
                    sl.EndDate__c =selectedAPTQueried.RequestedEndDate__c;
                    sl.Status__c ='Planned';
                }
                else{
                    sl = new InStoreLocation__c();
                    sl.RetailStoreGroupActionPlanTemplate__c = wd.junctionId;
                    sl.RetailLocationId__c = rgMap.get(wd.Id);
                    sl.Active__c = True;
                    sl.Category__c = storeCategory;
                    sl.StartDate__c = selectedAPTQueried.RequestedStartDate__c;
                    sl.EndDate__c =selectedAPTQueried.RequestedEndDate__c;
                    sl.Status__c ='Planned';
                }
            }
            else{
                system.debug('IN Else');
                sl = new InStoreLocation__c();
                sl.RetailStoreGroupActionPlanTemplate__c = wd.junctionId;
                sl.RetailLocationId__c = rgMap.get(wd.Id);
                sl.Active__c = True;
                sl.Category__c = storeCategory;
                sl.StartDate__c = selectedAPTQueried.RequestedStartDate__c;
                sl.EndDate__c =selectedAPTQueried.RequestedEndDate__c;
                sl.Status__c ='Planned';
            }
            
            
            if(APTRecordType == 'AccountPlan' || APTRecordType == 'PromotionalActivityProcess'){
                if(wd.currentplanogramId != null){
                    sl.PlanogramId__c = wd.currentplanogramId;
                }
                
            }
            else if(APTRecordType == 'ResetActivityProcess'){
                if(wd.plannedPlanogramId != null){
                    sl.PlanogramId__c = wd.plannedPlanogramId;
                    //Make a map to store planogram with retail store Id to update on retail store groups
                    // rsgPlanogramsToUpdate.put(wd.Id,wd.plannedPlanogramId);
                }
            }
            if(wd.standardPog){
                sl.InStoreLocationType__c = 'Planogram Specific';
            }else if(!wd.standardPog) {
                sl.InStoreLocationType__c = 'Custom Assortment';
            }
            //storeLocationsListToUpsert.put(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c,sl);// Commented for ticket SFDC - 0000003394
            String slKey = sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c; //Added for ticket SFDC - 0000003394
            storeLocationsListToUpsert.put(slKey,sl);//Added for ticket SFDC - 0000003394
            System.debug('accComplianceMap**************'+accComplianceMap);
            System.debug('(accComplianceMap.get(rgMap.get(wd.Id)))**************'+(accComplianceMap.get(rgMap.get(wd.Id))));
            //List<InStoreLocation__c> slToInsertIfProductisBan = new List<InStoreLocation__c>();
            if(!accComplianceMap.isEmpty() && !(accComplianceMap.get(rgMap.get(wd.Id))).contains('Category Ban')){
                //Create store products if Planogram was selected
                if(wd.standardPog && wd.planogramProducts != null && wd.planogramProducts.size()>0){
                    system.debug('** test wd.planogramProducts');
                    for(Products p : wd.planogramProducts){
                        System.debug('** test Inside 1'+p.id);
                        if(!accComplianceMap.isEmpty() && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Menthol Ban') && banProductList.get(p.Id).Flavor_Family__c =='Classic Menthol') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 0.77%') && banProductList.get(p.Id).Pod_Strength__c == '0.77%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 1.5%') && banProductList.get(p.Id).Pod_Strength__c == '1.5%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 3.0%') && banProductList.get(p.Id).Pod_Strength__c == '3%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 5.0%') && banProductList.get(p.Id).Pod_Strength__c == '5%')){
                            StoreProduct__c sp = new StoreProduct__c();
                              System.debug('** test Inside 2'+p.id);
                            sp.RetailStoreId__c= rgMap.get(wd.Id);
                            sp.ProductId__c = p.id;
                            //sp.PricingMatrixId__c = p.pricingId; //commented by juturi need to check 
                            sp.CommercialActivityProductPricingId__c=p.pricingId; //added by juturi
                            //Added by Shreya-pooja for ticket SFDC - 0000003131
                            sp.STD_JUUL_Funding__c = p.STDFunding;          //sr01
                            sp.JUUL_Tax_Funding__c = p.TaxFunding;          //sr02
                            sp.Retailer_Funding__c= p.RetailerFunding;      //sr03
                            //sp.Differentiator__c = p.differentiator;
                            sp.DefaultOrderQuantity__c = p.quantity;
                            sp.Source_Product_Id__c = p.parentId;
                            //Added for JTP 167 
                            sp.Active__c = True;
                            if(!StoreLocationStoreProductMap.containsKey(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c))
                                StoreLocationStoreProductMap.put(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c,new List<StoreProduct__c>());
                            StoreLocationStoreProductMap.get(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c).add(sp);
                            
                            system.debug('** test sp'+sp);
                            // storeProductStoreLocation.put(sp,sl);
                        }
                    }
                }
                system.debug('rgMap.get(wd.Id)'+rgMap.get(wd.Id));
                //Create store products if additional products were selected
                System.debug('wd.products**************'+wd.products);
                if(wd.products != null && wd.products.size()>0){
                      System.debug('Inside 3');
                    for(Products p: wd.products){
                          System.debug('Inside 4');
                        if(p.selected){
                              System.debug('Inside 5');
                            if(!accComplianceMap.isEmpty() && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Menthol Ban') && banProductList.get(p.Id).Flavor_Family__c =='Classic Menthol') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 0.77%') && banProductList.get(p.Id).Pod_Strength__c == '0.77%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 1.5%') && banProductList.get(p.Id).Pod_Strength__c == '1.5%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 3.0%') && banProductList.get(p.Id).Pod_Strength__c == '3%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 5.0%') && banProductList.get(p.Id).Pod_Strength__c == '5%')){
                                  System.debug('Inside 6');
                                StoreProduct__c sp = new StoreProduct__c();
                                sp.RetailStoreId__c= rgMap.get(wd.Id);
                                sp.ProductId__c = p.id;
                                //sp.PricingMatrixId__c = p.pricingId; //commented by juturi need to check
                                sp.CommercialActivityProductPricingId__c=p.pricingId; //added by juturi 
                                //Added by Shreya-pooja for ticket SFDC - 0000003131
                                sp.STD_JUUL_Funding__c = p.STDFunding;         //sr01
                                sp.JUUL_Tax_Funding__c = p.TaxFunding;         //sr02
                                sp.Retailer_Funding__c= p.RetailerFunding;     //sr03
                                //sp.Differentiator__c = p.differentiator;
                                sp.DefaultOrderQuantity__c = p.quantity;
                                sp.Source_Product_Id__c = p.parentId;
                                //Added for JTP 167 
                                sp.Active__c = True;
                                if(!StoreLocationStoreProductMap.containsKey(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c))
                                    StoreLocationStoreProductMap.put(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c,new List<StoreProduct__c>());
                                StoreLocationStoreProductMap.get(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c).add(sp);
                                
                                // storeProductStoreLocation.put(sp,sl);
                                system.debug('storeProductStoreLocation'+storeProductStoreLocation);
                            }
                        }
                    }
                }
                
                //Create store products and Assets if Commercial Activity Items were selected
                if(wd.CommercialActivityItems != null && wd.CommercialActivityItems.size()>0){
                    for(CommercialActivityProduct__c cap: caItems){
                        CommercialActivityItems ciWrapp = new CommercialActivityItems();
                        ciWrapp.id = cap.ProductId__c;
                        ciWrapp.name = cap.ProductId__r.Name ;
                        ciWrapp.parentId = cap.Id;
                        ciWrapp.listPrice = cap.CollateralUnitCost__c;
                        ciWrapp.productType = cap.ProductType__c;
                        ciWrapp.selected = true;
                        // commented by juturi
                        // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(cap.ProductId__c + accountState)){
                        //     ciWrapp.pricingId =pricingMatricData.get(cap.ProductId__c + accountState).Id;
                        //     ciWrapp.minimumMSRP = pricingMatricData.get(cap.ProductId__c + accountState).MinimumMSRP2__c;
                        //     ciWrapp.maximumExpectedMSRP = pricingMatricData.get(cap.ProductId__c + accountState).ExpectedMaximumMSRP__c;
                        //     // commented bu jututi
                        //     //ciWrapp.listPrice = pricingMatricData.get(cap.ProductId__c + accountState).PriceByState__c;
                            
                        // }
                        // added by juturi
                        if(!commercialAcitvityProductPrice.isEmpty() && commercialAcitvityProductPrice.containsKey(cap.ProductId__c + accountState)){
                            ciWrapp.pricingId =commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Id;
                            ciWrapp.listPrice = commercialAcitvityProductPrice.get(cap.ProductId__c + accountState).Price__c	;

                        }
                        wd.CommercialActivityItems.add(ciWrapp);
                    }
                    System.debug('wd.CommercialActivityItems'+wd.CommercialActivityItems);
                    for(CommercialActivityItems c: wd.CommercialActivityItems){
                         System.debug('SP Product loop 1'+c.id);
                        if(c.selected){
                            System.debug('SP Product loop 2'+c.productType);
                            if(!accComplianceMap.isEmpty() && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Menthol Ban') && banProductList.get(c.Id).Flavor_Family__c =='Classic Menthol') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 0.77%') && banProductList.get(c.Id).Pod_Strength__c == '0.77%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 1.5%') && banProductList.get(c.Id).Pod_Strength__c == '1.5%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 3.0%') && banProductList.get(c.Id).Pod_Strength__c == '3%') && !((accComplianceMap.get(rgMap.get(wd.Id))).contains('Potency Ban - 5.0%') && banProductList.get(c.Id).Pod_Strength__c == '5%')){
                                if(c.productType == 'JUUL Product'){
                                    System.debug('SP Product loop 3'+c.id);
                                    StoreProduct__c sp = new StoreProduct__c();
                                    System.debug('SP Product'+c.id);
                                    //Added by Shreya for SFDC - 0000004228 
                                    if(c.productBundle!=null &&(c.productBundle == 'Combo' || c.productBundle =='GetxSavex'))
                                        sp.Product_Bundle__c = c.productBundle;
                                    if(c.ProductDescription!=null)
                                        sp.Product_Bundle_Description__c = c.ProductDescription;
                                    //End of code for SFDC - 0000004228 
                                    sp.RetailStoreId__c= rgMap.get(wd.Id);
                                    sp.ProductId__c = c.id;    
                                    if(c.parentId!='null')
                                        sp.Source_Product_Id__c = c.parentId;                                   
                                    if(c.pricingId!='null')
                                        //sp.PricingMatrixId__c = c.pricingId;  //commented by juturi need to check 
                                        sp.CommercialActivityProductPricingId__c=c.pricingId; //added by juturi                              
                                    //Added by Shreya-pooja for ticket SFDC - 0000003131
                                    sp.STD_JUUL_Funding__c = c.STDFunding;         //sr01
                                    sp.JUUL_Tax_Funding__c = c.TaxFunding;         //sr02
                                    sp.Retailer_Funding__c= c.RetailerFunding;     //sr03
                                    // sp.Differentiator__c = c.differentiator;
                                    sp.DefaultOrderQuantity__c = c.quantity;
                                    //Added for JTP 167 
                                    sp.Active__c = True;
                                    if(!StoreLocationStoreProductMap.containsKey(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c))
                                        StoreLocationStoreProductMap.put(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c,new List<StoreProduct__c>());
                                    StoreLocationStoreProductMap.get(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c).add(sp);
                                    
                                    //storeProductStoreLocation.put(sp,sl);
                                    system.debug('StoreLocationStoreProductMap'+StoreLocationStoreProductMap);
                                }
                                else if(c.productType == 'Trade Collateral'){
                                    Asset ass = new Asset();
                                    ass.AccountId =  rgMap.get(wd.Id);
                                    ass.Product2Id =c.Id;
                                    ass.Unit_Price__c = c.listPrice;
                                    ass.name= c.name;
                                    ass.Source_Product_Id__c = c.parentId;
                                    ass.Quantity =c.quantity;
                                    //Added for JTP 167 
                                    ass.Active__c = True;
                                    if(!StoreLocationAssetMap.containsKey(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c))
                                        StoreLocationAssetMap.put(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c,new List<Asset>());
                                    StoreLocationAssetMap.get(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c).add(ass);
                                    
                                    //Added by Jyoti SFDC - 0000004342
                                    //start
                                    Asset__c ass1 = new Asset__c();
                                    ass1.Account__c =  rgMap.get(wd.Id);
                                    ass1.Product__c =c.Id;
                                    ass1.Unit_Price__c = c.listPrice;
                                    ass1.name= c.name;
                                    ass1.Source_Product_Id__c = c.parentId;
                                    ass1.Quantity__c =c.quantity;
                                    ass1.Status__c = 'Planned';
                                    //Added for JTP 167 
                                    ass1.Active__c = True;
                                    if(!StoreLocationCustomAssetMap.containsKey(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c))
                                        StoreLocationCustomAssetMap.put(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c,new List<Asset__c>());
                                    StoreLocationCustomAssetMap.get(sl.RetailStoreGroupActionPlanTemplate__c+'='+sl.RetailLocationId__c).add(ass1);
                                    //end
                                    //  assetStoreLocation.put(ass,sl);
                                    //  system.debug('storeProductStoreLocation'+storeProductStoreLocation);
                                }
                            }
                        }
                    }
                }
            }
            
           // if(rsgAptItems.get(wd.Id) != null && rsgAptItems.get(wd.Id).size()>0){  //Commented for SFDC - 0000005445 (create missions without mission tasks)
                Mission__c m = new Mission__c();
                m.AccountId__c = rgMap.get(wd.Id);
                if(missionRecordType != null)
                    m.RecordTypeId = missionRecordType;
                
                m.MissionType__c = storeCategory;
                m.RetailStoreGroupActionPlanTemplate__c = wd.junctionId;
                m.MissionType__c ='Strategy';
                
                for(string field: APTMissionFieldsMap.keyset()){
                    m.put(APTMissionFieldsMap.get(field),selectedAPTQueried.get(field));
                }
                //start -----Added for ticket SFDC - 0000003394  ***commented for reversed approach  
                if(!StoreLocationMissionMap.containsKey(slKey))    
                    StoreLocationMissionMap.put(slKey,new List<Mission__c>()); 
                StoreLocationMissionMap.get(slKey).add(m); 
                //end -----------Added for ticket SFDC - 0000003394
                mapKeyMission.put(String.valueOf(wd.Id)+'='+String.valueOf(rgMap.get(wd.Id)),m);
            //}


            //added by JC for SFDC - 0000005444 
            // system.debug('retail Strore Group Id - '+wd.Id);
            // system.debug('caItemsSTDfunding - '+caItemsSTDfunding); 
            // system.debug('wd.CommercialActivityItems - '+wd.CommercialActivityItems); 
            // system.debug('selectedAPTQueried.STD_JUUL_Funding_Check__c - '+selectedAPTQueried.STD_JUUL_Funding_Check__c);
		   if(selectedAPTQueried.STD_JUUL_Funding_Check__c == false){
            for(CommercialActivityItems c: wd.CommercialActivityItems){ 
               if(c.selected && caItemsSTDfunding.containskey(c.parentId) && c.productType == 'JUUL Product'){
                CommercialActivityProduct__c relatedCAP = caItemsSTDfunding.get(c.parentId);
                    // system.debug('relatedCAP - '+relatedCAP);
                    // system.debug('c.selected - '+c.selected);
			        if(c.STDFunding < relatedCAP.Min_STD_JUUL_Funding__c || c.STDFunding > relatedCAP.Max_STD_JUUL_Funding__c)
				    {
                    // system.debug('inside selectedAPTQueried.STD_JUUL_Funding_Check__c - false');
                    // system.debug('c.STDFunding - '+c.STDFunding);
                    // system.debug('c.MinSTDJUULFunding - '+relatedCAP.Min_STD_JUUL_Funding__c);
                    // system.debug('c.MaxSTDJUULFunding - '+relatedCAP.Max_STD_JUUL_Funding__c);
				    selectedAPTQueried.STD_JUUL_Funding_Check__c = true;
				    }
                }
		    }
        }else if(selectedAPTQueried.STD_JUUL_Funding_Check__c == true)
        {
            for(CommercialActivityItems c: wd.CommercialActivityItems){ 
                if(c.selected && caItemsSTDfunding.containskey(c.parentId)  && c.productType == 'JUUL Product'){
                 CommercialActivityProduct__c relatedCAP = caItemsSTDfunding.get(c.parentId);
                    //  system.debug('relatedCAP - '+relatedCAP);
                    //  system.debug('c.selected - '+c.selected);
                     if(c.STDFunding > relatedCAP.Min_STD_JUUL_Funding__c && c.STDFunding < relatedCAP.Max_STD_JUUL_Funding__c)
                     {
                    //  system.debug('inside selectedAPTQueried.STD_JUUL_Funding_Check__c - true');
                    //  system.debug('c.STDFunding - '+c.STDFunding);
                    //  system.debug('c.MinSTDJUULFunding - '+relatedCAP.Min_STD_JUUL_Funding__c);
                    //  system.debug('c.MaxSTDJUULFunding - '+relatedCAP.Max_STD_JUUL_Funding__c);
                     isTrue = false;
                     }else {
                        isTrue = true;
                        // system.debug('inside else and isTrue ='+ isTrue);                     
                        break;
                     }
                 }
             }
             selectedAPTQueried.STD_JUUL_Funding_Check__c = istrue;
        } 
        
		//end--added by JC for SFDC - 0000005444
        }
        

        //Delete existing store products
        if(RelatedStoreProductstoDelete.size()>0)
            Delete RelatedStoreProductstoDelete;
        
        //Delete existing assets
        if(RelatedAssetstoDelete.size()>0)
            Delete RelatedAssetstoDelete;
        
        //Added by Jyoti SFDC - 0000004342
        //Delete existing custom assets
        if(RelatedCustomAssetstoDelete.size()>0)
            Delete RelatedCustomAssetstoDelete;
        
        //Deactivate overlapped storeLocations
        if(sltoDeactivateList != null && sltoDeactivateList.size()>0)
            Update sltoDeactivateList;
        
        
        //Insert Store Locations
        system.debug('storeLocationsListToUpsert'+storeLocationsListToUpsert);
        List<String> noStoreProductsAAPT = new List<String>();
        List<String> noAssetsAAPT = new List<String>();
        if(storeLocationsListToUpsert.values() != null){
            upsert storeLocationsListToUpsert.values();
            //selectedAPTQueried.To_be_Deleted__c = 'true';
            //system.debug('@@To be deleted 11 :'+selectedAPTQueried.To_be_Deleted__c);
            System.debug('StoreLocationStoreProductMap************'+StoreLocationStoreProductMap);
            for(String sl :storeLocationsListToUpsert.Keyset()){
                //Update Store Location in Store Product
                if(StoreLocationStoreProductMap.containsKey(sl) && StoreLocationStoreProductMap.get(sl) != null){
                    for(StoreProduct__c sp: StoreLocationStoreProductMap.get(sl)){
                        sp.InStoreLocationId__c = storeLocationsListToUpsert.get(sl).id;
                        spToInsert.add(sp);
                    }
                }else{
                    noStoreProductsAAPT.add(sl);
                }
                if(StoreLocationAssetMap.containsKey(sl) && StoreLocationAssetMap.get(sl)!= null){
                    //Update Store Location in Asset
                    for(Asset a: StoreLocationAssetMap.get(sl)){
                        a.InStoreLocation__c = storeLocationsListToUpsert.get(sl).id;
                        assetToInsert.add(a);
                    }
                }else{
                    noAssetsAAPT.add(sl);
                }
                //Added by Jyoti SFDC - 0000004342
                //start
                if(StoreLocationCustomAssetMap.get(sl)!= null){
                    //Update Store Location in Custom Asset
                    for(Asset__c a: StoreLocationCustomAssetMap.get(sl)){
                        a.InStoreLocation__c = storeLocationsListToUpsert.get(sl).id;
                        customAssetToInsert.add(a);
                    }
                }
                //end
                
                //start-----------Added for ticket SFDC - 0000003394    ***commented for reversed approach
                if(StoreLocationMissionMap.get(sl)!= null){    
                    //Update Store Location in Asset    
                    for(Mission__c m: StoreLocationMissionMap.get(sl)){ 
                        m.InStoreLocationId__c = storeLocationsListToUpsert.get(sl).id;  
                        missionToInsert.add(m); 
                    }   
                } 
                //end----------------Added for ticket SFDC - 0000003394
            }
        }
        
        
        //Insert Store Products
        if (spToInsert != null && spToInsert.size() > 0) { System.debug('comes here when Store Products to insert');
            List<Database.SaveResult> spToInsertResults = Database.Insert(spToInsert, true);
            //selectedAPTQueried.To_be_Deleted__c = 'true';
            //system.debug('@@To be deleted 22 :'+selectedAPTQueried.To_be_Deleted__c);
            List<Database.Error> spToInsertError = new List <Database.Error> ();
            for (Integer index = 0, size = spToInsertResults.size(); index < size; index++) {
                if (!spToInsertResults[index].isSuccess()) {
                    spToInsertError.addAll(spToInsertResults[index].getErrors());
                }
            }
            if (spToInsertError.size() > 0) {
                LogEventTriggerHandler.insertBatchLog(spToInsertError, class_Name,method_Name, 'Store Product', 'Database.Insert_Failed');
            }else{
                if(noStoreProductsAAPT.size() == 0){
                    selectedAPTQueried.Is_APT_Ready_For_Approval_Process__c = true; //For JTP-1600
                }else{
                    selectedAPTQueried.Is_APT_Ready_For_Approval_Process__c = false; //For JTP-1600
                }
                
            }
        }
        
        //Insert Assets for commercial activity items
        if (assetToInsert != null && assetToInsert.size() > 0) { System.debug('comes here when Assets to insert');
            List <Database.SaveResult > assetToInsertResults = Database.Insert(assetToInsert, true);
            //selectedAPTQueried.To_be_Deleted__c = 'true';
            //system.debug('@@To be deleted 33 :'+selectedAPTQueried.To_be_Deleted__c);
            List < Database.Error > assetToInsertError = new List <Database.Error> ();
            for (Integer index = 0, size = assetToInsertResults.size(); index < size; index++) {
                if (!assetToInsertResults[index].isSuccess()) {
                    assetToInsertError.addAll(assetToInsertResults[index].getErrors());
                }
            }
            if (assetToInsertError.size() > 0) {
                LogEventTriggerHandler.insertBatchLog(assetToInsertError, class_Name,method_Name, 'Asset', 'Database.Insert_Failed');
            }else{
                if(noAssetsAAPT.size() == 0){
                    selectedAPTQueried.Is_APT_Ready_For_Approval_Process__c = true; //For JTP-1600
                }else{
                    selectedAPTQueried.Is_APT_Ready_For_Approval_Process__c = false; //For JTP-1600
                }
            }
        }

    
        
        //Added by Jyoti SFDC - 0000004342
        //start
        //Insert Custom Assets for commercial activity items
        if (customAssetToInsert != null && customAssetToInsert.size() > 0) {
            List <Database.SaveResult > customAssetToInsertResults = Database.Insert(customAssetToInsert, true);
            //selectedAPTQueried.To_be_Deleted__c = 'true';
            //system.debug('@@To be deleted 33 :'+selectedAPTQueried.To_be_Deleted__c);
            List < Database.Error > customAssetToInsertError = new List <Database.Error> ();
            for (Integer index = 0, size = customAssetToInsertResults.size(); index < size; index++) {
                if (!customAssetToInsertResults[index].isSuccess()) {
                    customAssetToInsertError.addAll(customAssetToInsertResults[index].getErrors());
                }
            }
            if (customAssetToInsertError.size() > 0) {
                LogEventTriggerHandler.insertBatchLog(customAssetToInsertError, class_Name,method_Name, 'Asset__c', 'Database.Insert_Failed');
            }
        }
        //end
        
        //Insert Missions
        //start---Added for ticket SFDC - 0000003394 // commented for reversed approach
        
        List<Id> successRecords = new List<Id>();
        //start----------Added for ticket SFDC - 0000003394    
        if(mapKeyMission.size()>0 && missionToInsert != null && missionToInsert.size() > 0){    
            
            List<Database.SaveResult> missionToInsertResults = Database.Insert( mapKeyMission.values(), true);  
            //End----------Added for ticket SFDC - 0000003394    
            //selectedAPTQueried.To_be_Deleted__c = 'true';
            //system.debug('@@To be deleted 44 :'+selectedAPTQueried.To_be_Deleted__c);
            List<Database.Error> missionToInsertError = new List <Database.Error>();
            for (Integer index = 0, size = missionToInsertResults.size(); index < size; index++) {
                if (!missionToInsertResults[index].isSuccess()) {
                    missionToInsertError.addAll(missionToInsertResults[index].getErrors());
                    //returnResponse= missionToInsertError[0].getMessage();
                }else
                    successRecords.add(missionToInsertResults[index].id);
                
            }
            if (missionToInsertError.size() > 0) {
                LogEventTriggerHandler.insertBatchLog(missionToInsertError,class_Name,method_Name, 'Mission', operationType);
            }
            
            //Update mission ids in Action Plans
            Map<Id,ActionPlan__c> actionPlansToInsert = new Map<Id,ActionPlan__c>();
            for(Mission__c m: mapKeyMission.values()){
                ActionPlan__c ap = new ActionPlan__c();
                if(APRecordType != null){
                    ap.RecordTypeId = APRecordType;
                }
                ap.isProcessed__c = true;
                ap.ActionPlanTemplateId__c = selectedAPTQueried.Id;
                ap.Mission__c = m.Id;
                actionPlansToInsert.put(m.Id,ap);
            }
            
            // Insert Action Plans
            If(actionPlansToInsert != null && actionPlansToInsert.size()>0){
                List<Database.SaveResult> actionPlansToInsertResults = Database.Insert(actionPlansToInsert.values(), true);
                //selectedAPTQueried.To_be_Deleted__c = 'true';
                //system.debug('@@To be deleted 55 :'+selectedAPTQueried.To_be_Deleted__c);
                List<Database.Error> actionPlansToInsertError = new List <Database.Error>();
                for (Integer index = 0, size = actionPlansToInsertResults.size(); index < size; index++) {
                    if (!actionPlansToInsertResults[index].isSuccess()) {
                        actionPlansToInsertError.addAll(actionPlansToInsertResults[index].getErrors());
                        //returnResponse= missionToInsertError[0].getMessage();
                    }
                }
                if (actionPlansToInsertError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(actionPlansToInsertError,class_Name,method_Name, 'Action Plan', operationType);
                }
            }
            
            Map<ActionPlanItem__c,MissionTask__c> mapAPTIMT = new Map<ActionPlanItem__c,MissionTask__c>();
            //commented by juturi rajesh JTP-1570
            // for(WrapperData wd: partialData){
            //     Mission__c m = mapKeyMission.get(String.valueOf(wd.Id)+'='+String.valueOf(rgMap.get(wd.Id)));
            //     if(m!=null){
            //        if(rsgAptItems.get(wd.Id) != null && rsgAptItems.get(wd.Id).size()>0){  //Added for SFDC - 0000005445 (create missions without mission tasks)
            //         for(Items i: rsgAptItems.get(wd.Id)){
            //             ActionPlanItem__c api = new ActionPlanItem__c();
            //             api.ActionPlanTemplateItemId__c =i.Id;
            //             api.ActionPlanId__c = actionPlansToInsert.get(m.Id).Id;
            //             MissionTask__c mtask = new MissionTask__c();
            //             mtask.ParentId__c  = m.Id;
            //             mtask.AccountId__c = rgMap.get(wd.Id);
            //             mtask.Source_Item_Id__c = i.Id;
            //             for(string field: aptiMtaskFieldsMap.keyset()){
            //                 mtask.put(aptiMtaskFieldsMap.get(field),aptItemsMap.get(i.Id).get(field));
            //             }
                        
            //             //Map to store missiontasks respective to action plan items
            //             mapAPTIMT.put(api,mtask);
                        
            //         }
            //     }
            //     }
                
            // }
            
            //Insert Mission Task
            if(mapAPTIMT.size()>0){
                List<Database.SaveResult> mTaskToInsertResults = Database.Insert(mapAPTIMT.values(), true);
                //selectedAPTQueried.To_be_Deleted__c = 'true';
                //system.debug('@@To be deleted 66 :'+selectedAPTQueried.To_be_Deleted__c);
                List<Database.Error> mTaskToInsertError = new List <Database.Error>();
                for (Integer index = 0, size = mTaskToInsertResults.size(); index < size; index++) {
                    if (!mTaskToInsertResults[index].isSuccess()) {
                        mTaskToInsertError.addAll(mTaskToInsertResults[index].getErrors());
                        //returnResponse= missionToInsertError[0].getMessage();
                    }
                }
                if (mTaskToInsertError.size() > 0) {
                    LogEventTriggerHandler.insertBatchLog(mTaskToInsertError,class_Name,method_Name, 'Mission task', operationType);
                }
            }
            
            if(mapAPTIMT.size()>0){
                List<ActionPlanItem__c> apiToInsert = new List<ActionPlanItem__c>();
                for(ActionPlanItem__c api:mapAPTIMT.keySet()){
                    api.MissionTaskId__c = mapAPTIMT.get(api).Id;
                    apiToInsert.add(api);
                }
                
                if(apiToInsert != null && apiToInsert.size()>0){
                    List<Database.SaveResult> apiToInsertResults = Database.Insert(apiToInsert, true);
                    List<Database.Error> apiToInsertError = new List <Database.Error>();
                    for (Integer index = 0, size = apiToInsertResults.size(); index < size; index++) {
                        if (!apiToInsertResults[index].isSuccess()) {
                            apiToInsertError.addAll(apiToInsertResults[index].getErrors());
                            //returnResponse= missionToInsertError[0].getMessage();
                        }
                    }
                    if (apiToInsertError.size() > 0) {
                        LogEventTriggerHandler.insertBatchLog(apiToInsertError,class_Name,method_Name, 'Mission task', operationType);
                    }
                }
            }
        }
        //end---Added for ticket SFDC - 0000003394 //commented for reversed approach

        
		//added by JC for SFDC - 0000005444
        update selectedAPTQueried;
        //To share mission records with account team members
        KAMApexSharing.shareMissionRecords(successRecords);
    }
    
    //Method to get related PlanogramProducts for a particular planogram(Reset) 
    @AuraEnabled
    public static String getPlanogramProductsforReset(List<PlanogramProductFacing__c> planogramProducts,RetailLocationGroup__c rsgRecord,Map<String,PricingMatrix__c> pricingMatricData,Map<string,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPrice){
        //Map<String,PricingMatrix__c> pricingMatricData = new Map<String,PricingMatrix__c>();
        //List<PlanogramProductFacing__c> planogramProducts = new List<PlanogramProductFacing__c>([Select id,ProductName__c,ProductName__r.Name,Facings__c from PlanogramProductFacing__c where PlanogramName__c =:planogramId]);
        //RetailLocationGroup__c rsgRecord = [Select id,Pricing_State__c from RetailLocationGroup__c where Id = :rsg];        
        String accountState = '-' + rsgRecord.Pricing_State__c;
        
        /*for(PricingMatrix__c prm: [Select id,MinimumMSRP2__c,ExpectedMaximumMSRP__c,PriceByState__c,StateTerritoryISO2__c,ProductId__c from PricingMatrix__c where Active__c = True]){
if(prm.ProductId__c !=null)
{ String s = prm.ProductId__c + '-' + prm.StateTerritoryISO2__c;
pricingMatricData.put(s,prm);
}
}*/
        List<Products> pList = new List<Products>();
        for(PlanogramProductFacing__c pf:planogramProducts){
            Products p = new Products();
            p.id= pf.ProductName__c;
            p.Name = pf.ProductName__r.Name;
            p.parentId = pf.Id;
            system.debug('pricingMatricData');
            system.debug('pf.ProductName__c + accountState'+pf.ProductName__c + accountState);
            // commented by juturi
            // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(pf.ProductName__c + accountState)){
            //     system.debug('pricingMatricData');
            //     p.minimumMSRP = pricingMatricData.get(pf.ProductName__c + accountState).MinimumMSRP2__c;
            //     p.maximumExpectedMSRP = pricingMatricData.get(pf.ProductName__c + accountState).ExpectedMaximumMSRP__c;
            //     // commented by juturi
            //     //p.listPrice = pricingMatricData.get(pf.ProductName__c + accountState).PriceByState__c;
            //     //p.plannedPrice = p.listPrice;
            // }
            // p.readOnlyNew = p.listPrice == 0 ? true : false;
            // System.debug('pricingMatricData '+p.listPrice);
            // added by juturi
            if(!commercialAcitvityProductPrice.isEmpty() && commercialAcitvityProductPrice.containsKey(pf.ProductName__c + accountState)){
                p.listPrice = commercialAcitvityProductPrice.get(pf.ProductName__c + accountState).Price__c;
                p.plannedPrice = p.listPrice;
            }
            pList.add(p);
        }
        
        return JSON.serializePretty(pList);
    }
    
    //Method to get related PlanogramProducts for a particular planogram.
    @AuraEnabled
    public static String getPlanogramProducts(Id planogramId,Id rsg){
        Map<String,PricingMatrix__c> pricingMatricData = new Map<String,PricingMatrix__c>();
        List<PlanogramProductFacing__c> planogramProducts = new List<PlanogramProductFacing__c>([Select id,ProductName__c,ProductName__r.Name,Facings__c from PlanogramProductFacing__c where PlanogramName__c =:planogramId]);
        RetailLocationGroup__c rsgRecord = [Select id,Pricing_State__c from RetailLocationGroup__c where Id = :rsg];
        String accountState = '-' + rsgRecord.Pricing_State__c;
        for(PricingMatrix__c prm: [Select id,MinimumMSRP2__c,ExpectedMaximumMSRP__c,PriceByState__c,StateTerritoryISO2__c,ProductId__c,combo__c,GetxSavex__c from PricingMatrix__c where Active__c = True]){
            if(prm.ProductId__c !=null)
            { String s = prm.ProductId__c + '-' + prm.StateTerritoryISO2__c;
             pricingMatricData.put(s,prm);
            }
            
        }
        // added by juturi
        Map<String,Commercial_Activity_Product_Pricing__c> commercialAcitvityProductPrice = new Map<string,Commercial_Activity_Product_Pricing__c>();
        Map<Id,CommercialActivityProduct__c> commercialActivityProductMap = new Map<id,CommercialActivityProduct__c>([select id,name,ProductId__c from CommercialActivityProduct__c where CommercialActivityId__c =: CommercialActivityIdSet]);

        for(Commercial_Activity_Product_Pricing__c capp : [select id,name,State__c,Commercial_Activity_Product__r.ProductId__c,State_ISO2__c,Price__c  from Commercial_Activity_Product_Pricing__c where Commercial_Activity_Product__c IN: commercialActivityProductMap.keyset()]){
                if(capp.Commercial_Activity_Product__r.ProductId__c !=null && capp.State_ISO2__c != null){
                    string  s = capp.Commercial_Activity_Product__r.ProductId__c+'-'+capp.State_ISO2__c;
                    commercialAcitvityProductPrice.put(s,capp);
                  }
             }
        // ended by juturi
        List<Products> pList = new List<Products>();
        for(PlanogramProductFacing__c pf:planogramProducts){
            Products p = new Products();
            p.id= pf.ProductName__c;
            p.Name = pf.ProductName__r.Name;
            p.parentId = pf.Id;
            system.debug('pricingMatricData');
            system.debug('pf.ProductName__c + accountState'+pf.ProductName__c + accountState);
            // commented by juturi
            // if(!pricingMatricData.isEmpty() && pricingMatricData.containsKey(pf.ProductName__c + accountState)){
            //     system.debug('pricingMatricData');
            //     p.minimumMSRP = pricingMatricData.get(pf.ProductName__c + accountState).MinimumMSRP2__c;
            //     p.maximumExpectedMSRP = pricingMatricData.get(pf.ProductName__c + accountState).ExpectedMaximumMSRP__c;
            //     //commented by juturi
            //     //p.listPrice = pricingMatricData.get(pf.ProductName__c + accountState).PriceByState__c;
            //     //p.plannedPrice = p.listPrice;
            // }
            // System.debug('pricingMatricData11 '+p.listPrice);
            //added by juturi
            // p.readOnlyNew = p.listPrice == 0 ? true : false;
            if(!commercialAcitvityProductPrice.isEmpty() && commercialAcitvityProductPrice.containsKey(pf.ProductName__c + accountState)){
                p.listPrice = commercialAcitvityProductPrice.get(pf.ProductName__c + accountState).Price__c;
                p.plannedPrice = p.listPrice;
            }
            pList.add(p);
        }
        
        return JSON.serializePretty(pList);
    }
    //Create Mission, Mission task, Action Plan and Action Plan Item
    //Added below method by Shreya for ticket SFDC - 0000004197 
     @AuraEnabled
    public static String createMissionsProductsAssets(Id aptId, List<WrapperData> selectedData){
        String response;
        String storeCategory;
        Set<Id> junctionIds = new Set<Id>();
        Map<Id,Id> storeLocationonJunction = new  Map<Id,Id>();
        ActionPlanTemplate__c selectedAPTQueried = [Select Id,RecordType.Name,CascadeFlag__c,RequestedStartDate__c,RequestedEndDate__c,KAM_Batch_ID__c from ActionPlanTemplate__c where Id =:aptId];
        
        if(selectedAPTQueried.RecordType.Name == 'Account Plan')
            storeCategory ='Account Plan';
        if(selectedAPTQueried.RecordType.Name == 'Promotional Activity Process')
            storeCategory='Promotion';
        if(selectedAPTQueried.RecordType.Name == 'Reset Activity Process')
            storeCategory ='Reset';
        
        for(WrapperData w: selectedData){
            // if(w.selected && !w.readOnly)
            junctionIds.add(w.junctionId);
            
        }
        for(InStoreLocation__c s: [Select id,RetailStoreGroupActionPlanTemplate__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c IN :junctionIds AND Category__c =:storeCategory AND Active__c = True AND Status__c = 'Planned' AND StartDate__c = :selectedAPTQueried.RequestedStartDate__c AND EndDate__c =:selectedAPTQueried.RequestedEndDate__c]){
            storeLocationonJunction.put(s.RetailStoreGroupActionPlanTemplate__c,s.id);
        }
        //Check if Planning has been done for all HQ accounts of retail store group associated on Action Plan Template
        if(storeLocationonJunction.keyset().size() == junctionIds.size()){
            system.debug('method check');
            // Execute a batch to do the planning for related stores of each retail store group of Action Plan Template
            set<ID> AccIDs = new set<ID>();
            Boolean CascadeChanges = false;
            KAMBatchAccountPlanning k = new KAMBatchAccountPlanning(aptId,selectedData,AccIDs,CascadeChanges);
            BatchID = Database.executeBatch(k,10);
            response ='Process succesfully completed.';
        }else
            response ='Please do planning for all retail store groups first.';
        
        selectedAPTQueried.CascadeFlag__c = True;
        selectedAPTQueried.KAM_Batch_ID__c = BatchID;
        update selectedAPTQueried;
        
        return response;
    }
    
    //Create Instorelocation, SP and Asset
    //Added below method by Shreya for ticket SFDC - 0000004197 
    @AuraEnabled
    public static  String createProductsAssets(Id aptId, List<WrapperData> selectedData){
        String response;
        String storeCategory;
        Set<Id> junctionIds = new Set<Id>();
        Map<Id,Id> storeLocationonJunction = new  Map<Id,Id>();
        system.debug('Inside createProductsAssets');
        
        ActionPlanTemplate__c selectedAPTQueried = [Select Id,ISL_Batch_Flag__c,KAM_Batch_ID__c,RecordType.Name,RequestedStartDate__c,RequestedEndDate__c from ActionPlanTemplate__c where Id =:aptId];
        
        if(selectedAPTQueried.RecordType.Name == 'Account Plan')
            storeCategory ='Account Plan';
        if(selectedAPTQueried.RecordType.Name == 'Promotional Activity Process')
            storeCategory='Promotion';
        if(selectedAPTQueried.RecordType.Name == 'Reset Activity Process')
            storeCategory ='Reset';
        
        for(WrapperData w: selectedData){
            // if(w.selected && !w.readOnly)
           
            junctionIds.add(w.junctionId);
            
        }
        
        System.debug('junctionIds==>'+junctionIds);
        for(InStoreLocation__c s: [Select id,RetailStoreGroupActionPlanTemplate__c,InStoreLocationType__c from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__c IN :junctionIds AND Category__c =:storeCategory AND Active__c = True AND Status__c = 'Planned' AND StartDate__c = :selectedAPTQueried.RequestedStartDate__c AND EndDate__c =:selectedAPTQueried.RequestedEndDate__c]){
            storeLocationonJunction.put(s.RetailStoreGroupActionPlanTemplate__c,s.id);
        }
        
        System.debug('storeLocationonJunction==>'+storeLocationonJunction);
        //Check if Planning has been done for all HQ accounts of retail store group associated on Action Plan Template
        if(storeLocationonJunction.keyset().size() == junctionIds.size()){
            // Execute a batch to do the planning for related stores of each retail store group of Action Plan Template
            System.debug('call KamBatchAccountPlanningforProducts batch');
            set<ID> AccIDs = new set<ID>();
            Boolean CascadeChanges = false;
            KamBatchAccountPlanningforProducts k = new KamBatchAccountPlanningforProducts(aptId,selectedData,AccIDs,AccIDs,CascadeChanges);
            BatchID = Database.executeBatch(k,10);
            response ='Process succesfully completed.';
        }else
            response ='Please do planning for all retail store groups first.';
        selectedAPTQueried.ISL_Batch_Flag__c=true;
        selectedAPTQueried.KAM_Batch_ID__c = BatchID;
        update selectedAPTQueried;
        return response;
    }	
    //Added below method by Shreya for ticket SFDC - 0000004197 
       //This method used to update the batch status 
    @AuraEnabled
    public static String getBatchJobStatus(Id apt){
        ActionPlanTemplate__c selectedAPTQueried = [Select Id,Batch_Status__c,KAM_Batch_ID__c from ActionPlanTemplate__c where Id =:apt];
        
        BatchInfo b = new BatchInfo();
        try{
            AsyncApexJob jobInfo = [Select TotalJobItems, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, Id, JobType, ApexClassId, CreatedDate 
                                    From AsyncApexJob Where id =:selectedAPTQueried.KAM_Batch_ID__c];
             
            if(jobInfo!=null){
                b.BatchID = jobInfo.id;
                b.BatchClass = jobInfo.ApexClassId;
                b.BatchJobItemsProcessed = jobInfo.JobItemsProcessed;
                b.BatchNumberOfErrors = jobInfo.NumberOfErrors;
                b.BatchTotalJobItems = jobInfo.TotalJobItems;
               }
         }
        catch(Exception e){
            System.debug('message'+e.getMessage());
        }
        return JSON.serializePretty(b); 
    }
    
    
    public static String getPlanogramImgUrl(Id PlanogramId) {
        //added below to query for the associated POG image
        String PlanogramImgURL;
        List<Planogram__c> Planogram = new List<Planogram__c>();
        
        if(PlanogramId != null) {
            Planogram = [SELECT ImageURL__c,Name_of_POG__c FROM Planogram__c WHERE Id =: PlanogramId];
            PlanogramImgURL = Planogram[0].ImageURL__c;
            return PlanogramImgURL;
        }
        
        return null;
    }
    //Added by shreya for ticket SFDC - 0000004466 
    //This method used to perform cascade changes on APT Layout
    @AuraEnabled
    Public static void CascadeISLMissionChanges(Id aptId, List<WrapperData> selectedData)
    {
        Map<String,InStoreLocation__c> ISL = new Map<String,InStoreLocation__c>();
        Map<String,List<ActionPlan__c>> DeleteActionPlans = new Map<String,List<ActionPlan__c>>();
        Map<String,Mission__c> Mission = new Map<String,Mission__c>();
        set<ID> aaptID = new set<ID>();
        Map<ID,AccountActionPlanTemplate__c>  AccountAPTMap =  new Map<ID,AccountActionPlanTemplate__c>();
        List<AccountActionPlanTemplate__c> cascadeToDoorList = new List<AccountActionPlanTemplate__c>();
        Map<String,AccountRetailStoreGroup__c> ARSGMap = new Map<String,AccountRetailStoreGroup__c>();
        Set<ID> AccountIDs = new Set<ID>();
        Set<ID> MissionAccountIDs = new Set<ID>();
        Boolean CascadeChanges = true;
        List<InStoreLocation__c> DeleteISL = new List<InStoreLocation__c>();
        List<Mission__c> DeleteMission = new List<Mission__c>();
        List<List<Actionplan__c>> DeleteAP = new List<List<Actionplan__c>>();
        List<Actionplan__c> DeleteAPAll = new List<Actionplan__c>();
        
        
        //To fetch Instorelocations linked to the Action plan template
        for(InStoreLocation__c i: [select RetailLocationId__c,RetailStoreGroupActionPlanTemplate__r.RetailLocationId__c,id from InStoreLocation__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.id=:aptId and RetailLocationId__r.Type != 'HQ'])
        {
            ISL.put(i.RetailLocationId__c+'-'+i.RetailStoreGroupActionPlanTemplate__r.RetailLocationId__c,i);
        }
        for(Mission__c m : [select id,RetailStoreGroupActionPlanTemplate__r.RetailLocationId__c,AccountId__c,(Select Id from Action_Plans__r) from mission__c where RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__c =: aptId and AccountId__r.Type!='HQ'])
        {
            if(!DeleteActionPlans.containskey(m.id))
            DeleteActionPlans.put(m.AccountId__c + '-' +m.RetailStoreGroupActionPlanTemplate__r.RetailLocationId__c,new List<ActionPlan__c>());
            DeleteActionPlans.get(m.AccountId__c + '-' +m.RetailStoreGroupActionPlanTemplate__r.RetailLocationId__c).addAll(m.Action_Plans__r);
            Mission.put(m.AccountId__c + '-' +m.RetailStoreGroupActionPlanTemplate__r.RetailLocationId__c,m);
        }
        //To fetch the RSG linked to APT
        for(AccountActionPlanTemplate__c aapt : [Select ID,RetailLocationId__c,RetailLocationId__r.PlanogramId__r.Id,RetailLocationId__r.PlanogramId__r.Name from AccountActionPlanTemplate__c where ActionPlanTemplateId__c = :aptID AND RetailLocationId__c != null])
        {
            aaptID.add(aapt.id);
            AccountAPTMap.put(aapt.RetailLocationId__c,aapt);
        }
        //To fetch the Door accounts linked to retail store group
        for(AccountRetailStoreGroup__c arsg : [Select id,AccountId__c,RetailStoreGroupId__c,AccountId__r.ComplianceMechanism__c,AccountId__r.ShippingState from AccountRetailStoreGroup__c where RetailStoreGroupId__c IN :AccountAPTMap.keyset() and  AccountId__c!=null and AccountId__r.Type != 'HQ'])
        {
          ARSGMap.put(arsg.AccountId__c+'-'+arsg.RetailStoreGroupId__c,arsg);
        }
        for(String astg : ARSGMap.keyset()){ 
            if(!ISL.containskey(astg))
            {
                AccountIDs.add(ARSGMap.get(astg).AccountId__c); 
            }
            if(!Mission.containsKey(astg))
            {
                MissionAccountIDs.add(ARSGMap.get(astg).AccountId__c);
            }
        }
        System.debug('MissionAccountIDs'+MissionAccountIDs);
        if(AccountIDs.size()>0){
            System.debug('AccountIDs'+AccountIDs);
         KamBatchAccountPlanningforProducts k = new KamBatchAccountPlanningforProducts(aptId,selectedData,AccountIDs,MissionAccountIDs,CascadeChanges);
         Database.executeBatch(k,10);
        }       
        for(String a : ISL.keyset()){ 
            if(!ARSGMap.containskey(a))
            {
                System.debug('Inside delete loop for account'+a);
                DeleteISL.add(ISL.get(a));
            }
        }
        if(DeleteISL!=null && DeleteISL.size()>0)
        {
            delete DeleteISL;
        }
        //To Delete Missions
       for(String a : Mission.keyset()){ 
            if(!ARSGMap.containskey(a))
            {
                DeleteAP.add(DeleteActionPlans.get(a));
                DeleteMission.add(Mission.get(a));
            }
        }
        
        if(DeleteMission!=null && DeleteMission.size()>0)
        {
          for(List<ActionPlan__c> d : DeleteAP){
                DeleteAPAll.addAll(d);
            }
            if(DeleteAPAll!=null && DeleteAPAll.size()>0)
            Delete DeleteAPAll;
            delete DeleteMission;
        }
    }
    //Added for JTP -167 
     @AuraEnabled
    Public static void OverrideProducts(Id aptId,List<WrapperData> selectedData)
    {
        System.debug('Override Products'+aptId);
        System.debug('Override selectedData'+selectedData);
        if(aptId!=null){
        KamBatchDeactivation k = new KamBatchDeactivation (aptId,selectedData);
        Database.executeBatch(k,10);
       
        } 
    }

    public Class WraperDataWithAPTInfo{
        @AuraEnabled
        public Boolean cascadeToDoorDisable {get;set;}
        @AuraEnabled
        public String recordTypeName {get;set;}
        @AuraEnabled
        public String APTstatus {get;set;}
        @AuraEnabled
        public Boolean CascadeFlag {get;set;}
        @AuraEnabled
        public Boolean ISLFlag {get;set;}
        @AuraEnabled
        public Boolean InstoreLocationsCreated {get;set;}
        @AuraEnabled
        public Boolean ProfileSalesOppAdmin {get;set;}
        @AuraEnabled
        public Boolean MissionsCreated {get;set;}
        @AuraEnabled
        public Boolean OverrideField {get;set;}
        @AuraEnabled 
        public Boolean APTChanges{get;set;}
        @AuraEnabled
        public String CurrencyISOCode {get;set;}
        @AuraEnabled
        public Boolean CascadeChanges {get;set;}
        @AuraEnabled
        public boolean storeProductsVisible {get;set;}
        @AuraEnabled
        public boolean planogramVisible {get;set;}
        @AuraEnabled
        public boolean CommercialStrategyDate {get;set;}
        @AuraEnabled
        public List<WrapperData> wraperList {get;set;}
        public void WraperDataWithAPTInfo(){
            cascadeToDoorDisable = True;
            storeProductsVisible = True;
            planogramVisible = True;
        }
        
    }
    
    //Added below wrappercass by Shreya for ticket SFDC - 0000004197 
    Public Class BatchInfo{
        
        @AuraEnabled
        public Id BatchID {get;set;}
        @AuraEnabled
        public String BatchStatus {get;set;}
        @AuraEnabled
        public String BatchClass {get;set;}
        @AuraEnabled
        public Integer BatchJobItemsProcessed {get;set;}
        @AuraEnabled
        public Integer BatchNumberOfErrors {get;set;}
        @AuraEnabled
        public Integer BatchTotalJobItems {get;set;}
        
    }
    
    Public Class WrapperData{
        @AuraEnabled
        public Id junctionId {get;set;}
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public Id accountId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Boolean selected {get;set;}
        @AuraEnabled
        public Boolean expanded {get;set;}
        @AuraEnabled
        public Id plannedPlanogramId {get;set;}
        @AuraEnabled
        public boolean disablePOG {get;set;}
        @AuraEnabled
        public boolean standardPog {get;set;}
        @AuraEnabled
        public List<Products> planogramProducts {get;set;}
        @AuraEnabled
        public List<Products> products {get;set;}
        @AuraEnabled
        public Id currentPlanogramId {get;set;}
        @AuraEnabled
        public String currentplanogram {get;set;}
        @AuraEnabled
        public String currentPlanogramURL {get;set;}
        @AuraEnabled
        public String plannedPlanogramURL {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
        @AuraEnabled
        public List<Planograms> selectedPlanogram {get;set;}
        @AuraEnabled
        public List<CommercialActivityItems> commercialActivityItems {get;set;}
        @AuraEnabled
        public Boolean readOnly {get;set;}
        public WrapperData(){
            selected = False;
            disablePOG = True;
            standardPog = False;
            readOnly = False;
            
        }
    }
    public Class Items{
        //Commented by Jyoti
        // @AuraEnabled
        // public Id Id {get;set;}
        //added by Jyoti
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Id parentId {get;set;}
        @AuraEnabled
        public Boolean selected {get;set;}
        @AuraEnabled
        public String subject {get;set;}
        @AuraEnabled
        public String priority {get;set;}
        public Items(){
            selected = False;
        }
        
    }
    public Class CommercialActivityItems{
        //Commented by jyoti for Product Bundle
        // @AuraEnabled
        // public Id Id {get;set;}
        //@AuraEnabled
        // public Id parentId {get;set;}
        //Added by jyoti for Product Bundle
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String parentId {get;set;}
        //end
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Boolean selected {get;set;}        
        @AuraEnabled
        public String productType {get;set;}
        @AuraEnabled
        public Decimal differentiator {get;set;}
        @AuraEnabled
        public Decimal quantity {get;set;}
        @AuraEnabled
        public boolean differentiatorDisabled {get;set;}
        @AuraEnabled
        public boolean STDFundingDisabled {get;set;}
        @AuraEnabled
        public boolean PTCModifierDisabled {get;set;}
        @AuraEnabled
        public Decimal STDFunding {get;set;}
        @AuraEnabled
        public boolean quantityDisabled {get;set;}
        @AuraEnabled
        public decimal minimumMSRP {get;set;}
        @AuraEnabled
        public decimal maximumExpectedMSRP {get;set;}
        @AuraEnabled
        public decimal listPrice {get;set;}
        @AuraEnabled
        public decimal plannedPrice {get;set;}
        @AuraEnabled
        public String pricingId {get;set;}
        //  @AuraEnabled
        // public Boolean readOnlyNew {get;set;}
        //Added by Shreya-pooja for ticket SFDC - 0000003131
        @AuraEnabled
        public Decimal TaxFunding {get;set;}
        @AuraEnabled
        public Decimal FinalPTC {get;set;}  
        @AuraEnabled
        public Decimal RetailerFunding {get;set;}
        @AuraEnabled
        public boolean TaxFundingDisabled {get;set;}
        @AuraEnabled
        public boolean RetailerFundingDisabled {get;set;}
        //Added by Shreya for SFDC - 0000004228 
        @AuraEnabled                                       //sr01
        public String ProductBundle {get;set;}             //sr02
        @AuraEnabled                                       //sr03
        public String ProductDescription {get;set;}        //sr04
        @AuraEnabled 
        public Boolean PriceMatrixExpiring {get;set;}
        public CommercialActivityItems(){
            minimumMSRP = 0.00;
            maximumExpectedMSRP=0.00;
            listPrice=0.00;
            PriceMatrixExpiring = false;
            // readOnlyNew = false;
            // differentiatorDisabled = false;
            //Added by Shreya-pooja for ticket SFDC - 0000003131
            STDFundingDisabled = false;
            PTCModifierDisabled = false;
            STDFunding = 0.00;
            plannedPrice =0.00;
            differentiator = 0.00;
            quantityDisabled = false;
            selected = False;
            quantity = 1;
            FinalPTC = 0.00;
            TaxFunding= 0.00;
            RetailerFunding=0.00;
            TaxFundingDisabled = false;
            RetailerFundingDisabled = false;
            
        }
    }
    public Class Planograms{
        @AuraEnabled
        public Id value {get;set;}
        @AuraEnabled
        public String label {get;set;}
    }
    public Class Products{
        //Commented by jyoti
        // @AuraEnabled
        // public Id Id {get;set;}
        //Added by jyoti
        @AuraEnabled
        public String Id {get;set;}//end
        @AuraEnabled
        public Id parentId {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Boolean selected {get;set;}
        //  @AuraEnabled
        // public Boolean readOnlyNew {get;set;}
        @AuraEnabled
        public Decimal differentiator {get;set;}
        @AuraEnabled
        public Decimal quantity {get;set;}
        @AuraEnabled
        public decimal minimumMSRP {get;set;}
        @AuraEnabled
        public decimal maximumExpectedMSRP {get;set;}
        @AuraEnabled
        public decimal listPrice {get;set;}
        @AuraEnabled
        public decimal plannedPrice {get;set;}
        @AuraEnabled
        public String pricingId {get;set;}
        //Added by Shreya-pooja for ticket SFDC - 0000003131
        @AuraEnabled
        public Decimal TaxFunding {get;set;}
        @AuraEnabled
        public Decimal FinalPTC {get;set;}  
        @AuraEnabled
        public Decimal RetailerFunding {get;set;}
        @AuraEnabled
        public Decimal STDFunding {get;set;}
        @AuraEnabled 
        public Boolean PriceMatrixExpiring {get;set;}
        public products(){
            minimumMSRP = 0.00;
            maximumExpectedMSRP=0.00;
            listPrice=0.00;
            selected = False;
            plannedPrice = 0.00;
            differentiator = 0.00;
            STDFunding = 0.00;
            // readOnlyNew = false;
            quantity = 1;
            PriceMatrixExpiring = false;
            //Added by Shreya-Pooja for ticket SFDC - 0000003131
            TaxFunding= 0.00;
            FinalPTC = 0.00;
            RetailerFunding=0.00;
        }
    }
}