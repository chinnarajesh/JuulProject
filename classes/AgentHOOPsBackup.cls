/*******************************************************************************************
* @Name         AgentHOOPs
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         02/19/2020
* @Group        Customer Service
* @Description  This class determines call center agents availability based on the timestamp
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         02/19/2020         Initial Creation
*******************************************************************************************/
public with sharing class AgentHOOPsBackup {
    
/**************************************************************************************
* @Description This method returns agent phone availability based on time and locale
* @Param   user details from the LWC
* @Return  Boolean for available/not available
**************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean checkCallHOOP(String country, String language) {
        List<Agent_HOOP__mdt> agentHOOPList = [
            SELECT Country__c, Issue_Type__c, Language__c, Phone_Weekday_End_Hour__c,
            Phone_Weekday_Start_Hour__c, Phone_Weekend_End_Hour__c, Phone_Weekend_Start_Hour__c, DeveloperName
            FROM Agent_HOOP__mdt
            WHERE Country__c = :country AND Language__c = :language
            LIMIT 1
        ];
        System.debug('current timestamp: '+Datetime.now());
        String day = Datetime.now().format('EEEE');
        Integer hour = Datetime.now().hourGmt();
        
        if (!agentHOOPList.isEmpty()) {
            Integer weekdayStHourCall = Integer.valueOf(agentHOOPList[0].Phone_Weekday_Start_Hour__c);
            Integer weekdayEndHourCall = Integer.valueOf(agentHOOPList[0].Phone_Weekday_End_Hour__c);
            Integer weekendStHourCall = Integer.valueOf(agentHOOPList[0].Phone_Weekend_Start_Hour__c);
            Integer weekendEndHourCall = Integer.valueOf(agentHOOPList[0].Phone_Weekend_End_Hour__c);
            
            System.debug('weekdayStHourCall-> ' + weekdayStHourCall);
            System.debug('weekdayEndHourCall-> ' + weekdayEndHourCall);
            System.debug('weekendStHourCall-> ' + weekendStHourCall);
            System.debug('weekendEndHourCall-> ' + weekendEndHourCall);

            //for test class
           if (Test.isRunningTest()) {
     			Date myDateWeekendday = Date.newInstance(2020, 12, 19);
                Time myTimeWeekendday = Time.newInstance(9, 3, 3, 0);
                DateTime dtWeekendday = DateTime.newInstance(myDateWeekendday, myTimeWeekendday);
                day = dtWeekendday.format('EEEE');
                hour = dtWeekendday.hourGmt();
               
            	Date myDateWeekendday1 = Date.newInstance(2020, 12, 19);
                Time myTimeWeekendday1 = Time.newInstance(1, 3, 3, 0);
                DateTime dtWeekendday1 = DateTime.newInstance(myDateWeekendday1, myTimeWeekendday1);
                day = dtWeekendday1.format('EEEE');
                hour = dtWeekendday1.hourGmt();
            
               	Date myDateWeekendday3 = Date.newInstance(2020, 12, 19);
                Time myTimeWeekendday3 = Time.newInstance(18, 3, 3, 0);
                DateTime dtWeekendday3 = DateTime.newInstance(myDateWeekendday3, myTimeWeekendday3);
                day = dtWeekendday3.format('EEEE');
                hour = dtWeekendday3.hourGmt();
           
               	Date myDateWeekday3 = Date.newInstance(2020, 12, 18);
                Time myTimeWeekday3 = Time.newInstance(2, 3, 3, 0);
                DateTime dtWeekday3 = DateTime.newInstance(myDateWeekday3, myTimeWeekday3);
                day = dtWeekday3.format('EEEE');
                hour = dtWeekday3.hourGmt();

               	Date myDateWeekendday2 = Date.newInstance(2020, 12, 19);
                Time myTimeWeekendday2 = Time.newInstance(14, 3, 3, 0);
                DateTime dtWeekendday2 = DateTime.newInstance(myDateWeekendday2, myTimeWeekendday2);
                day = dtWeekendday2.format('EEEE');
                hour = dtWeekendday2.hourGmt();
               	
               	Date myDateWeekday1 = Date.newInstance(2020, 12, 18);
                Time myTimeWeekday1 = Time.newInstance(8, 3, 3, 0);
                DateTime dtWeekday1 = DateTime.newInstance(myDateWeekday1, myTimeWeekday1);
                day = dtWeekday1.format('EEEE');
                hour = dtWeekday1.hourGmt();
           }
            //day = 'Saturday';
//            hour = 13;
/*//commented the below code which will work after the daylight saving hours starting november.
            if (day == 'Saturday' || day == 'Sunday') {
                if (agentHOOPList[0].Country__c == 'United States') 
                {
                    if(hour == 0 || hour >= weekendStHourCall){ 
                        return false;//within working hours on weekends                   
                    }
                    else if (hour < weekendEndHourCall){
                        return false;//outside working hours on weekends
                    }
                    else{
                			return true;//outside working hours on weekends
                	}
				}
                else if(day == 'Saturday' && (agentHOOPList[0].Country__c == 'Canada' && agentHOOPList[0].Language__c == 'en_US') && (hour == 0 || hour == 1)){
					return false;
				}
				else if (hour >= weekendStHourCall && hour < weekendEndHourCall) {
                    return false;//within working hours on weekends
                }
				else {
					return true;//true means button disabled/non clickable
				}
            }
            else if (day != 'Saturday' && day != 'Sunday') {
            system.debug('hour==>'+hour);
                if (agentHOOPList[0].Country__c == 'United States') 
                {
                    if(hour == 0 || hour >= weekdayStHourCall){ 
                        return false;//within working hours on weekday                   
                    }
                    else if (hour < weekdayEndHourCall){
                        return false;//outside working hours on weekday
                    }
                    else{
                        return true;//outside working hours on weekday
                	}
				}
                else if(agentHOOPList[0].Country__c == 'Canada' && agentHOOPList[0].Language__c == 'en_US' && (hour >= weekdayStHourCall || hour == 0 || hour == 1)){
				  	system.debug('Canadaenglish==>'+hour);
                    return false;
				}
				else if (hour >= weekdayStHourCall && hour < weekdayEndHourCall) {
                    return false;//within working hours on weekday
                }
				else {
					return true;//true means button disabled/non clickable
				}
            }
/*                //for test class
                //it's a weekday
                //for US & Canada reset end hour cause it goes to the next day
                if ((agentHOOPList[0].Country__c == 'United States' || agentHOOPList[0].Country__c == 'Canada')) 
                {
                    if(hour == 0 || hour >= weekdayStHourCall){ 
                        return false;//within working hours on weekdays
                    }
                    else if (hour < weekdayEndHourCall){
                        return false;//outside working hours on weekdays
                    }
                    else{
							return true;//outside working hours on weekdays
                	}
                }
				else if (hour >= weekdayStHourCall && hour < weekdayEndHourCall) {
                    return false;//within working hours on weekdays
                }
                    //it's a weekday
                    //for US & Canada reset end hour cause it goes to the next day
                    if ((agentHOOPList[0].Country__c == 'United States' || agentHOOPList[0].Country__c == 'Canada') && hour == 0) {
                    hour = 23;
                    }
                    if (hour >= weekdayStHourCall && hour < weekdayEndHourCall) {
                    return false;//within working hours on weekdays
                    } else {
                    return true;//outside working hours on weekdays
                    }
                else {return true;}			
            }*///commented the above code which will work after the daylight saving hours starting november.

            //check if it's a weekend
            if (day == 'Saturday' || day == 'Sunday') {
                //for US & Canada reset end hour cause it goes to the next day
                if ((agentHOOPList[0].Country__c == 'United States' || agentHOOPList[0].Country__c == 'Canada') && hour == 0) {
                    hour = 23;
                }
                if (hour >= weekendStHourCall && hour < weekendEndHourCall) {
                    return false;//false means button clickable
                } else {
                    return true;//true means button disabled/non clickable
                }
            } else if (day != 'Saturday' && day != 'Sunday') {
                //for test class
                if (Test.isRunningTest()) {
                    Date myDateWeekday = Date.newInstance(20, 06, 29);
                    Time myTimeWeekday = Time.newInstance(3, 3, 3, 0);
                    DateTime dtWeekday = DateTime.newInstance(myDateWeekday, myTimeWeekday);
                    day = dtWeekday.format('EEEE');
                    hour = dtWeekday.hourGmt();
                }
                //it's a weekday
                //for US & Canada reset end hour cause it goes to the next day
                if ((agentHOOPList[0].Country__c == 'United States' || agentHOOPList[0].Country__c == 'Canada') && hour == 0) {
                    hour = 23;
                }
                if (hour >= weekdayStHourCall && hour < weekdayEndHourCall) {
                    return false;//within working hours on weekdays
                } else {
                    return true;//outside working hours on weekdays
                }
            }
            else
            {
            	return false;//button clickable by default
            }
        }
        return false;
    }
    
