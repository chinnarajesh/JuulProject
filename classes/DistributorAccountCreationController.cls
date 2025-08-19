//DEPRECATED
@RestResource(urlMapping='/DistributorAccountCreation')
global without sharing class DistributorAccountCreationController {
    @HttpGet
    global static String doGet() {
        return 'success';
    }

    @HttpPost
    global static String doPost(){
        return 'success';
    }
}