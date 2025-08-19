/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Pooja Gite        03-15-2021                         */
/* Class Name: AccountMissionController                             */
/* Description:On Account to diisplay Active Mission list then 
for selcted mission record to display related Mission task, Store Producst and Assets. */
/* Ticket Number: SFDC - 0000003906 :Convert the mission control flow into a LWC.*/
/**********************************************************************/
Global class AccountMissionControllerPROD {
    //Fetch all active missions 
    @AuraEnabled
    public static string getALLMissions(Id acc){
        System.debug('Account ID is'+acc);
        String color;
        Date d = System.today();
        Map<Id,Mission__c> missionMap = new Map<Id,Mission__c>([SELECT id,StartDate__c, EndDate__c,Status__c, Commercial_Activity__c, InstructionDescription__c,RecordType.Name FROM Mission__c WHERE 
                                                                AccountId__c =:acc AND StartDate__c <= TODAY  AND EndDate__c >= TODAY 
                                                                AND (RecordType.Name = 'Promotional Activity Process' OR RecordType.Name ='Account Plan') AND 
                                                                RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.Status__c NOT IN ('Recalled','Archived') ORDER BY RecordType.Name]);
        
        List<Missions> missionList = new List<Missions>();
        for(ID missionId : missionMap.keyset())
        {
            Missions m = new Missions();
            m.id = missionMap.get(missionId).id;
            m.status= missionMap.get(missionId).Status__c;
            m.StartDate= missionMap.get(missionId).StartDate__c;
            m.EndDate= missionMap.get(missionId).EndDate__c;
            m.CommercialActivity = missionMap.get(missionId).Commercial_Activity__c;
            m.RecordType = missionMap.get(missionId).RecordType.Name;            
            if(m.RecordType == 'Promotional Activity Process' && m.status == 'Promo Executed'){
            	m.color = 'Green';
            }
			if(m.RecordType == 'Promotional Activity Process' && m.status == 'Planned'){
            	m.color= 'Yellow';
            }
        	if(m.RecordType == 'Promotional Activity Process' && (m.status == 'Promo Not Executed' || m.status == 'Cancelled' || m.status == Label.Mission_Status)){
            	m.color = 'Red';
            }
            if(m.RecordType == 'Account Plan'){
            	m.color = 'Blue';
            }
           
            missionList.add(m);
        }
       System.debug('missionList'+missionList);        
        
        return JSON.serializePretty(missionList);
    }
    //Method to return list of all related Mission Task for selected mission
     @AuraEnabled
     public static string getRelatedMissionTasks(Id mission){
         
         Map<Id,MissionTask__c > missiontaskMap = new Map<Id,MissionTask__c >([select id,Name,Status__c from MissionTask__c where ParentId__c =: mission AND IsRequired__c= true]);
         system.debug('task'+missiontaskMap);

         List<MissionTask> missionTaskList = new List<MissionTask>();
        for(ID missiontaskId : missiontaskMap.keyset())
        {
            MissionTask m = new MissionTask();
            m.id = missiontaskMap.get(missiontaskId).id;
            m.status= missiontaskMap.get(missiontaskId).Status__c;
            m.Name= missiontaskMap.get(missiontaskId).Name;
            missionTaskList.add(m);
        }
       System.debug('missionTaskList'+missionTaskList);    
       return JSON.serializePretty(missionTaskList);
     }
    //Method to return list of all selected Mission.
     	@AuraEnabled
     	public static string getSelMissions(Id mission){
        System.debug('Id mission'+mission); 
        Map<Id,Mission__c> missionMap1 = new Map<Id,Mission__c>([SELECT id,StartDate__c,EndDate__c,Status__c,InstructionDescription__c,Commercial_Activity__c,MissionType__c,
                                                                 FillOutVendorLog__c,ThirdPartyAllowed__c,AllowedtoPriceScan__c,NoPricingUseJUULPricing__c,IfPriceDoesntScan__c,
                                                                 ProductHowtoFixOutofStocks__c,CanYouLabelFixtures__c,CanYouProvideLeadBehinds__c
                                                                 FROM Mission__c WHERE Id =:mission]);
         System.debug('missionMap1'+missionMap1); 
        List<selMissions> selMissionList = new List<selMissions>();
        //String getImageURL = getImageURL(m1.InstructionDescription__c);
        for(ID missionId1 : missionMap1.keyset())
         {
            selMissions m1 = new selMissions();
            m1.Id = missionMap1.get(missionId1).id;
            m1.missionstatus= missionMap1.get(missionId1).Status__c;
            m1.missionStartDate= missionMap1.get(missionId1).StartDate__c;
            m1.missionEndDate= missionMap1.get(missionId1).EndDate__c;
            m1.CommercialActivity= missionMap1.get(missionId1).Commercial_Activity__c;
            m1.InstructionDescription= missionMap1.get(missionId1).InstructionDescription__c;
            m1.missiontype= missionMap1.get(missionId1).MissionType__c;
            m1.vendorLog= missionMap1.get(missionId1).FillOutVendorLog__c;
            m1.thirdPartyAllowed = missionMap1.get(missionId1).ThirdPartyAllowed__c;
            m1.allowedtoPriceScan= missionMap1.get(missionId1).AllowedtoPriceScan__c;
            m1.noPricingUse = missionMap1.get(missionId1).NoPricingUseJUULPricing__c;
            m1.ifPriceDoesntScan= missionMap1.get(missionId1).IfPriceDoesntScan__c;
            m1.fixOutOfStocks= missionMap1.get(missionId1).ProductHowtoFixOutofStocks__c;
            m1.labelFixtures= missionMap1.get(missionId1).CanYouLabelFixtures__c;
            m1.provideLeadBehinds= missionMap1.get(missionId1).CanYouProvideLeadBehinds__c;
            selMissionList.add(m1);
         }
       System.debug('missionTaskList'+selMissionList); 
       return JSON.serializePretty(selMissionList);
     }
        
       //Method to return list of all related Store Product for selected mission.
    	@AuraEnabled
        public static string getRelatedStoreProducts(Id acc, Id mission){
        String commercialActivity;
        Id StoreLocationId;
            system.debug('mission inside apex method' +mission);
        Mission__c m = [Select id,Name,Commercial_Activity__c, InStoreLocationId__c FROM Mission__c where id=:mission];
        commercialActivity = m.Commercial_Activity__c;
		StoreLocationId = m.InStoreLocationId__c;
         List<StoreProduct> storeProductList = new List<StoreProduct>();

            if(StoreLocationId != null){
            system.debug('mission inside apex method' +StoreLocationId);            
        Map<Id,StoreProduct__c > storeProductMap = new Map<Id,StoreProduct__c >([select id,Name,Product_Name_Formula__c,ActualMSRP__c,Final_PTC__c from StoreProduct__c where InStoreLocationId__c =: StoreLocationId and ProductId__r.Product_Availability__c =True]);
		//Map<Id,StoreProduct__c > storeProductMap = new Map<Id,StoreProduct__c >([select id,Name,Product_Name_Formula__c,ActualMSRP__c,Final_PTC__c from StoreProduct__c where RetailStoreId__c =: acc AND Commercial_Activity__c =: commercialActivity]);
        System.debug('storeProductMap'+storeProductMap);
        for(ID storeProductId : storeProductMap.keyset()){
            StoreProduct sp = new StoreProduct();
            sp.id = storeProductMap.get(storeProductId).id;
            sp.Name = storeProductMap.get(storeProductId).Name;
            sp.ProductName = storeProductMap.get(storeProductId).Product_Name_Formula__c;
            sp.ActualMSRP = storeProductMap.get(storeProductId).ActualMSRP__c;
            sp.FinalPTC = storeProductMap.get(storeProductId).Final_PTC__c;
            storeProductList.add(sp);
        }
            }
        system.debug('storeProductList' +storeProductList);
        return JSON.serializePretty(storeProductList);
        }
    
     	//Method to update Store Product's ActualMSRP__c field for selected mission.
      	@AuraEnabled
    	public static List<StoreProduct__c> saveAccountsLwc(List<StoreProduct> records){
            system.debug('Inside save'+records);
            List<StoreProduct__c> storeProductList = new List<StoreProduct__c>();
        if(records.size()>0 && records != null){
            //List<StoreProduct> storeProductList = new List<StoreProduct>();
            for(integer i = 0; i < records.size(); i++) {
                StoreProduct__c sp = new StoreProduct__c();
                sp.Id = records[i].Id;
                sp.ActualMSRP__c = records[i].ActualMSRP;                
                storeProductList.add(sp);
            }
            system.debug('Inside storeProductList'+storeProductList);
            update storeProductList;
        }
             system.debug('Inside return list'+storeProductList);
             return storeProductList;
    }
    
       //Method to update asset Status__c field in LWC for selected mission.
 		@AuraEnabled
    	public static List<Asset__c> saveAssertLwc(List<Assets> records){
            system.debug('Inside save'+records);
            List<Asset__c> assertList = new List<Asset__c>();
        if(records.size()>0 && records != null){
            
            //List<StoreProduct> assertList = new List<StoreProduct>();
            
            for(integer i = 0; i < records.size(); i++) {
                Asset__c sp = new Asset__c();
                sp.Id = records[i].Id;
                sp.Status__c = records[i].Status;                
                assertList.add(sp);
            }
            system.debug('Inside assertList'+assertList);
            update assertList;
        }
             return assertList;
    }
    
   // --------------------------Added for Selected Mission Status-----------------
   // Update Mission for dependent picklist status and type field.
     @AuraEnabled
   	public static List<Mission__c> saveSelMissionStatus(List<selMissions> records){
       system.debug('Inside apex method update'+records);
       List<Mission__c> mList = new List<Mission__c>();
        if(records.size()>0 && records != null){
            for(integer i = 0; i < records.size(); i++) {
                System.debug(' records[i].missionstatus;'+ records[i].missionstatus);
                System.debug(' records[i].missiontype;'+ records[i].missiontype);
                Mission__c sp = new Mission__c();
                sp.Id = records[i].Id;
                sp.Status__c = records[i].missionstatus;
				sp.MissionType__c = records[i].missiontype;              
                mList.add(sp);
            }
            system.debug('Inside mList'+mList);
            update mList;
        }
             return mList;
   }
    //-----------------------End--------------------------
        
        //Added by Jyoti for Asset Object Changes
        /*@AuraEnabled
        public static string getRelatedAsset(Id acc, Id mission){
            
        String commercialActivity;  
        system.debug('mission' +mission);
        Mission__c m = [Select id,Name,Commercial_Activity__c FROM Mission__c where id=:mission ];
        commercialActivity = m.Commercial_Activity__c;
        Map<Id,Asset__c> assetMap = new Map<Id,Asset__c>([Select Id,Name,Quantity__c,Status__c from Asset__c where Account__c =: acc AND Commercial_Activity__c =:commercialActivity]);
        List<Assets> assetList = new List<Assets>();
        
        for(ID assetId : assetMap.keySet()){
            Assets a = new Assets();
            a.id = assetMap.get(assetId).id;
            a.Name = assetMap.get(assetId).Name;
            a.Quantity = assetMap.get(assetId).Quantity__c;
            a.Status = assetMap.get(assetId).Status__c;
            assetList.add(a);
            }
            //System.debug('assetList'+assetList);
          return JSON.serializePretty(assetList);
        }*/
    	
    	//Method to return list of related asset for selected mission.
        @AuraEnabled
        public static string getRelatedAsset(Id acc, Id mission){
        //String commercialActivity;
        Id StoreLocationId;
        system.debug('mission' +mission);
        Mission__c m = [Select id,Name,InStoreLocationId__c FROM Mission__c where id=:mission ];
        //commercialActivity = m.Commercial_Activity__c;
        StoreLocationId = m.InStoreLocationId__c;
		List<Assets> assetList = new List<Assets>();
            if(StoreLocationId != null){
        //Map<Id,Asset__c> assetMap = new Map<Id,Asset__c>([Select Id,Name,Quantity__c,Status__c from Asset__c where Account__c =: acc AND Commercial_Activity__c =:commercialActivity]);
          Map<Id,Asset__c> assetMap = new Map<Id,Asset__c>([Select Id,Name,Quantity__c,Status__c from Asset__c where InStoreLocation__c =: StoreLocationId  and Product__r.Product_Availability__c = True]);
        
        for(ID assetId : assetMap.keySet()){
            Assets a = new Assets();
            a.id = assetMap.get(assetId).id;
            a.Name = assetMap.get(assetId).Name;
            a.Quantity = assetMap.get(assetId).Quantity__c;
            a.Status = assetMap.get(assetId).Status__c;
            assetList.add(a);
            }
            }
            //System.debug('assetList'+assetList);
          return JSON.serializePretty(assetList);
        }
        //Commented by Jyoti for SFDC - 0000004342
        //start
        /*@AuraEnabled
        public static string getRelatedAsset(Id acc, Id mission){
            
        String commercialActivity;
            system.debug('mission' +mission);
        Mission__c m = [Select id,Name,Commercial_Activity__c FROM Mission__c where id=:mission ];
        commercialActivity = m.Commercial_Activity__c;
        Map<Id,Asset__c> assetMap = new Map<Id,Asset__c>([select id,Name,Quantity from Asset__c where AccountId =: acc AND Commercial_Activity__c =:commercialActivity]);
        List<Assets> assetList = new List<Assets>();
        
        for(ID assetId : assetMap.keySet()){
            Assets a = new Assets();
            a.id = assetMap.get(assetId).id;
            a.Name = assetMap.get(assetId).Name;
            a.Quantity = assetMap.get(assetId).Quantity;
            assetList.add(a);
            }
          return JSON.serializePretty(assetList);
        }*/
    //end 

     public Class Missions{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public Date StartDate {get;set;}
        @AuraEnabled
        public Date EndDate {get;set;}
        @AuraEnabled
        public String CommercialActivity {get;set;}
        @AuraEnabled
        public String RecordType {get;set;}
        @AuraEnabled
        public String color {get;set;}
     }
    
     public Class selMissions{
	  	@AuraEnabled
        public Id Id {get;set;}
		@AuraEnabled
        public String missionstatus {get;set;}
        @AuraEnabled
        public Date missionStartDate {get;set;}
        @AuraEnabled
        public Date missionEndDate {get;set;}
        @AuraEnabled
        public String InstructionDescription {get;set;}
        @AuraEnabled
        public String CommercialActivity {get;set;}
        @AuraEnabled
        public String missiontype {get;set;}
        @AuraEnabled
        public String vendorLog {get;set;}
		@AuraEnabled
        public boolean thirdPartyAllowed {get;set;}
        @AuraEnabled
        public String allowedtoPriceScan {get;set;}
        @AuraEnabled
        public String noPricingUse {get;set;}
        @AuraEnabled
        public String ifPriceDoesntScan {get;set;}
        @AuraEnabled
        public String fixOutOfStocks {get;set;}
        @AuraEnabled
        public String labelFixtures {get;set;}
        @AuraEnabled
        public String provideLeadBehinds {get;set;}
	 }
    
    public Class MissionTask{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public String missionstatus {get;set;}
        @AuraEnabled
        public Date missionStartDate {get;set;}
        @AuraEnabled
        public Date missionEndDate {get;set;}
     }
    
    public Class StoreProduct{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String ProductName {get;set;}
        @AuraEnabled
        public Decimal ActualMSRP {get;set;}
        @AuraEnabled
        public Decimal FinalPTC {get;set;}
        
     }
    
    public Class Assets{
        @AuraEnabled
        public Id Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Decimal Quantity {get;set;}
        @AuraEnabled
        public String Status {get;set;}
     }

}