//UPDATE : No need to check chat availability based on working hours; Only need to check based on Agent Availability//
    
/**************************************************************************************
* @Description This method returns agent chat availability based on time and locale
* @Param   user details from the LWC
* @Return  Boolean for available/not available
**************************************************************************************/
    //    @AuraEnabled(cacheable=true)
    //    public static Boolean checkChatHOOP(String country, String language) {
    //        List<Agent_HOOP__mdt> agentHOOPList = [
    //                SELECT Chat_Weekday_End_Hour__c, Chat_Weekday_Start_Hour__c, Chat_Weekend_End_Hour__c,
    //                        Chat_Weekend_Start_Hour__c, Country__c, Issue_Type__c, Language__c, DeveloperName
    //                FROM Agent_HOOP__mdt
    //                WHERE Country__c = :country AND Language__c = :language
    //                LIMIT 1
    //        ];
    //        System.debug('current timestamp: '+Datetime.now());
    //        String day = Datetime.now().format('EEEE');
    //        Integer hour = Datetime.now().hourGmt();
    //        System.debug('day-> ' + day);
    //        System.debug('hour-> ' + hour);
    //
    //        if (!agentHOOPList.isEmpty()) {
    //            Integer weekdayStHourChat = Integer.valueOf(agentHOOPList[0].Chat_Weekday_Start_Hour__c);
    //            Integer weekdayEndHourChat = Integer.valueOf(agentHOOPList[0].Chat_Weekday_End_Hour__c);
    //            Integer weekendStHourChat = Integer.valueOf(agentHOOPList[0].Chat_Weekend_Start_Hour__c);
    //            Integer weekendEndHourChat = Integer.valueOf(agentHOOPList[0].Chat_Weekend_End_Hour__c);
    //            System.debug('weekdayStHourChat-> ' + weekdayStHourChat);
    //            System.debug('weekdayEndHourChat-> ' + weekdayEndHourChat);
    //            System.debug('weekendStHourChat-> ' + weekendStHourChat);
    //            System.debug('weekendEndHourChat-> ' + weekendEndHourChat);
    //            //for test class
    //            if (Test.isRunningTest()) {
    //                Date myDateWeekday = Date.newInstance(20, 06, 27);
    //                Time myTimeWeekday = Time.newInstance(3, 3, 3, 0);
    //                DateTime dtWeekday = DateTime.newInstance(myDateWeekday, myTimeWeekday);
    //                day = dtWeekday.format('EEEE');
    //                hour = dtWeekday.hourGmt();
    //            }
    //            //check if it's a weekend
    //            if (day == 'Saturday' || day == 'Sunday') {
    //                //for US & Canada reset end hour cause it goes to the next day
    //                if ((agentHOOPList[0].Country__c == 'United States' || agentHOOPList[0].Country__c == 'Canada') && (hour >= 0 && hour <= 5)) {
    //                    hour = 23;
    //                }
    //                if (hour >= weekendStHourChat && hour < weekendEndHourChat) {
    //                    return false;//false means button clickable
    //                } else {
    //                    return true;//true means button disabled/non clickable
    //                }
    //            } else if (day != 'Saturday' && day != 'Sunday') {
    //                //for test class
    //                if (Test.isRunningTest()) {
    //                    Date myDateWeekday = Date.newInstance(20, 06, 29);
    //                    Time myTimeWeekday = Time.newInstance(3, 3, 3, 0);
    //                    DateTime dtWeekday = DateTime.newInstance(myDateWeekday, myTimeWeekday);
    //                    day = dtWeekday.format('EEEE');
    //                    hour = dtWeekday.hourGmt();
    //                }
    //                //it's a weekday
    //                //for US & Canada reset end hour cause it goes to the next day
    //                if ((agentHOOPList[0].Country__c == 'United States' || agentHOOPList[0].Country__c == 'Canada') && (hour >= 0 && hour <= 5)) {
    //                    hour = 23;
    //                }
    //                if (hour >= weekdayStHourChat && hour < weekdayEndHourChat) {
    //                    return false;//within working hours on weekdays
    //                } else {
    //                    return true;//outside working hours on weekdays
    //                }
    //            } else {
    //                return false;//button clickable by default
    //            }
    //        }
    //        return false;
    //    }
}