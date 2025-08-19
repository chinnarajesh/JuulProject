public class SlackMsgCtrl {

    public Slack_Config__c sConfig {get;set;}
    public boolean isError {get;set;}
    public boolean isSuccess {get;set;}
    public String configMessage{get;set;}
    
    private static FINAL Map<String,String> ERRORMAP = new Map<String,String>{
        'channel_not_found' => 'An error occurred, please check your SLACK user and channel names',
        'invalid_payload' => 'Malformed request',
        'user_not_found' => 'User doesnot exists or invalid',
        'channel_is_archived' => 'Channel is archived',
        'action_prohibited' => 'There is a restriction in posting this kind of message. Please contact admin'
    } ;

    public SlackMsgCtrl(){
        isError = false;
        isSuccess = false;
        String name = getParameter('c');
        sConfig = [
            SELECT 
                Id,
                Message__c,
                Slack_Counter__c,
                Message_Editable__c,
                Channel__c,
                Webhook_url__c,
                Icon_Emoji__c,
                Icon_URL__c,
                Username__c
            FROM Slack_Config__c 
            WHERE Name =:name
        ];    
    }

    public Pagereference pageAction(){
        Pagereference p;
        String msg = getParameter('msg');
        String dbMessage = sConfig.Message__c;
        Id rid = getParameter('id');
        
        if(String.isBlank(msg) && sConfig.Message__c != null){
            sConfig.Message__c = TemplateResolver.compile(sConfig.Message__c,rid);
        }
        else{
             sConfig.Message__c = msg;
        }

        if(sConfig.Message_Editable__c){
            configMessage = sConfig.Message__c;
            sConfig.Message__c = '';
            p = null;
        }
        else{
            p = send(sConfig.Message__c);
        }
        if(String.isBlank(msg) && String.isBlank(dbMessage)){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Slack Config Message Found.');
            ApexPages.addMessage(errorMsg);
        }
        if(String.isNotBlank(msg) && String.isNotBlank(dbMessage)){
            ApexPages.Message warningMsg = new ApexPages.Message(ApexPages.Severity.WARNING,'Warning: Multiple Slack Config Message Found.');
            ApexPages.addMessage(warningMsg);
        }
        return p;
    }

    public pageReference send(){
        pageReference p;
        p = send(String.isBlank( sConfig.Message__c) ? configMessage :  sConfig.Message__c + '\n' + configMessage);
        return p;
    }

    public Pagereference send(String msg){
        
        slackAPI s = new SlackAPI(sConfig) ;
        string res = s.send(msg);
        if(ERRORMAP.containsKey(res)){
            isError = true;
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ERRORMAP.get(res));
            ApexPages.addMessage(errorMsg);           
        }
        else{
            try{
                Apexpages.currentPage().getParameters().put('Slack_Count__c',String.valueOf(sConfig.Slack_Counter__c)) ;
                updateParent(getParameter('id'));
            }
            catch(Exception ex){}
            isSuccess = true;      
        }
        return null; 
    }

    private static String getParameter(String p){
        return ApexPages.currentPage().getParameters().get(p);
    }
    
    private static void updateParent(Id rid){
        Boolean hasUpdate = false;
        Map<String,String> params = ApexPages.currentPage().getParameters();
        SObjectType stype = rid.getSobjectType();
        SObject r = stype.newSObject(rid);
        for(String f : params.keySet()){
            system.debug('#### key'+f) ;
            if(f.endsWithIgnoreCase('__c')){
                system.debug('#### key with __c'+f) ;
                system.debug('### count value '+params.get(f)) ;
                Object val = params.get(f);
                String v = params.get(f);
                if(String.isNotBlank(v) && v.isNumeric()){
                    val = (Decimal)Decimal.valueOf(v);
                }
                hasUpdate = true;
                r.put(f, (Decimal)Decimal.valueOf(v));
            }
        }
        if(hasUpdate)
            update r;
    }
}