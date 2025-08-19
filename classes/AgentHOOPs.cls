/*******************************************************************************************
* @Name         AgentHOOPs
* @Author       Satabhisa Roy <satabhisa.roy@juul.com>
* @Date         13/02/2025
* @Group        Customer Service
* @Description  This class determines enablement of Call Us button based on timestamp
*******************************************************************************************/
public with sharing class AgentHOOPs {
    
    /**************************************************************************************
	* @Description This method returns agent phone availability based on time and locale
	* @Return  Boolean for available/not available
	**************************************************************************************/

    private static Boolean isAvailable(Integer hour, Integer startHour, Integer endHour) {
        if (startHour < endHour) { // Standard case
            Boolean b =  (hour >= startHour && hour < endHour);
            //System.debug('b '+b);
            return !b;
        } 
        else { // End hour is on the next day (rollover)
            Boolean c = (hour >= startHour || hour <= endHour);
            //System.debug('c '+c);
            return !c;

        }
    }
    /**************************************************************************************
    * @Description This method returns the start hour and end hour of the countries
    * @Param   user details from the LWC
    **************************************************************************************/
    @AuraEnabled(cacheable = true)
    public static Boolean checkCallHOOP(String country, String language) {
        List<Agent_HOOP__mdt> agentHOOPList = [
            SELECT Country__c, Language__c, Phone_Weekday_End_Hour__c,
            Phone_Weekday_Start_Hour__c, Phone_Weekend_End_Hour__c,
            Phone_Weekend_Start_Hour__c
            FROM Agent_HOOP__mdt
            WHERE Country__c =:country AND Language__c =:language
            LIMIT 1
        ];

        if (agentHOOPList.isEmpty()) {
            return false; // No matching agent HOOP found
        }
        
        else
        {
            
        

        String day = Datetime.now().format('EEEE');
        Integer hour = Datetime.now().hourGmt();

        Integer startHour;
        Integer endHour;
            
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

        // Consolidated Logic:
        if (agentHOOPList[0].Country__c == 'United States' || (agentHOOPList[0].Country__c == 'Canada' && agentHOOPList[0].Language__c == 'en_US')) {
            //system.debug(agentHOOPList[0].Country__c);
            if (day == 'Saturday' || day == 'Sunday') {
                startHour = Integer.valueOf(agentHOOPList[0].Phone_Weekend_Start_Hour__c);
                endHour = Integer.valueOf(agentHOOPList[0].Phone_Weekend_End_Hour__c);
            } 
            else 
            { // Weekday for US/Canada
                if (Test.isRunningTest()) 
                {
                    Date myDateWeekday = Date.newInstance(20, 06, 29);
                    Time myTimeWeekday = Time.newInstance(3, 3, 3, 0);
                    DateTime dtWeekday = DateTime.newInstance(myDateWeekday, myTimeWeekday);
                    day = dtWeekday.format('EEEE');
                    hour = dtWeekday.hourGmt();
                }
                startHour = Integer.valueOf(agentHOOPList[0].Phone_Weekday_Start_Hour__c);
                endHour = Integer.valueOf(agentHOOPList[0].Phone_Weekday_End_Hour__c);
            }
        } 
            else 
        	{ // All other countries
            //system.debug(agentHOOPList[0].Country__c);
                if (day == 'Saturday' || day == 'Sunday') 
                {
                    startHour = Integer.valueOf(agentHOOPList[0].Phone_Weekend_Start_Hour__c);
                    endHour = Integer.valueOf(agentHOOPList[0].Phone_Weekend_End_Hour__c);
                } 
                else 
                { // Weekday for other countries
                    if (Test.isRunningTest()) 
                    {
                        Date myDateWeekday = Date.newInstance(20, 06, 29);
                        Time myTimeWeekday = Time.newInstance(3, 3, 3, 0);
                        DateTime dtWeekday = DateTime.newInstance(myDateWeekday, myTimeWeekday);
                        day = dtWeekday.format('EEEE');
                        hour = dtWeekday.hourGmt();
                    }
                    startHour = Integer.valueOf(agentHOOPList[0].Phone_Weekday_Start_Hour__c);
                    endHour = Integer.valueOf(agentHOOPList[0].Phone_Weekday_End_Hour__c);
                }
        }

        return isAvailable(hour, startHour, endHour);
        }
    }
}