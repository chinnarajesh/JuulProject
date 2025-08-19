/*******************************************************************************************
* @Name         DataUtility
* @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
* @Date         04/22/2019
* @Group        Customer Service
* @Description  This is a utility class which has methods to return formatted/valid data
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         04/22/2019          Initial Creation
*******************************************************************************************/
public with sharing class DataUtility {
    /**************************************************************************************
     * @Description This method validates the incoming email
     * @Param   email address
     * @Return  true if email is valid else false
     **************************************************************************************/
    public static Boolean checkEmail(String emailString) {
        String inputString = emailString;
        String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        Pattern myPattern = Pattern.compile(emailRegex);
        Matcher myMatcher = myPattern.matcher(inputString);
        if (!myMatcher.matches()) {
            return false;
        } else {
            return true;
        }
    }
    /**************************************************************************************
     * @Description This method returns elapsed seconds between 2 time instances
     * @Param   start and end time
     * @Return  number of seconds elapsed between them
     **************************************************************************************/
//    public static Integer getElapsedSeconds(Time startTime, Time endTime) {
//        // Save CPU.
//        if (startTime == null || endTime == null || startTime == endTime) {
//            return 0;
//        } else {
//            Integer elapsedHours = endTime.hour() - startTime.hour();
//            Integer elapsedMinutes = endTime.minute() - startTime.minute();
//            Integer elapsedSeconds = endTime.second() - startTime.second();
//            Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();
//
//            Integer total = ((elapsedHours * 60 * 60) +
//                    (elapsedMinutes * 60) +
//                    (elapsedMiliseconds / 1000) +
//                    elapsedSeconds);
//
//            // Don't return negative values.
//            if (total < 0) {
//                return 0;
//            } else {
//                return total;
//            }
//        }
//    }
}