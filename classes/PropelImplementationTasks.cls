global with sharing class PropelImplementationTasks {
    global class GetRequestsfromFlow{
        @InvocableVariable(label='Change Record' required=true) global PDLM__Change__c change;
        @InvocableVariable(label='Accessible By' required=true) global String accessibleBy;
        @InvocableVariable(label='Change Phase Id' required=true) global Id changePhaseId;
    }

    @InvocableMethod

    global static void PropelImplementationTasks(List<GetRequestsfromFlow> flows) {
        Set<PDLM__Change__c> changeRecords = new Set<PDLM__Change__c>();
        Map<PDLM__Change__c, List<String>> changeAccessibleByGroupsMap = new Map<PDLM__Change__c, List<String>>();
        Map<PDLM__Change__c, Id> changeChangePhaseIdMap = new Map<PDLM__Change__c, Id>();
        Map<String, Id> accountNameImplApproverMap = new Map<String, Id>();
        Map<String, Id> accountNameQualityReviewApproverMap = new Map<String, Id>();
        Map<String, PDLM__Change__c> changeNameChangeMap = new Map<String, PDLM__Change__c>();
        String[] groupNames = new String[]{};
        List<String> accountNamesList = new List<String>();
        List<PDLM__Project__c> projectsList = new List<PDLM__Project__c>();
        List<PDLM__Deliverable__c> activitiesList = new List<PDLM__Deliverable__c>();

        //Loop through records that trigger the Process Builder
        for (GetRequestsfromFlow fl : flows){
            changeRecords.add(fl.change);
            changeChangePhaseIdMap.put(fl.change, fl.changePhaseId);
            String[] tempGroupNames = fl.accessibleBy.split(';');
            changeAccessibleByGroupsMap.put(fl.change, tempGroupNames);
            groupNames.addAll(tempGroupNames);
        }

        System.debug('Group List: ' + groupNames);
        System.debug('changeAccessibleByGroupsMap: ' + changeAccessibleByGroupsMap);

        if (changeAccessibleByGroupsMap.size()==0){return; }

        //Get Account records
        for (Account acc : [SELECT Id, Name, Implementation_Approver__c, Quality_Review_Approver__c FROM Account WHERE Name in :groupNames]){
            accountNamesList.add(acc.Name);

            if (acc.Implementation_Approver__c != null){
                accountNameImplApproverMap.put(acc.Name, acc.Implementation_Approver__c);
            }
            
            if (acc.Quality_Review_Approver__c != null){
                accountNameQualityReviewApproverMap.put(acc.Name, acc.Quality_Review_Approver__c);
            }
        }

        System.debug('accountNamesList: ' + accountNamesList);
        System.debug('accountNameImplApproverMap: ' + accountNameImplApproverMap);
        System.debug('accountNameQualityReviewApproverMap: ' + accountNameQualityReviewApproverMap);

        //Loop through changes and then groups; a project needs to be createdd first
        for (PDLM__Change__c chg: changeAccessibleByGroupsMap.keySet()){
            changeNameChangeMap.put(chg.Name, chg);

            for (String groupName : changeAccessibleByGroupsMap.get(chg)){
                if (accountNamesList.contains(groupName)){
                    PDLM__Project__c project = new PDLM__Project__c();
                    project.CM_Name__c = groupName;
                    project.Name = chg.Name + ' - ' + groupName + ' Project';
                    project.PDLM__Status__c = 'Open';
                    projectsList.add(project);
                }
            }
        }

        System.debug('projectsList: ' + projectsList);
        if (projectsList.size() > 0){
            insert projectsList;
        }

        //Loop through changes and then groups; a task is needed for each group when there is a matching Account record
        for (PDLM__Project__c proj : projectsList){
            String projectPrefix = proj.Name.split(' - ')[0];
            PDLM__Change__c changeRecord = changeNameChangeMap.get(projectPrefix);
            String groupName = proj.CM_Name__c;

            if (accountNamesList.contains(groupName)){
                PDLM__Deliverable__c activity = new PDLM__Deliverable__c();
                activity.CM_Supplier_Manufacturer__c = groupName;
                activity.Name = changeRecord.Name + ' / ' + groupName + ' / Implementation Task';
                activity.PDLM__Assigned_To__c = accountNameImplApproverMap.containsKey(groupName) ? accountNameImplApproverMap.get(groupName) : changeRecord.CreatedById;
                activity.PDLM__Change_Phase__c = changeChangePhaseIdMap.get(changeRecord);
                activity.PDLM__Change__c = changeRecord.Id;
                activity.PDLM__Project__c = proj.Id;
                activity.PDLM__Type__c = 'Task';
                activity.Quality_Review_Approver__c = accountNameQualityReviewApproverMap.get(groupName);
                activitiesList.add(activity);
            }
        }

        System.debug('activitiesList: ' + activitiesList);
        if (activitiesList.size() > 0){
            insert activitiesList;
        }
    }
}