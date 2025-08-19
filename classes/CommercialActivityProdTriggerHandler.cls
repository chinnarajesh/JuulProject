/*************************************************************************************************
Class Name         : CommercialActivityProdTriggerHandler
Version             : 1.0
Date Created        : 17-March-2021
Author              : Shreya Raut
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer             Date                    Description
* ---------------       -----------             ----------------------------------------------
**************************************************************************************************/
public class CommercialActivityProdTriggerHandler {
    public static boolean run = false;
    public static void productBundleCheck(List<CommercialActivityProduct__c> capList)
    {
        System.debug('Inside Trigger');
        String value;
        Set<String> ProductBundle = new Set<String>();
        String cap;
        Set<String> ProductDescription = new Set<String>();
        set<ID> caID = new set<ID>();
        Map<ID,String> PrdBundleType = new Map<ID,String>();
        set<String> prdDescription = new Set<String>();
        Map<String,List<CommercialActivityProduct__c>> CAPMap = new Map<string,List<CommercialActivityProduct__c>>();
        List<CommercialActivity__c> caItems = new List<CommercialActivity__c>();
        for(CommercialActivityProduct__c c:capList)
        {
            if(c.Product_bundle_Description__c!=null && c.Product_Bundle__c !=null )
                cap = String.valueOf(c.Product_bundle_Description__c.toUpperCase())+'='+String.valueOf(c.Product_Bundle__c.toUpperCase());
            caID.add(c.CommercialActivityId__c);
            PrdBundleType.put(c.id,c.Product_Bundle__c);
            prdDescription.add(c.Product_bundle_Description__c);
        }
        system.debug('Product Bundle'+PrdBundleType+'size'+ PrdBundleType.size());
        //fetch commercial activities linked
        if(caID!=null){
            caItems =[select id,Commercial_Activity_Status__c, Product_Bundle_Error__c from CommercialActivity__c where id =:caID];
        }
        for(CommercialActivityProduct__c cp : [select id,Product_Bundle__c,Product_bundle_Description__c from CommercialActivityProduct__c where 
                                               CommercialActivityId__c=: caID])
        {
            if(cp.Product_Bundle__c!=null && cp.Product_bundle_Description__c!=null){
                if(!CAPMap.containsKey(cp.Product_bundle_Description__c.toUpperCase()+'='+cp.Product_Bundle__c.toUpperCase())){
                    CAPMap.put(cp.Product_bundle_Description__c.toUpperCase()+'='+cp.Product_Bundle__c.toUpperCase(),new List<CommercialActivityProduct__c>());
                }
                CAPMap.get(cp.Product_bundle_Description__c.toUpperCase()+'='+cp.Product_Bundle__c.toUpperCase()).add(cp);
            }
        }
        system.debug('CAPMAP'+CAPMap);
        
        for(String d : CAPMap.keyset())
        {
            Integer j = CAPMAP.get(d).size();
            
            System.debug('J value'+j);
            if(j<2)
            {
                value='Error';
                String ProductBundles=d.SubStringAfter('=');
                String ProductDescriptions = d.substringBefore('=');
                if(ProductBundles!=null)
                    ProductBundle.add(ProductBundles);
                if(ProductDescriptions!=null)
                    ProductDescription.add(ProductDescriptions);
                System.debug('ProductBundle'+ProductBundle);
                System.debug('PRoduct Description'+ProductDescription);
                //break;
            }else{
                value='Success';
            }
        }
        System.debug('Value is'+value);
        
        List<CommercialActivity__c> updateCA = new List<CommercialActivity__c>();
        
        for(CommercialActivity__c ca :caItems){
            
            System.debug('CAPKey'+cap);//nullcheck
            if(CAPMAP.get(cap)!=null){
                Integer i = CAPMAP.get(cap).size();
                System.debug('i'+i);
                if(ProductBundle.size()>0){
                    System.debug('Inside 1st');
                    ca.Commercial_Activity_Status__c = false;
                    ca.Product_Bundle_Error__c ='For '+ProductBundle+' add more than 2 product with description '+ProductDescription;  
                }else{
                    System.debug('Inside 2nd');
                    ca.Commercial_Activity_Status__c = true;
                    ca.Product_Bundle_Error__c ='Products are successfully added.';
                }
            } else{
                System.debug('Inside 2nd');
                ca.Commercial_Activity_Status__c = true;
                ca.Product_Bundle_Error__c ='Products are successfully added.';
            }
            
            updateCA.add(ca);
        }
        update updateCA;
        
    }
    
