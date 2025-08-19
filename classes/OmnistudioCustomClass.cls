global with sharing class OmnistudioCustomClass implements callable{
    
    /*
    inputs - arguments - List<Object> of passed in arguments
    output - result - The result of the Function being called. Supports single Object values, List<Object> or Map<String, Object>
    */    
    public Object call(String action, Map<String, Object> args){
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        
        //if(action == 'customFunction'){
            //To return the result to the dataraptor. the key should always be named as `result`.
            //output.put('result',convertToObject(input,output,options));
        //}

        return invokeMethod(action, input, output, options);
    }
    private boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
       Boolean result=true;
        try{
            if(methodName.equalsIgnoreCase('getAccount')){
                getAccount(inputMap,outMap,options);
            }
            else{
                outMap.put('result', '');
            }
        } catch(Exception e){
            return false;
        }
        return result;
    }
    
    public void getAccount(Map<String,object>input,Map<String,object>output,Map<String,object>options){
        List<Account> acc = [Select Id, Name FROM Account Limit 5]; 
        output.put('result', acc);
    }
    
}