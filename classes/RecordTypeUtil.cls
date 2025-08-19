/*******************************************************************************************
* @Name         RecordTypeUtil
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         10/29/2018
* @Group        Customer Service
* @Description  A class which returns record type info about an object
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         10/29/2018          Initial Creation
*******************************************************************************************/
public with sharing class RecordTypeUtil {
    //Method to get the recordTypeId
    public static Id recordTypeId(string obj, string recName) {
        Id recTypeId;
        if (obj != null && recName != null) {
            recTypeId = Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().get(recName).getRecordTypeId();
        }
        return recTypeId;
    }

    //Method to get the map of recordType Name as key and recordTypeId as value
    public static Map<String, Id> recordTypeMap(string obj) {
        Map<String, Id> recTypeNameWithIdMap = new Map<String, Id>();
        if (obj != null) {
            for (Schema.RecordTypeInfo recInfo : Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().values()) {
                recTypeNameWithIdMap.put(recInfo.getName(), recInfo.getRecordTypeId());
            }
        }
        return recTypeNameWithIdMap;
    }
}