({
    doInit: function(component, event, helper) {
        
        $('#article-types').select2({
            placeholder: 'Article Types',
            multiple: true
        }).change(function (e) {
            helper.handleFilter(component, helper);
            
        })
        $('#categories').select2({
            placeholder: 'Internal KB',
            multiple: true
        }).change(function (e) {
            helper.handleFilter(component, helper);
        })
        
        $('#search').keyup(function (e) {
            helper.handleFilter(component, helper);
        })
        
        helper.getCase(component, helper).then(function(res){
            res.Subject = res.Subject || '';
            res.Description = res.Description || '';
            component.set('v.case',res);
            return Promise.all([
                helper.getCategories(component, helper),
                helper.getArticleType(component, helper),
                helper.getArticles(component, helper)
            ])
        }).then(function(res) {
            var spinner = component.find("knowledgeSpinner");
            $A.util.addClass(spinner, "slds-hide");
            var arr = helper.parseCategories(res[0]);
            
            component.set('v.categories', arr);
            component.set('v.articleTypes', res[1]);
            component.set('v.articles', res[2].articles);
            component.set('v.suggestions', res[2].suggestions);
            component.set('v.caseArticleMap', res[2].caseArticleMap);
            
        })
    },
    
    attach : function (component, event, helper) {
        return helper.insertCaseArticle(component, event, helper);
    },
    detach : function (component, event, helper) {
        return helper.deleteCaseArticle(component, event, helper);
    },
    openArticle : function (component, event, helper) {
        var i = event.target.getAttribute('data-value');
        var d = component.get('v.articles')[i];
        d.attributes = d.attributes || {};
        d.attributes.idx = i;
        component.set('v.article',d);
        component.set('v.selectedTab','all');
        component.set('v.isDetail',true);  
    },
    openSuggestion : function (component, event, helper) {
        var i = event.target.getAttribute('data-value');
        var d = component.get('v.suggestions')[i];
        d.attributes = d.attributes || {};
        d.attributes.idx = i;
        component.set('v.article',d);
        component.set('v.selectedTab','sugested');
        component.set('v.isDetail',true);  
    },
    backToSearch : function (component, event, helper) {
        component.set('v.isDetail',false);
    }
})