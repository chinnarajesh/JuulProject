/*******************************************************************************************
* @Name         AgentOperationService
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         07/17/2019
* @Group        Customer Service
* @Description  This is a REST Service which returns agent specific availability data
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         07/17/2019          Initial Creation
*******************************************************************************************/
@RestResource(UrlMapping='/customerops/agentoperation/*')
global class AgentOperationService {

    /**************************************************************************************
     * @Description This method returns agent availability based on time and locale
     * @Param   JSON payload of timestamp and locale
     * @Return  Boolean for available/not available
     **************************************************************************************/
    @HttpPost
    global static Boolean getAvailability() {
        RestRequest req = RestContext.request; //the RestRequest for the Apex REST method
        Blob requestBody = req.requestBody;
        String jsonBody = requestBody.toString(); //the body of the request
        ZendeskSiteUserWrapper wrapper = new ZendeskSiteUserWrapper();
        wrapper = ZendeskSiteUserWrapper.parse(jsonBody);
        System.debug('parsed JSON--> ' + wrapper);
        if (wrapper.timestamp != null && String.isNotBlank(wrapper.locale)) {
            //get the maps which hold the agents' hours of operation per locale
            Map <String, String> mapOfWeekdaySt = CSCountryConfigUtil.getLocaleToWeekdayStHr();
            Map <String, String> mapOfWeekdayEnd = CSCountryConfigUtil.getLocaleToWeekdayEndHr();
            Map <String, String> mapOfWeekendSt = CSCountryConfigUtil.getLocaleToWeekendStHr();
            Map <String, String> mapOfWeekendEnd = CSCountryConfigUtil.getLocaleToWeekendEndHr();

            //calculate the day and hour from the timestamp
            String day = wrapper.timestamp.format('EEEE');
            Integer hour = wrapper.timestamp.hour();
            System.debug('day-> ' + day);
            System.debug('hour-> ' + hour);
            Integer weekdayStHour, weekdayEndHour, weekendStHour, weekendEndHour;

            if (mapOfWeekdaySt.get(wrapper.locale) != null && mapOfWeekdayEnd.get(wrapper.locale) != null &&
                    mapOfWeekendSt.get(wrapper.locale) != null && mapOfWeekendEnd.get(wrapper.locale) != null) {
                weekdayStHour = Integer.valueOf(mapOfWeekdaySt.get(wrapper.locale));
                weekdayEndHour = Integer.valueOf(mapOfWeekdayEnd.get(wrapper.locale));
                weekendStHour = Integer.valueOf(mapOfWeekendSt.get(wrapper.locale));
                weekendEndHour = Integer.valueOf(mapOfWeekendEnd.get(wrapper.locale));
            }
            System.debug('weekdayStHour-> ' + weekdayStHour);
            System.debug('weekdayEndHour-> ' + weekdayEndHour);
            System.debug('weekendStHour-> ' + weekendStHour);
            System.debug('weekendEndHour-> ' + weekendEndHour);
            //check if it's a weekend
            if (day == 'Saturday' || day == 'Sunday') {
                //special operation hours for israel on sundays
                if (day == 'Saturday' && wrapper.locale == 'he') {
                    return false;
                } else if (day == 'Sunday' && wrapper.locale == 'he') {
                    if (hour >= weekendStHour && hour < weekendEndHour) {
                        return true;
                    } else {
                        return false;
                    }
                }
                if (hour >= weekendStHour && hour < weekendEndHour) {
                    return true;
                } else {
                    return false;
                }
            } else {
                //special operation hours for israel on fridays
                if (day == 'Friday' && wrapper.locale == 'he') {
                    return false;
                } else if (day != 'Friday' && wrapper.locale == 'he') {
                    if (hour >= weekdayStHour && hour < weekdayEndHour) {
                        return true;
                    } else {
                        return false;
                    }
                }
                //it's a weekday
                if (hour >= weekdayStHour && hour < weekdayEndHour) {
                    return true;
                } else {
                    return false;
                }
            }
        }
        return null;
    }
}