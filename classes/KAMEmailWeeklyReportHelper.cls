/****************************************************************************************************/
/* VERSION     AUTHOR                  DATE                                                         */
/*     1.0     Pushkar Gangwar         06-18-2020                                                   */
/* Class Name: KAMEmailWeeklyReportHelper                                                           */
/* Description: Helper class for KAMEmailWeeklyAlertReportBatch to process execute method sending email to account team
/****************************************************************************************************/

global class KAMEmailWeeklyReportHelper {
    
    global static void sendAlertReportEmail(Set<Id> accountIds){
        //fetching user emails from account team to send the report link 
        List<User> userList = new List<User>();
        Set<Id> userIdList = new Set<Id>();    
        Map<id, Account> acctsToUpdate = new Map<id, Account>([Select a.Id, OwnerId, (Select Id, AccountId,UserId From AccountTeamMembers WHERE 
                                                                             TeamMemberRole = 'KAPM' OR TeamMemberRole = 'KAM\'s Reporting Manager (Director/Sr Director)')
                                                               From Account a Where a.Id in :accountIds]);  
        //Collecting userId of Account Team Members(KAM Reporting Manage director) to get emails address to send email
        for(List<AccountTeamMember> memebrList:  acctsToUpdate.values().AccountTeamMembers){    
            for(AccountTeamMember member : memebrList){
                userIdList.add(member.UserId);  
            }
        }
        //Collecting userId of owner to get emails address to send email
        for(Account ac: acctsToUpdate.values()){
            userIdList.add(ac.OwnerId);
        }
        
        if(userIdList.size() > 0){
            userList = [SELECT ID, Email FROM User WHERE ID=:userIdList];
            List<String>  recipients = new List<String>();
            for(User userObj : userList){
                recipients.add(userObj.email);
            }
            System.debug('--recipients : '+ recipients );
            if(recipients.size() > 0){
                KAMEmailWeeklyReportHelper.sendEmailTo(recipients); 
            }
        }   
    } 
    
    //Send report link in Email to Account Team memebrs
    global static void sendEmailTo(List<String>  recipients){
        List<Report> Weeklyreport = new List<Report>();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Weeklyreport = [SELECT Id,DeveloperName, Name FROM Report where 
                   DeveloperName = 'This_Week_Created_Alert_dym' LIMIT 1];
        if(Weeklyreport.size() > 0){
            //getting report URL to send in email
            String reportURL = baseUrl+ '/'+Weeklyreport[0].Id; 
            //Sending email to recipients
            message.setSubject('Report: '+ Weeklyreport[0].Name);
            message.setHtmlBody('<html> Hello, <br/><br/>Please find the alert report for Accounts added in hierarchy during this week. <br/> <a href="'+reportURL+'">'+Weeklyreport[0].Name+'</a></html>');
            message.setToAddresses(recipients);     
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message } ); 
        }        
    }
    
}