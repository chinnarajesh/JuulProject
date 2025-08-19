/**********************************************************************/
/* VERSION     AUTHOR                  DATE                           */
/*     1.0     Pushkar Gangwar         05-20-2020                     */
/* Class Name: KAMCreateMissionTaskHelper      		              */
/* Description: Helper class for KAMCreateAssesmentTaskForVisitBatch
* to process execute method 							 	  		  */
/**********************************************************************/

public class KAMCreateMissionTaskHelper {
    /*
     * Method Name : getVisitAndActionPlanTemplateItems
     * Params :  List (ActionPlan)
     * Description : getVisitAndActionPlanTemplateItems method process the Maps of Action plan, Action plan Template and Action Plan Template Item.
     * So that we can reduce or avoid query in for loops.
     */
     public static void getMissionAndActionPlanTemplateItems(List < ActionPlan__c > APList) {
        Map < ID, List < ActionPlan__c >> APTandAPMap = new Map < ID, List < ActionPlan__c >> ();
         //Creating Map of Action Plan Template and Action Plan to avoid for loop queries
        for (ActionPlan__c actionPlan: APList) {
            if (APTandAPMap.get(actionPlan.ActionPlanTemplateId__c) == null) {
                APTandAPMap.put(actionPlan.ActionPlanTemplateId__c, New List < ActionPlan__c > ());
            }
            APTandAPMap.get(actionPlan.ActionPlanTemplateId__c).add(actionPlan);
        }
        Map < Id, List < ActionPlanTemplateItem__c >> APTandAPTImmap = new Map < Id, List < ActionPlanTemplateItem__c >> ();
        List < ActionPlanTemplateItem__c > APTIlist = new List < ActionPlanTemplateItem__c > ();
        APTIlist = [SELECT ID, ActionPlanTemplateId__c, Priority__c, Description__c, Required__c,
                    Sequence__c, Subject__c, Comments__c FROM ActionPlanTemplateItem__c WHERE ActionPlanTemplateId__c =: APTandAPMap.KeySet()];
         //Creating Map of Action Plan Template and Action Plan Template Item to avoid for loop queries
         if (APTIlist.size() > 0) {
            for (ActionPlanTemplateItem__c ActionPlanItemObj: APTIlist) {
                if (APTandAPTImmap.get(ActionPlanItemObj.ActionPlanTemplateId__c) == NULL) {
                    APTandAPTImmap.put(ActionPlanItemObj.ActionPlanTemplateId__c, New List < ActionPlanTemplateItem__c > ());
                }
                APTandAPTImmap.get(ActionPlanItemObj.ActionPlanTemplateId__c).add(ActionPlanItemObj);
            }
        }
         if(APTandAPTImmap != null && APTandAPMap!= null){
             KAMCreateMissionTaskHelper.createRecords(APTandAPTImmap, APTandAPMap);
         }
         
    }

    
    /*
     * Method Name : createRecords
     * Params :  Map, Map
     * Description : Create Assesment Task and ActionPlan Itemm records. This method will also update the Action Plan process checkbox.
     */
   public static void createRecords(Map < Id, List < ActionPlanTemplateItem__c >> APTandAPTImmap, Map < ID, List < ActionPlan__c >> APTandAPMap) {
        try {
            
           /* Fetching mapping fields from Data_Mapping metadata START */
            List<Data_Mapping__mdt> APTIandAPImapping = [SELECT Source_Object__c, Source_Field__c,
                                       Target_Object__c, Target_Field__c FROM Data_Mapping__mdt 
                                       WHERE Target_Object__c = 'ActionPlanItem__c'];

			List<Data_Mapping__mdt> APITandMTMapping = [SELECT Source_Object__c, Source_Field__c,
                                       Target_Object__c, Target_Field__c FROM Data_Mapping__mdt 
                                       WHERE Target_Object__c = 'MissionTask__c'];

            system.debug('APTIandAPImapping-- '+ APTIandAPImapping);
            system.debug('APITandMTMapping-- '+ APITandMTMapping);
            /* Fetching mapping fields from Data_Mapping metadata END */
            
            List < ActionPlan__c > APListTOUpdate = new List < ActionPlan__c > ();
            Map<ActionPlanItem__c, MissionTask__c> APIandAssesmentTaskMap = new Map<ActionPlanItem__c, MissionTask__c>();
            for (Id actionPlanTemplateId: APTandAPTImmap.KeySet()) {
                List < ActionPlanTemplateItem__c > APtemplateItem = new List < ActionPlanTemplateItem__c > ();
                APtemplateItem = APTandAPTImmap.get(actionPlanTemplateId);
                for (ActionPlan__c actionPlanObj: APTandAPMap.get(actionPlanTemplateId)) {
                    for (ActionPlanTemplateItem__c APTitem: APtemplateItem) {
                        // creating Action plan item record.
						ActionPlanItem__c APItem = new ActionPlanItem__c();
                        for(Data_Mapping__mdt ActionPlanItemMaping :  APTIandAPImapping){
                           APItem.put('ActionPlanId__c', actionPlanObj.get('Id'));  
                           if(ActionPlanItemMaping.Source_Object__c == 'ActionPlan__c'){
                                system.debug('Creating ActionPlanItem =' + ActionPlanItemMaping.Source_Object__c+'.'+ ActionPlanItemMaping.Source_Field__c+ ' in '+ ActionPlanItemMaping.Target_Object__c+'.'+ActionPlanItemMaping.Target_Field__c);
                                APItem.put(ActionPlanItemMaping.Target_Field__c, actionPlanObj.get(ActionPlanItemMaping.Source_Field__c));
                            }
                            if(ActionPlanItemMaping.Source_Object__c == 'ActionPlanTemplateItem__c'){
                                APItem.put(ActionPlanItemMaping.Target_Field__c, APTitem.get(ActionPlanItemMaping.Source_Field__c ));
                            }
                            
                        }
                        MissionTask__c assesTask = new MissionTask__c();
                        for(Data_Mapping__mdt missionTaskMaping :  APITandMTMapping){
                            if(missionTaskMaping.Source_Object__c == 'ActionPlan__c'){
                             	system.debug('Creating MissionTask = '+ missionTaskMaping.Source_Object__c+'.' + missionTaskMaping.Source_Field__c+ ' in '+missionTaskMaping.Target_Object__c+'.'+ missionTaskMaping.Target_Field__c);
                                 assesTask.put(missionTaskMaping.Target_Field__c, actionPlanObj.get(missionTaskMaping.Source_Field__c));
                             }
                            if(missionTaskMaping.Source_Object__c == 'ActionPlanTemplateItem__c'){
                                assesTask.put(missionTaskMaping.Target_Field__c, APTitem.get(missionTaskMaping.Source_Field__c ));
                            }                            
                        }
                        assesTask.put('ParentId__c', actionPlanObj.get('Mission__c'));
                        //JJ Added for Linking Mission Task with Account
                       // assesTask.put('AccountId__c',actionPlanObj.get('AccountId'));
                        //JJ Added for Linking Mission Task with Account
                        actionPlanObj.isProcessed__c = true;
                        //to map the actionplan item and mission task adding the values to APIandAssesmentTaskMap
                        APIandAssesmentTaskMap.put(APItem,assesTask);
                    }
                    APListTOUpdate.add(actionPlanObj);
                }
            }
            
            //Database.insert(APIandAssesmentTaskMap.values());
            if (APIandAssesmentTaskMap.values() != null && APIandAssesmentTaskMap.values().size() > 0) {
    			List < Database.SaveResult > insertMissionTaskResults = Database.Insert(APIandAssesmentTaskMap.values(), false);
    			List < Database.Error > listError = new List <Database.Error> ();
    			for (Integer index = 0, size = insertMissionTaskResults.size(); index < size; index++) {
        			if (!insertMissionTaskResults[index].isSuccess()) {
            			listError.addAll(insertMissionTaskResults[index].getErrors());
        			}
    			}
    			if (listError.size() > 0) {
                    system.debug('listError-- '+ listError);
        			LogEventTriggerHandler.insertBatchLog(listError, 'KAMCreateMissionTaskHelper', 'createRecords', 'Mission Task', 'Database.Insert_Failed');
    			}
			}
            
            
            //updating Action Plan Item mapped with mission tasks.
            List<ActionPlanItem__c> ActionPlanItemList = new List<ActionPlanItem__c>();
            for(ActionPlanItem__c API :  APIandAssesmentTaskMap.Keyset()){
                API.MissionTaskId__c= APIandAssesmentTaskMap.get(API).Id;
                ActionPlanItemList.add(API);
            }
            //Database.insert(ActionPlanItemList);
             if (ActionPlanItemList != null && ActionPlanItemList.size() > 0) {
    			List < Database.SaveResult > insertActionPlanItemResults = Database.Insert(ActionPlanItemList, false);
    			List < Database.Error > listError = new List <Database.Error> ();
    			for (Integer index = 0, size = insertActionPlanItemResults.size(); index < size; index++) {
        			if (!insertActionPlanItemResults[index].isSuccess()) {
            			listError.addAll(insertActionPlanItemResults[index].getErrors());
        			}
    			}
    			if (listError.size() > 0) {
                    system.debug('listError-- '+ listError);
        		LogEventTriggerHandler.insertBatchLog(listError, 'KAMCreateMissionTaskHelper', 'createRecords', 'Action Plan Item', 'Database.Insert_Failed');
    			}
			} 
            //Database.update(APListTOUpdate);
            
       		// Updating the Action plan with processes scheckboix and storing the error logs into logs
             if (APListTOUpdate != null && APListTOUpdate.size() > 0) {
    			List < Database.SaveResult > insertActionPlanResults = Database.Update(APListTOUpdate, false);
    			List < Database.Error > listError = new List <Database.Error> ();
    			for (Integer index = 0, size = insertActionPlanResults.size(); index < size; index++) {
        			if (!insertActionPlanResults[index].isSuccess()) {
            			listError.addAll(insertActionPlanResults[index].getErrors());
        			}
    			}
    			if (listError.size() > 0) {
        		LogEventTriggerHandler.insertBatchLog(listError, 'KAMCreateMissionTaskHelper', 'createRecords', 'Action Plan', 'Database.Update_Failed');
    			}
			}
            
            //return true;
        }
        Catch(Exception ex) {
            system.debug('Exception in line: ' + ex.getLineNumber());
            system.debug('Exception Message: ' + ex.getMessage());
            //return false;
        }
    }
}