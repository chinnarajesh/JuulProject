import { LightningElement } from 'lwc';
import TwitterImageForFooter from '@salesforce/resourceUrl/TwitterImageForFooter';
import LinkedInImageForFooter from '@salesforce/resourceUrl/LinkedInImageForFooter';

export default class JUULCommunityFooter extends LightningElement {
    twitterImage = TwitterImageForFooter;
    linkedInImage = LinkedInImageForFooter;
}