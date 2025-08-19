public class SlackAPI {
    private Slack_Config__c config;
    
    public SlackAPI(Slack_Config__c config){
        this.config = config;
    }
    
    public SlackAPI(String configName){
        this.config = [
            SELECT 
                Id,
                Name,
                Username__c,
                Webhook_url__c,
                Icon_Emoji__c,
                Icon_URL__c,
                Channel__c 
            FROM 
                Slack_Config__c 
            WHERE 
                Name =:configName LIMIT 1
        ];
    }
    
    public string send(String msg){
        return doPOST(
                    config.WebHook_URL__c,
                    JSON.serialize(
                        new Map<String,String>{
                            'text' => msg,
                            'username' => config.Username__c,
                            'icon_emoji' => config.Icon_Emoji__c,
                            'icon_url' => config.Icon_URL__c,
                            'channel' => config.Channel__c
                        }
                    )
                );
    }
    
    private static string doPOST(String endpoint,String payload){
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setBody(payload);
        Http h = new Http();
        Httpresponse  res = h.send(req);
        return res.getBody();
    }
}