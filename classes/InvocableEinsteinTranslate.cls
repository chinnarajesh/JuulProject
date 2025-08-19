global class InvocableEinsteinTranslate {
    @InvocableMethod(label='Einstein Translate')
// Loop through variables to be used in method
   global static List<outputVariables> loopVariables(List<inputVariables> requests) {   
        List<outputVariables> results = new List<outputVariables>(); 
            for (inputVariables request : requests){
                results.add(translator(request));
            }
        return results;                              
        }
    
// Translate method
    global static outputVariables translator(inputVariables request){
        outputVariables returndetails = new outputVariables();
        returndetails.translatedText = AITools.MLServices.translate(request.textToTranslate, request.targetLang, request.sourceLang);
        return returndetails;
    }
    
// Declare input variables to be used with Flow and invocable method
    global class inputVariables{              
        @InvocableVariable(label='Text To Translate' required='true')
        global String textToTranslate;
        
        @InvocableVariable(label='Source Language' required='true')
        global String sourceLang;
        
        @InvocableVariable(label='Target Language' required='true')
        global String targetLang;
        
 }
    
// Declare output variables to be used with Flow and invocable method
    global class outputVariables{
        @InvocableVariable(label='Translated Text')
        global String translatedText;       
    }
}