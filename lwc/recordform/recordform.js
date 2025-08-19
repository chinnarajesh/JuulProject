import { LightningElement,api,track} from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_ID from '@salesforce/schema/Case.CaseNumber';
import SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
//import ENVIRONMENT_FIELD from '@salesforce/schema/Case.Environment__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import PRIORITY_FIELD from '@salesforce/schema/Case.Priority';
import ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
 export default class Recordform extends LightningElement {

@api recordId='500DM00000EZyCFYA1';
    objectApiName = CASE_OBJECT;
    fields = [CASE_ID,SUBJECT_FIELD,DESCRIPTION_FIELD,STATUS_FIELD,PRIORITY_FIELD,ORIGIN_FIELD];


 }