    public static void ProductBundleEmptyCheck(List<CommercialActivityProduct__c> capList)
    {
        System.debug('inside ProductBundlePicklistCheck method');
        set<ID> caID = new set<ID>();
        Map<ID,string> prdBundleType = new Map<ID,string>();
        Map<ID,String> prdDescription = new Map<ID,String>();
        for(CommercialActivityProduct__c c:capList)
        {
            caID.add(c.CommercialActivityId__c);
            prdBundleType.put(c.id,c.Product_bundle__c);
            prdDescription.put(c.id,c.Product_bundle_Description__c);
        }
        for(CommercialActivityProduct__c cpa : capList)
        {
            
            if(prdBundleType.get(cpa.id)!=null && prdDescription.get(cpa.id)==null){
                cpa.addError('Please add Prodoct Bundle Description');
            }
        }
        
    }
    
    public static void productBundleCheckAfterDelete(List<CommercialActivityProduct__c> capList){
        
        System.debug('Inside Delete Trigger');
        Set<String> ProductBundle = new Set<String>();
        set<String> ProductDescription = new Set<String>();
        set<ID> caID = new set<ID>();
        Set<ID> capID = new set<ID>();
        Map<String,List<CommercialActivityProduct__c>> CAPMap = new Map<string,List<CommercialActivityProduct__c>>();
        Map<id,CommercialActivityProduct__c> NonPBCAPMap = new Map<id,CommercialActivityProduct__c>();
        Map<String, Integer> CAPSizeMap = new Map<String, Integer>();
        Set<string> ErrorRecords = new Set<String>();
        Set<string> SuccessRecords = new Set<String>();
        List<CommercialActivity__c> caItems = new List<CommercialActivity__c>();
        List<CommercialActivity__c> updateCA = new List<CommercialActivity__c>();
        for(CommercialActivityProduct__c c:capList)
        {
            if(c.CommercialActivityId__c!=null)
                caID.add(c.CommercialActivityId__c);
            if(c.id!=null)
                capID.add(c.id);
        }
        if(caID!=null){
            caItems =[select id,Commercial_Activity_Status__c, Product_Bundle_Error__c from CommercialActivity__c where id =:caID];
        }
        for(CommercialActivityProduct__c cp : [select id,Product_Bundle__c,Product_bundle_Description__c from CommercialActivityProduct__c where 
                                               CommercialActivityId__c=: caID and id!=:capID])
        {
            if(cp.Product_Bundle__c!=null && cp.Product_bundle_Description__c!=null){
                if(!CAPMap.containsKey(cp.Product_bundle_Description__c.toUpperCase()+'='+cp.Product_Bundle__c.toUpperCase())){
                    CAPMap.put(cp.Product_bundle_Description__c.toUpperCase()+'='+cp.Product_Bundle__c.toUpperCase(),new List<CommercialActivityProduct__c>());
                }
                CAPMap.get(cp.Product_bundle_Description__c.toUpperCase()+'='+cp.Product_Bundle__c.toUpperCase()).add(cp);
            }else{
                NonPBCAPMap.put(cp.id,cp);
            }
        }
        system.debug('CAPMAP'+CAPMap);
        for(String d : CAPMap.keyset())
        {
            CAPSizeMap.put(d,CAPMAP.get(d).size());
        }
        System.debug('CAPSizeMap'+CAPSizeMap);
        System.debug('CAPSizeMapSize'+CAPSizeMap.size());
        System.debug('CAPSizeMapIsEmpty'+CAPSizeMap.isEmpty());
        
        
        for(String s :CAPSizeMap.keyset())
        {
            if(CAPSizeMap.get(s)<2)
            {
                String ProductBundles = s.SubStringAfter('=');
                String ProductDescriptions = s.substringBefore('=');
                if(ProductBundles!=null)
                    ProductBundle.add(ProductBundles);
                if(ProductDescriptions!=null)
                    ProductDescription.add(ProductDescriptions);
                ErrorRecords.add(s);
            }else{
                
                SuccessRecords.add(s);
            }
        }
        System.debug('ErrorRecords'+ErrorRecords);
        System.debug('ErrorRecords'+ErrorRecords.size());
        System.debug('SuccessRecords'+SuccessRecords);
        System.debug('SuccessRecords'+SuccessRecords.size());
        for(CommercialActivity__c ca :caItems){
            if(ErrorRecords.size()<=0 && SuccessRecords.size()>0){
                System.debug('inside if ErrorRecords');
                ca.Commercial_Activity_Status__c = true;
                ca.Product_Bundle_Error__c ='Products are successfully added.';
            }else if(ErrorRecords.size()>0 && SuccessRecords.size()<=0){
                System.debug('inside else ErrorRecords');
                
                ca.Commercial_Activity_Status__c = false;
                ca.Product_Bundle_Error__c ='For '+ProductBundle+' add more than 2 product with description '+ProductDescription;  
                
            }else if(ErrorRecords.size()>0 && SuccessRecords.size()>0){
                System.debug('inside both ');
                ca.Commercial_Activity_Status__c = false;
                ca.Product_Bundle_Error__c ='For '+ProductBundle+' add more than 2 product with description '+ProductDescription;  
            }else{
                System.debug('inside both null ');
                ca.Commercial_Activity_Status__c = false;
                ca.Product_Bundle_Error__c ='Please add products';  
            }
            
            updateCA.add(ca);
        }
        update updateCA;
    } 
    
