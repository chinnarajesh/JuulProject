public class AssortmentProductHandler {
    
    public static void checkPricingMatrix(List<AssortmentProduct__c> AssProdList)
    {
        set<ID> productID = new set<ID>();
            
            for(AssortmentProduct__c cap: AssProdList)
            {
                if(cap.ProductId__c!=null)
                productID.add(cap.ProductId__c);
                   cap.Pricing_Matrix_Status__c = 'All the pricing matrix records are updated';
            }
            System.debug('Test productID'+productID);
            Date startDate = Date.today();  
            Map<String,PricingMatrix__c> PMMap = new Map<String,PricingMatrix__c>();
        if(productID!=null && productID.size()>0){
            for(PricingMatrix__c p : [select id,End_Date__c,StateTerritoryISO2__c,ProductId__c from PricingMatrix__c where ProductId__c  =: productID  ]){
                String key = p.id+'-'+p.ProductId__c;
                Date endDate =p.End_Date__c;
                Integer noOfDays = startDate.daysBetween( endDate );
                if(noOfDays!=null && noOfDays <180 )
                    PMMAp.put(key,p);
            }
        }
        system.debug('test PMMAp'+PMMAp);
        if(PMMap.size()>0 && !PMMap.isEmpty())
            for(String i : PMMap.keyset())
            {
                system.debug('test 1');
                for(AssortmentProduct__c c : AssProdList){
                    if(PMMap.get(i)!=null && PMMap.get(i).ProductId__c!=null )
                    if((PMMap.get(i).ProductId__c == c.ProductId__c))
                    {
                         string s1 = c.Pricing_Matrix_Status__c;
                          if(s1!=null && !s1.contains( PMMap.get(i).StateTerritoryISO2__c) && !s1.contains('All the')){
                           if( PMMap.get(i).StateTerritoryISO2__c!=null)
                   c.Pricing_Matrix_Status__c =   c.Pricing_Matrix_Status__c +','+ PMMap.get(i).StateTerritoryISO2__c  ;
                    }else{
                         if( PMMap.get(i).StateTerritoryISO2__c!=null)
                        c.Pricing_Matrix_Status__c = 'Please reach out to your Price Execution Manager to have your region pricing matrix updated for ' +PMMap.get(i).StateTerritoryISO2__c  ;
                    }
                    }
                }
            }
        
    }

}