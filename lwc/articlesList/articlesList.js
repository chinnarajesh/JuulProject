/*******************************************************************************************
 * @Name         ArticlesList
 * @Author       Sahil Chaudhry <sahil.chaudhry@juul.com>
 * @Date         12/05/2019
 * @Group        Customer Service
 * @Description  This is a LWC which displays knowledge articles based on topic and language
 *******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*   1.0              Sahil         12/10/2019          Initial Creation
*******************************************************************************************/
import {LightningElement, wire, track, api} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import getArticleURL from '@salesforce/apex/KnowledgeController.getArticleURL';
import findArticleByDataCategory from '@salesforce/apex/KnowledgeController.findArticleByDataCategory';
import {registerListener} from 'c/pubsub';
import {NavigationMixin} from 'lightning/navigation';
import mostViewedLabel from '@salesforce/label/c.Most_Viewed_Articles';
import {unregisterAllListeners} from 'c/pubsub';

export default class ArticlesList extends NavigationMixin(LightningElement) {
    @api articles;
    @wire(CurrentPageReference) pageRef;
    label = {
        mostViewedLabel
    };

    connectedCallback() {
        registerListener('getArticlesByDCat', this.handleArticleByDCat, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleArticleByDCat(payload) {
        console.log(payload);
        findArticleByDataCategory(payload)
            .then(result => {
                console.log(result);
                this.articles = result ? [...result] : [];
            })
            .catch((error) => {
                this.message = 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message;
                console.log(this.message);
            });
    }

    handleArticleSelect(event) {
        getArticleURL({
            articleId: event.target.article.Id
        })
            .then(result => {
                console.log(result);
                window.open(result);
            })
            .catch((error) => {
                this.message = 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message;
                console.log(this.message);
            });
    }
}