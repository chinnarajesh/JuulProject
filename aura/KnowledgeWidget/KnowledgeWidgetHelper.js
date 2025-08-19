({
    call: function(component, action, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            if (params) {
                action.setParams(params);
            }
            action.setCallback(this, function(a) {
                var err = a.getError();
                var result = a.getReturnValue();
                if (err && err.length > 0) reject(err);
                else resolve(result);
            });
            $A.enqueueAction(action, false);
        }));
        
    },
    insertCaseArticle: function(component, event, helper) {
        var spinner = component.find("knowledgeSpinner");
        $A.util.removeClass(spinner, "slds-hide");
        return helper.call(component, component.get('c.insertCaseArticle'), {
            articleId : event.getSource().get("v.value"),
            caseId: component.get('v.case').Id
        }).then(function (result) {
            $A.util.addClass(spinner, "slds-hide");            
            var caseArticleMap = component.get('v.caseArticleMap');
            caseArticleMap[event.getSource().get("v.value")] = result;
            component.set('v.caseArticleMap', caseArticleMap);
            helper.parseCaseArticles(component, helper);
            return caseArticleMap;
        })
    },
    deleteCaseArticle : function (component, event, helper) {
        var spinner = component.find("knowledgeSpinner");
        $A.util.removeClass(spinner, "slds-hide");
        var art = component.get('v.articles')[parseInt(event.getSource().get("v.value"))];
        return helper.call(component, component.get('c.deleteCaseArticle'), {
            caseArticleId : art.attributes.caseArticle.Id
        }).then(function (result) {
            $A.util.addClass(spinner, "slds-hide");
            var caseArticleMap = component.get('v.caseArticleMap');
            delete caseArticleMap[art.KnowledgeArticleId];
            component.set('v.caseArticleMap', caseArticleMap);
            helper.parseCaseArticles(component, helper);
            return caseArticleMap;
        })
    },
    getArticles: function(component, helper) {
        
        return helper.call(component, component.get('c.getArticles')).then(function(res) {
            var arrIds = [];
            for (var i = 0; i < res.length; i++) {
                if (res[i].DataCategorySelections && res[i].DataCategorySelections.length > 0) {
                    res[i].DataCategory = res[i].DataCategorySelections[0].DataCategoryName;
                }
                arrIds.push(res[i].KnowledgeArticleId);
            }
            
            return helper.getAllCaseArticle(component, helper, arrIds, component.get('v.case').Id).then(function(caseArticleMap) {
                for (var i = 0; i < res.length; i++) {
                    res[i].attributes = res[i].attributes || {};
                    res[i].ArticleNumber = res[i].ArticleNumber || '';
                    res[i].Summary = res[i].Summary || '';
                    res[i].Title = res[i].Title || '';
                    res[i].UrlName = res[i].UrlName || '';
                    res[i].KB_Description__c = res[i].KB_Description__c || '';
                    if (caseArticleMap[res[i].KnowledgeArticleId]) {
                        res[i].attributes.added = true;
                        res[i].attributes.caseArticle = caseArticleMap[res[i].KnowledgeArticleId];
                    }
                }
                return {
                    caseArticleMap: caseArticleMap,
                    articles: res,
                    suggestions: helper.filterSuggestions(component, res)
                }
            });
        })
    },
    getAllCaseArticle: function(component, helper, articleIds, caseId) {
        return helper.call(component, component.get('c.getAllCaseArticle'), {
            articleIds: articleIds,
            caseId: caseId
        }).then(function(result) {
            var caseArticleMap = {};
            for (var i = 0; i < result.length; i++) {
                caseArticleMap[result[i].KnowledgeArticleId] = result[i];
            }
            return caseArticleMap;
        });
    },
    getCategories: function(component, helper) {
        return helper.call(component, component.get('c.getDataCategories'));
    },
    getCase: function(component, helper) {
        return helper.call(component, component.get('c.getCase'),{caseId:component.get('v.recordId')});
    },
    getArticleType: function(component, helper) {
        var arr = [];
        return helper.call(component, component.get('c.getArticleType')).then(function(res) {
            for (var key in res) {
                if (res.hasOwnProperty(key)) {
                    var m = {
                        name: key,
                        attribues: {
                            isChecked: false
                        },
                        val: res[key]
                    }
                    arr.push(m);
                }
            }
            return arr;
        })
    },
    parseCategories: function(r) {
        r = r || [];
        var arr = [];
        var m = {};
        for (var i = 0; i < r.length; i++) {
            for (var j = 0; j < r[i].topCategories.length; j++) {
                parseChildCategories(m, r[i].topCategories[j].childCategories || []);
            }
        }
        for (var key in m) {
            if (m.hasOwnProperty(key)) {
                var d = {
                    name: key,
                    attribues: {
                        isChecked: false
                    },
                    val: m[key]
                }
                arr.push(d);
            }
        }
        return arr;
        
        function parseChildCategories(m, r) {
            for (var i = 0; i < r.length; i++) {
                if (r[i].childCategories && r[i].childCategories.length == 0) {
                    m[r[i].label] = r[i].name;
                } else {
                    parseChildCategories(m, r[i].childCategories);
                }
            }
            
            return m;
        }
    },
    parseCaseArticles : function (component, helper) {
        var res = component.get('v.articles');
        var caseArticleMap = component.get('v.caseArticleMap');
        for (var i = 0; i < res.length; i++) {
            res[i].attributes = res[i].attributes || {};
            if (caseArticleMap[res[i].KnowledgeArticleId]) {
                res[i].attributes.added = true;
                res[i].attributes.caseArticle = caseArticleMap[res[i].KnowledgeArticleId];
            }
            else {
                res[i].attributes.added = false;
                delete res[i].attributes.caseArticle;
            }
        }
        
        component.set('v.articles', res);
        component.set('v.suggestions', helper.filterSuggestions(component, res));
    },
    filterSuggestions : function(component, arr) {
        var options = {
            shouldSort: true,
            threshold: 0.6,
            location: 0,
            distance: 100,
            maxPatternLength: 32,
            minMatchCharLength: 1,
            keys: [
                "ArticleNumber",
                "Summary",
                "Title",
                "UrlName",
                "KB_Description__c"
            ]
        };
        var results = [];
        try {
            var darr = new Fuse(arr, options).search(component.get('v.case').Description || '');
            var sarr = new Fuse(arr, options).search(component.get('v.case').Subject || '');
            var all = darr.concat(sarr);
            
            for (var i = 0; i < all.length; i++) {
                if (results.indexOf(all[i]) == -1) {
                    results.push(all[i]);
                }
            }
        }
        catch(ex){
           console.error('error-->', ex); 
        }
        return results;
    },
    handleFilter : function (component, helper) {
        var articleTypes = $('#article-types').select2('val');
        var categories = $('#categories').select2('val');
        var articles = component.get('v.articles');
        var search = $('#search').val();
        $('.data-rows').each(function () {
            var $e = $(this);
            if (
                (!search || $e.text().toLowerCase().indexOf(search.toLowerCase()) > -1)
                && (articleTypes.length == 0 || articleTypes.indexOf($e.attr('data-article-type')) > -1)
                && ( categories.length == 0 || categories.indexOf($e.attr('data-category')) > -1 )
            ) {
                $e.show();
            }
            else {
                $e.hide();
            }
        })
        
    }
    
})