    public static void checkPricingMatrix (List<CommercialActivityProduct__c> capList)
    {
        
        //store product ids in a map
        //fetch the pricing matrix records of respective products
        //check if the date is less than 180 
        //if the product id is there then update the field 
        //
        system.debug('handler run1'+CommercialActivityProdTriggerHandler.run);
        CommercialActivityProdTriggerHandler.run = true;
        system.debug('handler run2'+CommercialActivityProdTriggerHandler.run);
        set<ID> productID = new set<ID>();
        
        for(CommercialActivityProduct__c cap: capList)
        {
            if(cap.ProductId__c!=null)
                productID.add(cap.ProductId__c);
            cap.Pricing_Matrix_Status__c ='All the pricing matrix records are updated';
        }
        System.debug('Test productID'+productID);
        Date startDate = Date.today();  
        Map<ID,PricingMatrix__c> PMMap = new Map<ID,PricingMatrix__c>();
        if(productID!=null && productID.size()>0){
            for(PricingMatrix__c p : [select id,End_Date__c,StateTerritoryISO2__c,Active__c,ProductId__c from PricingMatrix__c where ProductId__c  =: productID and Active__c = true  ]){
               
                Date endDate =p.End_Date__c;
                Integer noOfDays = startDate.daysBetween( endDate );
                if(noOfDays!=null && noOfDays <180 )
                    PMMAp.put(p.id,p);
            }
        }
        system.debug('test PMMAp'+PMMAp);
        if(PMMAp!=null && PMMAp.size()>0 && !PMMAp.isEmpty())
            for(ID i : PMMap.keyset())
        {
            system.debug('test 1');
            for(CommercialActivityProduct__c c : capList){
                system.debug('test 2');
                if(PMMap.get(i)!=null &&  PMMap.get(i).ProductId__c !=null  )
                    if((PMMap.get(i).ProductId__c == c.ProductId__c)  && c.ProductType__c=='Juul Product')
                {
                    system.debug('test PMMap.get(i).StateTerritoryISO2__c'+PMMap.get(i).StateTerritoryISO2__c);
                    string s1 = c.Pricing_Matrix_Status__c;
                    if(s1!=null && !s1.contains( PMMap.get(i).StateTerritoryISO2__c) && !s1.contains('All the')){
                        if(PMMap.get(i).StateTerritoryISO2__c !=null)
                            system.debug('inside 1');
                            c.Pricing_Matrix_Status__c =   c.Pricing_Matrix_Status__c +','+ PMMap.get(i).StateTerritoryISO2__c  ;
                    }else{
                         system.debug('inside 2');
                        if(PMMap.get(i).StateTerritoryISO2__c !=null) 
                            c.Pricing_Matrix_Status__c = 'Please reach out to your Price Execution Manager to have your region pricing matrix updated for ' +PMMap.get(i).StateTerritoryISO2__c  ;
                    }
                }
            }
        }
        
    }
    
}