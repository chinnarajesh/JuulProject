public class AcctMissioncontrolDesktopcontroller {
    
     //Fetch all active missions 
    @AuraEnabled
    public static string getALLMissions(Id acc){
        
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
                system.debug('inside PC1');
            	m.color = 'Green';
            }
			if(m.RecordType == 'Promotional Activity Process' && m.status == 'Planned'){
                 system.debug('inside PC2');
            	m.color= 'Yellow';
            }
        	if(m.RecordType == 'Promotional Activity Process' && (m.status == 'Promo Not Executed' || m.status == 'Cancelled' || m.status == Label.Mission_Status)){
            	 system.debug('inside PC3');
                m.color = 'Red';
            }
            if(m.RecordType == 'Account Plan'){
                 system.debug('inside PC4');
            	m.color = 'Blue';
            }
           
            missionList.add(m);
        }
       System.debug('missionList'+missionList);        
        
        return JSON.serializePretty(missionList);
    }
    
    @AuraEnabled 
    public static string getselectedMissions (ID MissionID)
    {
         System.debug('Id mission'+MissionID); 
        Map<Id,Mission__c> missionMap1 = new Map<Id,Mission__c>([SELECT id,StartDate__c,EndDate__c,Status__c,InstructionDescription__c,Commercial_Activity__c,MissionType__c,RecordType.Name,
                                                                 FillOutVendorLog__c,ThirdPartyAllowed__c,AllowedtoPriceScan__c,NoPricingUseJUULPricing__c,IfPriceDoesntScan__c,
                                                                 ProductHowtoFixOutofStocks__c,CanYouLabelFixtures__c,CanYouProvideLeadBehinds__c,RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.ExecutionNotes__c	
                                                                 FROM Mission__c WHERE Id =:MissionID]);
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
            m1.InstructionDescription= missionMap1.get(missionId1).RetailStoreGroupActionPlanTemplate__r.ActionPlanTemplateId__r.ExecutionNotes__c	;
            m1.missiontype= missionMap1.get(missionId1).MissionType__c;
            m1.vendorLog= missionMap1.get(missionId1).FillOutVendorLog__c;
            m1.thirdPartyAllowed = missionMap1.get(missionId1).ThirdPartyAllowed__c;
            m1.allowedtoPriceScan= missionMap1.get(missionId1).AllowedtoPriceScan__c;
            m1.noPricingUse = missionMap1.get(missionId1).NoPricingUseJUULPricing__c;
            m1.ifPriceDoesntScan= missionMap1.get(missionId1).IfPriceDoesntScan__c;
            m1.fixOutOfStocks= missionMap1.get(missionId1).ProductHowtoFixOutofStocks__c;
            m1.labelFixtures= missionMap1.get(missionId1).CanYouLabelFixtures__c;
            m1.provideLeadBehinds= missionMap1.get(missionId1).CanYouProvideLeadBehinds__c;
            m1.recordtype=  missionMap1.get(missionId1).RecordType.Name;
            selMissionList.add(m1);
         }
       System.debug('missionTaskList'+selMissionList); 
       return JSON.serializePretty(selMissionList);
    }
    
   @AuraEnabled
    public static List<StoreProduct__c> getStoreProducts (ID MissionID)
    {
        set<ID> ISLIDs = new set<ID>();
        for( Mission__c m : [Select id, InStoreLocationId__c FROM Mission__c where id=:MissionID])
        {
            ISLIDs.add(m.InStoreLocationId__c);
        }
        system.debug('isl'+ISLIDs);
        List<StoreProduct__c > StoreProductList = new List<StoreProduct__c>([select Id,Name,Product_Name_Formula__c,ActualMSRP__c,Final_PTC__c,Active__c from StoreProduct__c where InStoreLocationId__c =: ISLIDs and ProductId__r.Product_Availability__c =True and Active__c = True]);
        return StoreProductList;
    }
     @AuraEnabled
    public static List<Asset__c> getAsset (ID MissionID)
    {
        set<ID> ISLIDs = new set<ID>();
        for( Mission__c m : [Select id, InStoreLocationId__c FROM Mission__c where id=:MissionID])
        {
            ISLIDs.add(m.InStoreLocationId__c);
        }
        List<Asset__c > AssetList = new List<Asset__c>([Select Id,Name,Quantity__c,Status__c,Active__c from Asset__c where InStoreLocation__c =: ISLIDs  and Product__r.Product_Availability__c = True and Active__c = True]);
        return AssetList;
    }
     @AuraEnabled
    public static List<MissionTask__c> getMissionTask (ID MissionID)
    {
        set<ID> ISLIDs = new set<ID>();
        for( Mission__c m : [Select Id, InStoreLocationId__c FROM Mission__c where id=:MissionID])
        {
            ISLIDs.add(m.InStoreLocationId__c);
        }
        List<MissionTask__c > MissionTaskList = new List<MissionTask__c>([select id,Name,Status__c from MissionTask__c where ParentId__c =: MissionID AND IsRequired__c= true]);
        return MissionTaskList;
    }
    @AuraEnabled
    public static List<StoreProduct__c> saveData(List<StoreProduct__c> spList, List<Asset__c> AssetList, List<Mission__c> MissionList)
    {
        system.debug('inside save');
        List<StoreProduct__c> SPLIstToUpdate = new List<StoreProduct__c>();
        List<Asset__C> CustAssetLIstToUpdate = new List<Asset__c>();
        List<Mission__c> MissionListUpdate = new List<Mission__c>();
       
        for(StoreProduct__c sp: spList)
        {
            StoreProduct__c sp1 = new StoreProduct__c();
            sp1.ID = sp.id;
            sp1.ActualMSRP__c = sp.ActualMSRP__c;
            SPLIstToUpdate.add(sp1);
        }
        for(Asset__C ast: AssetList)
        {
            Asset__C ast1 = new Asset__C();
            ast1.ID = ast.id;
            ast1.Status__c = ast.Status__c;
            CustAssetLIstToUpdate.add(ast1);
        }
        for(Mission__c m : MissionList){
            
            Mission__c m1 = new Mission__c();
            m1.ID = m.Id;	
            if(m.Status__c!=null)
            m1.Status__c = m.Status__c;
            MissionListUpdate.add(m1);
        }
        
        if(SPLIstToUpdate!=null && SPLIstToUpdate.size()>0){
        update SPLIstToUpdate;
        }
        if(CustAssetLIstToUpdate!=null && CustAssetLIstToUpdate.size()>0){
        update CustAssetLIstToUpdate;
        }
        if(MissionListUpdate!=null && MissionListUpdate.size()>0){
        update MissionListUpdate;
        }
    
        return SPLIstToUpdate;
    }
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
        @AuraEnabled
          public String recordtype{get;set;}
	 }
}