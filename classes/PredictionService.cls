public class PredictionService {
        public static  List<EV_Model_Configuration__mdt> getModels(){
        list<EV_Model_Configuration__mdt> evModels=new list<EV_Model_Configuration__mdt>();
        if(!Test.isRunningTest()){
          evModels=[select Question_Label_Search__c,Model_Id__c,DeveloperName from EV_Model_Configuration__mdt];
        }else{
        EV_Model_Configuration__mdt  evModel = new EV_Model_Configuration__mdt();
           evModel.DeveloperName = 'EV';
            evModel.Question_Label_Search__c = '(EV)';
             evModel.Model_Id__c = 'ZF2DFZ2W36UJLVTAPSE6KSQQOY';
             evModels.add(evModel);
        }
        return evModels;
        }
        public static List<EV_Prediction__c> getEVPredictions(Id CDId, String FileName, Id FormId, Id RTId, Id AccountId, list<VisionService.prediction> result){
        system.debug('****EV Prediction Generation');
            EV_Prediction__c evPredict;
        List<EV_Prediction__c> evPredictList = new List<EV_Prediction__c> ();
        set<String> resultSet=new set<String>();
        for(VisionService.prediction ei : result){
            evPredict = new EV_Prediction__c();
            evPredict.Label__c = ei.label;
            evPredict.Probability__c = ei.probability;
            evPredict.minX__c = ei.boundingBox.minX;
            evPredict.maxX__c = ei.boundingBox.maxX;
            evPredict.minY__c = ei.boundingBox.minY;
            evPredict.maxY__c = ei.boundingBox.maxY;
            
            evPredict.Form__c= FormId;  
            evPredict.Retail_Theater__c = RTId;
            evPredict.Account__c        = AccountId;
            evPredict.ContentDocument_Id__c  = CDId;
            evPredict.File_Name__c = FileName;
            resultSet.add(ei.label);
            evPredictList.add(evPredict);
          }
        for(Product2 ProdRec:[select Id, Einstein_Vision_External_Id__c from Product2 where Einstein_Vision_External_Id__c !=null and Einstein_Vision_External_Id__c !='' ] )
        {
            if(ProdRec.Einstein_Vision_External_Id__c!=null && ProdRec.Einstein_Vision_External_Id__c!='' && !resultSet.Contains(ProdRec.Einstein_Vision_External_Id__c)){
            evPredict = new EV_Prediction__c();
            evPredict.Label__c = ProdRec.Einstein_Vision_External_Id__c;
            evPredict.Probability__c = 0;
            evPredict.minX__c = 0;
            evPredict.maxX__c = 0;
            evPredict.minY__c = 0;
            evPredict.maxY__c = 0;
            
            evPredict.Form__c= FormId;  
            evPredict.Retail_Theater__c = RTId;
            evPredict.Account__c        = AccountId;
            evPredict.ContentDocument_Id__c  = CDId;
            evPredict.File_Name__c = FileName;
            resultSet.add(ProdRec.Einstein_Vision_External_Id__c);
            evPredictList.add(evPredict);
            }
                
        }



         return evPredictList;
       }  
       public static void EVPredictionUpdateLocations(Set<Id> setEVCDIds, Map<Id,Id> mapCD2Form, Map<Id,Id> mapForm2RT)   {
        String FirstRec;
        Integer LastMinY = null, LastROW = null, LastROWSeq = null, LastLocation=null;
        List<EV_Prediction__c> listEVP_YAll = new List<EV_Prediction__c>();
        List<EV_Prediction__c> listEVP_XAll = new List<EV_Prediction__c>();
        Map<String,Id> mapEVExternalIS2Id = new Map<String,Id>();
        Id RTId=null, FormId=null;
        Integer EVSort=0;
        Set<Id> SetRTProcessedIds = new Set<Id>(); 
        
        List<Product2> ProductList = [select Id, Einstein_Vision_External_Id__c from Product2 where Einstein_Vision_External_Id__c !=null];
        for(Product2 ProdRec:ProductList ){
            mapEVExternalIS2Id.put(ProdRec.Einstein_Vision_External_Id__c, ProdRec.Id);
        }
        
        for(Id Y_CDId :setEVCDIds) { 
            FirstRec = 'Yes';
            LastMinY = null; 
            LastROW = null; 
            LastROWSeq = null; 
            LastLocation=null;
            FormId    = mapCD2Form.get(Y_CDId);  
            RTId      = mapForm2RT.get(mapCD2Form.get(Y_CDId));
            
            List<EV_Prediction__c> listEVP_Y = [SELECT Id, Name, Label__c, Probability__c, maxY__c, maxX__c, minX__c, minY__c,  
                                                     Row_Number__c, Row_Sequence__c, Relative_Location__c, Account__c, Product__c  
                                                FROM EV_Prediction__c  Where Retail_Theater__c = :RTId and Form__c = :FormId and ContentDocument_Id__c = :Y_CDId
                                               Order by minY__c Asc];
            
            if (listEVP_Y.Size() > 0) {
                 for(EV_Prediction__c EVP : listEVP_Y){
                      if (FirstRec == 'Yes'){
                          FirstRec = 'No';
                          EVP.Row_Number__c = 1;
                          EVP.Row_Sequence__c = 1;
                          EVP.Relative_Location__c = 1; 
                          LastROW  = 1;
                      } 
                      else {
                          if (Integer.valueOf(EVP.minY__c) - LastMinY > 70) 
                           {  LastROW++; }
                          EVP.Row_Number__c = LastROW; 
                      }
                      LastMinY = Integer.valueOf(EVP.minY__c);
                      if(mapEVExternalIS2Id.ContainsKey(EVP.Label__c)) {
                         EVP.Product__c = mapEVExternalIS2Id.get(EVP.Label__c);
                      }
                  }
                  listEVP_YAll.addall(listEVP_Y);
            }
        }
        if(listEVP_YAll.size() > 0) {
            Update listEVP_YAll;
             System.debug('listEVP_YAll ************ '+listEVP_YAll);
        }
            
        for(Id X_CDId :setEVCDIds) {
            FirstRec = 'Yes';
            LastROW  = null; 
            FormId    = mapCD2Form.get(X_CDId);  
            RTId      = mapForm2RT.get(mapCD2Form.get(X_CDId));
            
            list<EV_Prediction__c> listEVP_X = [SELECT Id, Name, Label__c, Probability__c, maxY__c, maxX__c, minX__c, minY__c, Row_Number__c, 
                                                Row_Sequence__c, Relative_Location__c, Account__c, Retail_Theater__c, Form__c, ContentDocument_Id__c, Product__c, File_Name__c 
                                                FROM EV_Prediction__c where Retail_Theater__c = :RTId and Form__c = :FormId and ContentDocument_Id__c = :X_CDId
                                                Order By Row_Number__c Asc, minX__c Asc]; 
            for (EV_Prediction__c EVP:listEVP_X){
                if (FirstRec == 'Yes'){
                    FirstRec = 'No';
                    LastROW  = 1;
                    LastROWSeq = 0;
                    LastLocation = 0;
                } 
                
                if (Integer.valueOf(EVP.Row_Number__c) == LastROW) 
                {   LastROWSeq++ ;  } 
                else { LastROWSeq = 1; 
                      LastROW++; }
                
                LastLocation++ ; 
                EVP.Row_Sequence__c      = LastROWSeq; 
                EVP.Relative_Location__c = LastLocation;
                EVSort++;
                EVP.EV_Sort__c = EVSort;
            }
            listEVP_XAll.addall(listEVP_X);
        }
        
        if(listEVP_XAll.size() > 0) {
            update listEVP_XAll;
            System.debug('listEVP_XAll ************ '+listEVP_XAll);
        }
            
        AggregateResult[] results = [SELECT  Account__c, Retail_Theater__c, Form__c, ContentDocument_Id__c, Product__c, File_Name__c, Label__c, Count(Id) totalCount,Sum(Probability__c) sumprobability   
                                     FROM EV_Prediction__c where Retail_Theater__c = :RTId and Form__c = :FormId and ContentDocument_Id__c IN :setEVCDIds
                                     Group By Account__c, Retail_Theater__c, Form__c, ContentDocument_Id__c, Product__c, File_Name__c, Label__c
                                     Order By ContentDocument_Id__c, Label__c Asc]; 
        list<Audit_Facings__c> listAF = new list<Audit_Facings__c>();
        Audit_Facings__c   newAF;  
        for(AggregateResult ar : results) {
           newAF = new Audit_Facings__c();  
            newAF.Account__c = (Id)ar.get('Account__c');
            newAF.Retail_Theater__c = (Id)ar.get('Retail_Theater__c');
            newAF.Form__c = (Id)ar.get('Form__c');
            newAF.ContentDocument_Id__c = (Id)ar.get('ContentDocument_Id__c');
            newAF.Product__c = (Id)ar.get('Product__c');
            newAF.File_Name__c = (String)ar.get('File_Name__c');
            newAF.name = (String)ar.get('Label__c');
            newAF.Number_of_Facings__c =(Decimal)ar.get('sumprobability')==0?(Decimal)ar.get('sumprobability'):(Integer)ar.get('totalCount');
            listAF.add(newAF);
            
            SetRTProcessedIds.add((Id)ar.get('Retail_Theater__c'));
        }
       if(listAF.Size()>0){
           Insert listAF;
         System.debug('listAF ************ '+listAF);
        }
        
        if(SetRTProcessedIds.Size()>0){
            list<Retail_Theater__c> ListRTProcessed =new list<Retail_Theater__c>();
            //Retail_Theater__c NewRTRec;
            for(Retail_Theater__c newRTrec:[select id,Is_Processed__c from Retail_Theater__c where id in:SetRTProcessedIds  and Is_Processed__c=:false]){
                //NewRTRec = new Retail_Theater__c();
                //NewRTRec.Id = RTRecId;
                NewRTRec.Is_Processed__c = True;
                ListRTProcessed.add(NewRTRec);
            }
            if(!ListRTProcessed.isempty())
            Update ListRTProcessed;
            System.debug('ListRTProcessed ************ '+ListRTProcessed);
        }
    }
}