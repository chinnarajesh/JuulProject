/**********************************************************************/
/* VERSION     		AUTHOR                  	DATE                           */
/*     1.0     		Ramya Ganeshkar       02-19-2021                    */
/* Class Name: KAMUpdatePricingMatriceController                      */
/* Description: To implement new pricing matrix changes  */
 /*Ticket Number: SFDC - 0000003183    */
/**********************************************************************/
public class KAMUpdatePricingMatriceController {
    //public static List<PricingMatrix__c> pricingList = new List<PricingMatrix__c>();
     

    @AuraEnabled(Cacheable = true)
    public static List<pricingMatrixWrapper> getPricingDetails(String stateId){
        List<pricingMatrixWrapper> pricingWrapperList = new List<pricingMatrixWrapper>();
        List<PricingMatrix__c> pricingList = [SELECT Id, StateTerritory__r.Name,StateTerritory__c,ProductId__c, 
                                                StateTerritory__r.DK__c, StateTerritory__r.RK2PK__c, StateTerritory__r.RK4PK__c, StateTerritory__r.Accessory1__c,StateTerritory__r.Combo__c,StateTerritory__r.GetxSavex__c,
                                                ProductId__r.Name, ProductCode__c,ProductPricingFamily__c, Country__c,
                                                Start_Date__c, End_Date__c, 
                                                RK2PK__c, DK__c, RK4PK__c, AccessoryOnePrice__c 
                                                FROM PricingMatrix__c WHERE StateTerritory__c =:stateId ];  
        
        Map<ID,PricingMatrix__c> prMatrixMap = new Map<ID,PricingMatrix__c>();
        for(PricingMatrix__c p :pricingList )
        {
            prMatrixMap.put(p.ProductId__c, p);
            System.debug('Pricing Matrix'+prMatrixMap);
        }
        
        for(ID pr : prMatrixMap.keyset()){
            pricingMatrixWrapper pricingWrp = new pricingMatrixWrapper();
            pricingWrp.productId = pr;
            pricingWrp.pricingMatrixId = prMatrixMap.get(pr).Id;
            pricingWrp.stateTerritoryId = prMatrixMap.get(pr).StateTerritory__c;
            //Adding Country fields Kam Canada - Ramya
            pricingWrp.country = prMatrixMap.get(pr).Country__c;
            pricingWrp.productName = prMatrixMap.get(pr).ProductId__r.Name;
            pricingWrp.productCode = prMatrixMap.get(pr).ProductCode__c;
            pricingWrp.productPricingFamily = prMatrixMap.get(pr).ProductPricingFamily__c;
            pricingWrp.rk2pkPrice = prMatrixMap.get(pr).StateTerritory__r.RK2PK__c;
            pricingWrp.startDate = null;
            //pricingWrp.startDate = prMatrixMap.get(pr).Start_Date__c;
            pricingWrp.dkPrice = prMatrixMap.get(pr).StateTerritory__r.DK__c;
            pricingWrp.endDate = null;
            //pricingWrp.endDate = prMatrixMap.get(pr).End_Date__c;
            pricingWrp.rk4pkPrice = prMatrixMap.get(pr).StateTerritory__r.RK4PK__c;
            pricingWrp.accessoryPrice = prMatrixMap.get(pr).StateTerritory__r.Accessory1__c;
            //Added by shreya 
            pricingWrp.Combo = prMatrixMap.get(pr).StateTerritory__r.Combo__c;  //sr01
            pricingWrp.GetxSavex = prMatrixMap.get(pr).StateTerritory__r.GetxSavex__c;  //sr02
            pricingWrp.isSelected = false;
           // pricingWrp.allStartDate = prMatrixMap.get(pr).Start_Date__c;
            //pricingWrp.allEndDate = prMatrixMap.get(pr).End_Date__c;
            pricingWrapperList.add(pricingWrp);
            System.debug('PR List'+pricingWrp);
        }
        System.debug('PRWrapper'+pricingWrapperList);
        return pricingWrapperList;        
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<StateTerritory__c> getStateDetails(){
        List<StateTerritory__c> stateList = [SELECT Id, Name, AdditionalTax__c, DK__c, RK2PK__c, RK4PK__c, 
                                                Accessory1__c FROM StateTerritory__c];
        System.debug('stateList-->' +stateList);
        return stateList;

    }

    /*
    *Created By : Subodh Shukla
    *Description: 
    *LastModifiedBy: 
    */
    @AuraEnabled
    public static List<pricingMatrixWrapper> saveData(List<pricingMatrixWrapper> wrapperList){
        List<PricingMatrix__c> createPricingMatrixList = new List<PricingMatrix__c>();

        List<pricingMatrixWrapper> exisitngPricingMatrixList = validateStartDateEndDate(wrapperList);
        system.debug('exisitngPricingMatrixList**--->'+exisitngPricingMatrixList);
        
        String response;

        if(exisitngPricingMatrixList != null && exisitngPricingMatrixList.size() == 0){
            for(pricingMatrixWrapper prwrp : wrapperList){
            system.debug('prwrp**--->'+prwrp);
               // if(prwrp.isSelected  )   {
                        PricingMatrix__c pricingMatrix = new PricingMatrix__c();
                        if(prwrp.startDate != null){
                            pricingMatrix.Start_Date__c = prwrp.startDate;
                        }
                        if(prwrp.allStartDate != null){
                            pricingMatrix.Start_Date__c = prwrp.allStartDate;
                        }
                        if(prwrp.endDate != null){
                            pricingMatrix.End_Date__c = prwrp.endDate;
                        }
                        if(prwrp.allEndDate != null){
                            pricingMatrix.End_Date__c = prwrp.allEndDate;
                        }
                        pricingMatrix.ProductId__c = prwrp.productId;
                        pricingMatrix.StateTerritory__c = prwrp.stateTerritoryId;
                		//Adding country field Kam Canada
                		pricingMatrix.Country__c = prwrp.country;
                        pricingMatrix.ProductPricingFamily__c = prwrp.productPricingFamily;
                        pricingMatrix.New_AccessoryOnePrice__c = prwrp.accessoryPrice;
                        pricingMatrix.New_DK__c = prwrp.dkPrice;
                        pricingMatrix.New_RK_2PK__c = prwrp.rk2pkPrice;
                        pricingMatrix.New_RK_4PK__c = prwrp.rk4pkPrice;
                        //added by Shreya 
                        pricingMatrix.Combo__c = prwrp.Combo;       //sr01
                        pricingMatrix.GetxSavex__c = prwrp.GetxSavex;  //sr02
                        createPricingMatrixList.add(pricingMatrix);
            //    }
              /*  else if(prwrp.isAllSelected){
                    System.debug('isAllSelected===>');
                        PricingMatrix__c pricingMatrix = new PricingMatrix__c();
                        pricingMatrix.Start_Date__c = prwrp.allStartDate;
                        pricingMatrix.End_Date__c = prwrp.allEndDate;   
                        pricingMatrix.ProductId__c = prwrp.productId;
                        pricingMatrix.StateTerritory__c = prwrp.stateTerritoryId;
                        pricingMatrix.ProductPricingFamily__c = prwrp.productPricingFamily;
                        pricingMatrix.New_AccessoryOnePrice__c = prwrp.accessoryPrice;
                        pricingMatrix.New_DK__c = prwrp.dkPrice;
                        pricingMatrix.New_RK_2PK__c = prwrp.rk2pkPrice;
                        pricingMatrix.New_RK_4PK__c = prwrp.rk4pkPrice;
                        createPricingMatrixList.add(pricingMatrix);
                }*/
            }
        
                try{
                    if(createPricingMatrixList.size()>0){
                        insert createPricingMatrixList;
                    }
                }catch (Exception e) {
                    System.debug('Inside Catch');
                    throw new AuraHandledException(e.getMessage());    
                    //throw new AuraHandledException('Pricing Matrix With That Start And End Date //Already Exist For:' );  
                }
            }
        return exisitngPricingMatrixList;
    }

     @AuraEnabled(Cacheable = true)
    public static List<PricingMatrix__c> handleErrorProduct(){ //String priceMatricId
        //System.debug('checked data-->'+priceMatricId);
        List<PricingMatrix__c> pmLst = [SELECT Id, StateTerritory__r.Name,StateTerritory__c,ProductId__c, 
                                            ProductId__r.Name, ProductCode__c,ProductPricingFamily__c,Combo__c,GetxSavex__c,Country__c,
                                            Start_Date__c, End_Date__c, RK2PK__c, DK__c, RK4PK__c, AccessoryOnePrice__c 
                                            FROM PricingMatrix__c  ]; //WHERE Id =:priceMatricId
        System.debug('pmLst' +pmLst);
        return pmLst;

    }

    public static List<pricingMatrixWrapper> validateStartDateEndDate(List<pricingMatrixWrapper> wrapperList){
        Map<String, List<PricingMatrix__c>> productPricingMatrixMap = new Map<String, List<PricingMatrix__c>>();
        Map<String, pricingMatrixWrapper> pricingMatrixMap = new Map<String, pricingMatrixWrapper>();
        //Boolean isValidpricingMtrix;
         List<pricingMatrixWrapper> invalidpricingMatrix = new List<pricingMatrixWrapper>();
        String territory = wrapperList[0].stateTerritoryId;

        List<PricingMatrix__c> pricingMatixList = [SELECT Id, StateTerritory__r.Name,StateTerritory__c,ProductId__c, 
                                                ProductId__r.Name, ProductCode__c,ProductPricingFamily__c,Country__c,
                                                Start_Date__c, End_Date__c,Combo__c,GetxSavex__c,
                                                RK2PK__c, DK__c, RK4PK__c, AccessoryOnePrice__c 
                                                FROM PricingMatrix__c WHERE StateTerritory__c =:territory ];  
        
        System.debug('pricingMatixList--->'+pricingMatixList);
        for(PricingMatrix__c pricingMatrix : pricingMatixList){
            if(productPricingMatrixMap.containsKey(pricingMatrix.ProductId__c)){
                List<PricingMatrix__c> pmList = new List<PricingMatrix__c>();
                pmList = productPricingMatrixMap.get(pricingMatrix.ProductId__c);
                pmList.add(pricingMatrix);
                productPricingMatrixMap.put(pricingMatrix.ProductId__c, pmList);
            }else{
                productPricingMatrixMap.put(pricingMatrix.ProductId__c,new List<PricingMatrix__c> {pricingMatrix} );
            }
        }

        system.debug('productPricingMatrixMap--->'+productPricingMatrixMap);

        for(pricingMatrixWrapper pricingMatrixInstance: wrapperList){
            if(productPricingMatrixMap.containsKey(pricingMatrixInstance.productId)) {
                List<PricingMatrix__c> pricingMatrixlst = new List<PricingMatrix__c>();
               
                pricingMatrixlst = productPricingMatrixMap.get(pricingMatrixInstance.productId);
               
                for(integer index=0; index < pricingMatrixlst.size(); index++){
                    if(pricingMatrixInstance.isAllSelected != null && pricingMatrixInstance.isAllSelected){
                        if(pricingMatrixInstance.isSelected == true && ( (pricingMatrixInstance.allStartDate >= pricingMatrixlst[index].Start_Date__c && pricingMatrixInstance.allStartDate <= pricingMatrixlst[index].End_Date__c)  ||  
                        (pricingMatrixInstance.allEndDate >= pricingMatrixlst[index].Start_Date__c && pricingMatrixInstance.allEndDate <= pricingMatrixlst[index].End_Date__c) ||
                        (pricingMatrixInstance.allStartDate < pricingMatrixlst[index].Start_Date__c &&  pricingMatrixInstance.allEndDate > pricingMatrixlst[index].End_Date__c) )){
                            //  invalidpricingMatrix.add(pricingMatrixInstance);
                              if(!pricingMatrixMap.containsKey(pricingMatrixInstance.productCode)){
                                  pricingMatrixMap.put(pricingMatrixInstance.productCode, pricingMatrixInstance);
                              }
                          }
                    }else{
                        if(pricingMatrixInstance.isSelected == true && ((pricingMatrixInstance.startDate >= pricingMatrixlst[index].Start_Date__c && pricingMatrixInstance.startDate <= pricingMatrixlst[index].End_Date__c) || 
                        (pricingMatrixInstance.endDate >= pricingMatrixlst[index].Start_Date__c && pricingMatrixInstance.endDate <= pricingMatrixlst[index].End_Date__c) ||
                        (pricingMatrixInstance.startDate < pricingMatrixlst[index].Start_Date__c &&  pricingMatrixInstance.endDate > pricingMatrixlst[index].End_Date__c)
                        )){
                        //  invalidpricingMatrix.add(pricingMatrixInstance);
                            if(!pricingMatrixMap.containsKey(pricingMatrixInstance.productCode)){
                                pricingMatrixMap.put(pricingMatrixInstance.productCode, pricingMatrixInstance);
                            }
                        }
                    }
                }
            }
        }
        system.debug('pricingMatrixMap--->'+pricingMatrixMap);
        invalidpricingMatrix.addAll(pricingMatrixMap.values());
        system.debug('invalidpricingMatrix--->'+invalidpricingMatrix);
        system.debug('wrapperList--->'+wrapperList);
        return invalidpricingMatrix;
    }
        
    

    public class pricingMatrixWrapper {
        @Auraenabled public Boolean isSelected {get;set;}
        @AuraEnabled public String productId {get;set;}
        @AuraEnabled public String pricingMatrixId {get;set;}
        @AuraEnabled public String stateTerritoryId {get;set;}
        //adding country for KAM Canada Changes- Ramya
        @AuraEnabled public String country{get;set;} 
        @AuraEnabled public Date startDate {get;set;}
        @AuraEnabled public Date endDate {get;set;}
        @AuraEnabled public String productName {get;set;}
        @AuraEnabled public boolean isProductSelected {get;set;}
        @AuraEnabled public String productCode {get;set;}
        @AuraEnabled public String productPricingFamily {get;set;}
        @AuraEnabled public Decimal rk2pkPrice {get;set;}
        @AuraEnabled public Decimal dkPrice {get;set;}
        @AuraEnabled public Decimal rk4pkPrice {get;set;}
        @AuraEnabled public Decimal accessoryPrice {get;set;}
        //Added by shreya
        @AuraEnabled public Decimal Combo {get;set;}  //sr01
        @AuraEnabled public Decimal GetxSavex {get;set;}  //sr02
        @AuraEnabled public Date allStartDate {get;set;}
        @AuraEnabled public Date allEndDate {get;set;}
        @Auraenabled public Boolean isAllSelected {get;set;}
        
    }
}