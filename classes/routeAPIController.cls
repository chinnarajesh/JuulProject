/** 
* File Name: TD_JUUL_REST_API.cls
* Description: Webservice for Transactional IVR 
* Copyright : Talkdesk, Inc. Copyright (c) 2017
* Author : Phillip Zeelig
* Date: 10182017
**/ 

//https://talkdesk-demo-developer-edition.na50.force.com/services/apexrest/routeAPIsJuul
@RestResource(urlMapping='/routeAPIs/*')
global without sharing class routeAPIController {
    @HttpPost
    global static void getAccount(String source_address){

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/xml');
        XmlStreamWriter w = new XmlStreamWriter();

        //Always the same, not case specific
        w.writeStartDocument('UTF-8', '1.0');
        w.writeStartElement(null, 'Response', null);
        w.writeStartElement(null, 'Context', null);

        //defined recordType
        Contact c;
        ID personType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String accID;
        String type;
        String accURL;
        String source_phone = source_address.right(10);
        String instanceID = System.Url.getSalesforceBaseURL().toExternalForm();
        instanceID = instanceID.substringBefore('.force').substringAfter('.');

        try{
            Map <string,Contact> conMap = new Map <string,Contact>();
            List<contact> contactIDs  = [SELECT id, AccountID, MobilePhone, Phone, HomePhone, OtherPhone FROM Contact];
            if(contactIDs.size() > 0){
                for(Contact contact: contactIDs){
                     if (contact.Phone!=NULL){
                         conMap.put(contact.phone.replaceAll('\\D+','').right(10),contact);  
                     }
                     if (contact.HomePhone!=NULL){
                        conMap.put(contact.HomePhone.replaceAll('\\D+','').right(10),contact);  
                     }
                     if (contact.OtherPhone!=NULL){
                        conMap.put(contact.OtherPhone.replaceAll('\\D+','').right(10),contact);  
                     }
                     if (contact.MobilePhone!=NULL){
                        conMap.put(contact.MobilePhone.replaceAll('\\D+','').right(10),contact);  
                    }
                }
            }
            if(conMap.size()>0){
                c = conMap.get(source_phone);
                if(c!=NULL){
                    accID = conMap.get(source_phone).AccountID;
                    List<account> a = [SELECT id, RecordTypeID FROM Account WHERE id =: accID];
                    if(a.size()>0 && a[0].RecordTypeID == personType){
                        type = 'Person';
                    }
                    else{
                        type = 'Business';
                    }
                }
            }
            //<?xml version="1.0" encoding="UTF-8"?><Response><Context output="business_account_true"><Integration id="salesforce"><Field name="TicketId">https://na50.salesforce.com/0016A000007NOAiQAO</Field></Integration></Context></Response>
            if(accID != NULL && type == 'Business'){
            accURL = 'https://' + instanceID + '.salesforce.com/' + accID;
            w.writeAttribute(null, null, 'output', 'business_account_true');
            w.writeStartElement(null, 'Fields', null);
            w.writeStartElement(null, 'Field', null);
            w.writeAttribute(null, null, 'name', 'ticketid');
            w.writeCharacters(accURL);
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndDocument();
            String xmlOutput = w.getXmlString();
            w.close();
            res.responseBody = Blob.valueOf(xmlOutput);
            return;
          }
          if(accID != NULL && type == 'Person'){
            accURL = 'https://' + instanceID + '.salesforce.com/' + accID;
            w.writeAttribute(null, null, 'output', 'person_account_true');
            w.writeStartElement(null, 'Fields', null);
            w.writeStartElement(null, 'Field', null);
            w.writeAttribute(null, null, 'name', 'ticketid');
            w.writeCharacters(accURL);
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndDocument();
            String xmlOutput = w.getXmlString();
            w.close();
            res.responseBody = Blob.valueOf(xmlOutput);
            return;
          }
          if(accID == NULL){
            accURL = 'https://' + instanceID + '.salesforce.com/' + accID;
            w.writeAttribute(null, null, 'output', 'no_account_found');
            w.writeStartElement(null, 'Fields', null);
            w.writeStartElement(null, 'Field', null);
            w.writeAttribute(null, null, 'name', 'ticketid');
            w.writeCharacters(accURL);
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndDocument();
            String xmlOutput = w.getXmlString();
            w.close();
            res.responseBody = Blob.valueOf(xmlOutput);
            return;
          }
        }
            Catch(QueryException e){
              w.writeAttribute(null, null, 'output', 'error');
              w.writeStartElement(null, 'Fields', null);
              w.writeStartElement(null, 'Field', null);
              w.writeAttribute(null, null, 'name', 'ticketid');
              w.writeCharacters(accURL);
              w.writeEndElement();
              w.writeEndElement();
              w.writeEndElement();
              w.writeEndDocument();
              String xmlOutput = w.getXmlString();
              w.close();
              res.responseBody = Blob.valueOf(xmlOutput);
              return;
        }
    }
}