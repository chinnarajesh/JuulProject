import { LightningElement,api,track} from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import savedFilterHeader from '@salesforce/label/c.PB_Saved_Filter_Section';
import savedFilterSubHeader from '@salesforce/label/c.PB_Saved_Filter_Sub_Section';
import formHeader from '@salesforce/label/c.PB_Form_Section';
import formSubHeader from '@salesforce/label/c.PB_Form_Sub_Section_One';
import formSubHeaderQuestion from '@salesforce/label/c.PB_Form_Sub_Section_Two';
import filterSection from '@salesforce/label/c.PB_Filter_Section';
import getKAMTabNames from '@salesforce/apex/FilterPhotoLibrary.getKAMTabNames';
import getFieldTabNames from '@salesforce/apex/FilterPhotoLibrary.getFieldTabNames';
import getSavedFilterNames from '@salesforce/apex/FilterPhotoLibrary.getSavedFilterNames';
import getSavedFilterNamesRefresh from '@salesforce/apex/FilterPhotoLibrary.getSavedFilterNamesRefresh';
import getAvailbleKAMFilters from '@salesforce/apex/FilterPhotoLibrary.getAvailbleKAMFilters';
import getAvailbleFieldFilters from '@salesforce/apex/FilterPhotoLibrary.getAvailbleFieldFilters';
import saveNewFilter from '@salesforce/apex/FilterPhotoLibrary.saveNewFilter';
import isFilterAlreadyAvailable from '@salesforce/apex/FilterPhotoLibrary.isFilterAlreadyAvailable';
import fetchPhotosForAppliedFilter from '@salesforce/apex/FilterPhotoLibrary.fetchPhotosForAppliedFilter';
import getFormValues from '@salesforce/apex/FilterPhotoLibrary.getFormValues';
import getQuestionValues from '@salesforce/apex/FilterPhotoLibrary.getQuestionValues';
import getSelectedSavedJsonValuesFilter from '@salesforce/apex/FilterPhotoLibrary.getSelectedSavedJsonValuesFilter';
import getSelectedSavedJsonValuesQuestion from '@salesforce/apex/FilterPhotoLibrary.getSelectedSavedJsonValuesQuestion';
import getSelectedSavedJsonValuesFromDate from '@salesforce/apex/FilterPhotoLibrary.getSelectedSavedJsonValuesFromDate';
import getSelectedSavedJsonValuesToDate from '@salesforce/apex/FilterPhotoLibrary.getSelectedSavedJsonValuesToDate';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import photoimage from '@salesforce/resourceUrl/photoimage';
import photochatter from '@salesforce/resourceUrl/PhotoChatter';
import jQuery3 from '@salesforce/resourceUrl/jQuery3';
import getImage from '@salesforce/apex/FilterPhotoLibrary.getImage';
// import JSZIP from '@salesforce/resourceUrl/jszip'; 
import photogallery from '@salesforce/resourceUrl/photogallery';
import lightgallery from '@salesforce/resourceUrl/lightgallery';
import jquerymodal from '@salesforce/resourceUrl/jquerymodal';
import photoGalleryHeader from '@salesforce/label/c.PB_Photo_Gallery';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class PhotoLibrary extends NavigationMixin(LightningElement) {
   
@track checkIcon_button_tag_form="action:new";
@track checkIcon_button_tag_filter="action:new";
@track title_checkbox=" Click to include Survey Section for Search";
@track title_checkbox_1="Click to include All Filter Section for Search";
@track isDVisible=false;
  customLabel = {
      savedFilterHeader,
      savedFilterSubHeader,
      formHeader,
      formSubHeader,
      formSubHeaderQuestion,
      filterSection

  };
  img_icon=  photochatter;
@track showDataLoading = false;
@track clearAllFilterNotification = false;
@track clearAllFormNotification = false;
@api photos = [];
@track localphotos = [];
@track leng = false;
@track teamon = false;
@track retailTheaterTab = false;
photoval = [];
chartjsInitialized = false;
@track isPhotoAvailable = false;
@track isPhotoNotAvailable = false;
@track photoSpinner = false;
@track retailTabBl = false;
@track retailClear = false;

@track loadingEditFilter = false;

label = {
    photoGalleryHeader
};
  @api isfilterpersona;
  @track lstKAMTabs;
  @track lstPhotoTabs;
  @track error;
  @track currentKAMTabContent = [];
  @track currentFilterTabContent = [];
  @track searchKAMFilter = '';
  @track searchFieldFilter = '';
  @track newfiltername = '';
  @track items = [];
  @track formitems = [];
  @track alluserids = [];
  @track exactitems = [];
  @track enteredallvalues = [];
  @track mylstKAMTabs = [];
  @track mylstFieldTabs = [];
  @track activetab = '';
  @track mytemp = [];
  @track mykamtemp = []
  @track mytabset = [];
  @track mykamtabset = []
  @track _initializationCompleted = false;
  @track mySelectedFormIds = [];
  @track mySelectedQuestionIds = [];
  @track myFormSubmittedDate = '';
  @track myFormSubmittedDateTo = '';
  @track myQuestions = [];
  fields = ["Name"];
  @track myselo = [];
  @track allimages = [];
  @track mysavedfiltertemp = [];
  @track mysavedfilterquestiontemp = [];
  mysavedFromDate = '';
  mysavedToDate = '';
  @track isShowModal = false;
  @track totallenrecord = 0;
  beforeTempQuestionId = [];
  beforeTempubmittedDate = '';
  beforeTempubmittedDateTo = '';
  beforeTempFilterValues = [];
  checkOrUncheckForm = false;
  checkOrUncheckFilter = false;
  formApplyButton = false;
  filterApplyButton = false;

  isMultiSelectFilter = false;
  isMultiSelectForm = true;
  @track selectedSavedFilterName = '';

  @track selectedEditSavedFilterName = '';
  @track accountURLID;
  pageNum = 1;
  iconViseble=false;
 @track iconSymbole="utility:hide";
 //sfdcBaseURL;

  handleToggleIconshow(event){ console.log("popopo-111");
   let targetId = event.target.dataset.id;
   console.log("targetId "+targetId);
   let target = this.template.querySelector(`[data-id="${targetId}"]`);
   if(target.iconName === "utility:preview"){
    // this.iconSymbole =  "utility:hide";
      target.iconName = "utility:hide";
   }
   else if(target.iconName === "utility:hide"){
    target.iconName = "utility:preview";
    // this.iconSymbole =  "utility:preview";
   }
//    this.template.querySelectorAll('.iconName').forEach((icon) => {
//     if (icon.dataset.id !== targetId) {
//         icon.iconName = "utility:preview";  // Reset other icons to "preview"
//     }
// });
   console.log('target.iconName '+target.iconName);
  this.template.querySelectorAll(`[data-id="${targetId}Check"]`).forEach((element) => { console.log("popopo-222");
        if( element.style.display === "none"){
            element.style.display = "block";
        } else if( element.style.display === "block"){
            element.style.display = "none";
        }
  });
}

@track isDVisible=false; 
@track show="Show";
handleToggleSectionD(){
    this.isDVisible=!this.isDVisible;
    if(this.show == 'Show'){
        this.show = 'Hide';
    }
    else if(this.show == 'Hide'){
      this.show = 'Show';
  }
}


  jsonEscape(str) {
      return str.replace(/\n/g, "\\\\n").replace(/\r/g, "\\\\r").replace(/\t/g, "\\\\t");
  }

  get fieldTabValues() {
      return this.mylstFieldTabs;
  }
  set mytabsetvalues(value){
    this.mytabset = value;
  }
  get mytabsetvalues() {
    
    return this.mytabset.map(elmt => {
        let helptext;
        // console.log('elmt.labeltype '+elmt.labeltype);
        if (elmt.labeltype === 'Search by Door Owner') {
            helptext = 'Please enter at least 3 characters. References active Account Owners based on role.';
        } else if (elmt.labeltype === 'Search by Account KAM') {
            helptext = 'Please enter at least 3 characters. References active Ultimate Parent Account owners based on role.';
        }else if(elmt.labeltype === 'Search by Ultimate Parent Account'){
            helptext = 'Please enter at least 3 characters.';
        }
        return {
            ...elmt,
            iconBl:elmt.labeltype === 'Search By Account Id' ? false : true,
            helpText:helptext,
            // retailTabBl:elmt.ObjectTabName === 'Retail Theater'? true: false,
            tooltip: elmt.labeltype === 'Search By Account Id' ? true : false,
        };
    });
}


  get kamTabValues() {
      return this.mylstKAMTabs;
  }

  get filterOption() {
      return this.items;
  }

  get formOption() {
      return this.formitems;
  }

  get questionOption() {
      return this.myQuestions;
  }
  retryCount = 0;
  maxRetries = 3;
  connectedCallback(){
    console.log('connected callback....');
    this.loadJQuery()
    .then(() => this.loadJQueryModal())
    .then(() => {
        console.log('zoom resources loaded successfully');
        this.loadJQueryModal2();
    })
    .then(() => {
        // console.log('All resources loaded successfully');
        // this.initializeJQueryDependentLogic();
    })
    .catch(error => {
        console.error('Failed to load resources. Error:', error);
    });
  }


//   connectedCallback(){

//     Promise.all([
//         loadScript(this, jQuery3),
//       loadScript(this, jquerymodal + '/jquerymodal/jquery.modal.js'),
//       loadScript(this, lightgallery + '/lightgallery/js/lightgallery-all.js'),
//       loadStyle(this, lightgallery + '/lightgallery/css/lightgallery.css'),
//         loadStyle(this, photoimage),
//     ]).then(() => {
//         console.log('Entered into then block connectedCallback');

//     }
//     )
//         .catch(error => {
//               console.log('Failed to load the JQuery Here is the Error is Connected call back : ' + error);
//           });
//   }



  loadJQuery() {
    return loadScript(this, jQuery3)
        .then(() => {
            // console.log('jQuery loaded successfully');
        })
        .catch(error => {
            console.error('Failed to load jQuery. Error:', error);
            throw error;
        });

}
loadJQueryModal() {
    return new Promise((resolve, reject) => {
        const attemptLoad = () => {
            Promise.all([
                loadScript(this, `${jquerymodal}/jquerymodal/jquery.modal.js`),
                // loadScript(this, `${lightgallery}/lightgallery/js/lg-zoom.min.js`),
                loadScript(this, `${lightgallery}/lightgallery/js/lightgallery.min.js`),
                // loadScript(this, `${lightgallery}/lightgallery/js/lg-autoplay.min.js`),
                loadStyle(this, `${lightgallery}/lightgallery/css/lightgallery.css`),
                loadStyle(this, photoimage)
            ])
            .then(() => {
                // console.log('All scripts and styles loaded successfully');
                resolve();
            })
            .catch(error => {
                console.error('Failed to load scripts or styles. Error:', error);
                if (this.retryCount < this.maxRetries) {
                    this.retryCount++;
                    console.error(`Retrying to load scripts and styles... Attempt ${this.retryCount}`);
                    setTimeout(attemptLoad, 1000); // Adding a delay before retrying
                } else {
                    reject(error);
                }
            });
        };
        attemptLoad();
    });
}
loadJQueryModal2() {
    return new Promise((resolve, reject) => {
        const attemptLoad = () => {
            Promise.all([

                loadScript(this, `${lightgallery}/lightgallery/js/lg-zoom.min.js`),
                // loadScript(this, `${lightgallery}/lightgallery/js/lightgallery.min.js`),
                // loadScript(this, `${lightgallery}/lightgallery/js/lg-autoplay.min.js`),
                // loadStyle(this, `${lightgallery}/lightgallery/css/lightgallery.css`),
                // loadStyle(this, photoimage)
            ])
            .then(() => {
                // console.log('All scripts and styles loaded successfully');
                resolve();
            })
            .catch(error => {
                console.error('Failed to load scripts or styles. Error:', error);
                if (this.retryCount < this.maxRetries) {
                    this.retryCount++;
                    console.error(`Retrying to load scripts and styles... Attempt ${this.retryCount}`);
                    setTimeout(attemptLoad, 1000); // Adding a delay before retrying
                } else {
                    reject(error);
                }
            });
            };
            attemptLoad();
            });
    }



  renderedCallback() {
    //this.sfdcBaseURL = window.location.origin;
    //alert(sfdcBaseURL);
    //  console.log('Calling renderedCallback');
     if(this._initializationCompleted === true){
        // console.log('Entered into first time');
        this.loadJQuery()
        .then(() => this.loadJQueryModal())
        .then(() => {
            console.log('zoom resources loaded successfully');
            this.loadJQueryModal2();
        })
        .then(() => {
            // console.log('All resources loaded successfully _initializationCompleted part...');
            $(this.template.querySelector('.gallery-scroll-view')).html('');
            $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
                thumbnail: true,
                allowMediaOverlap: true,
                mobileSrc : true,
            });

            
            let galleryContent = '';
            this.localphotos.forEach((photo) => {
                // console.log('test photo',photo); //05SR
                let mytlo = photo.allFieldValues2[0];
                //  console.log('test mytlo before',mytlo); //04SR
                //  delete mytlo['Audit Date'];
                //  console.log('test mytlo after',mytlo); //04SR
                const myseclo = JSON.stringify(mytlo);
                let mytlo1 = photo.allFieldValues[0];
                let auditDateVal = photo.auditDate;
              
                // console.log(' photo.allFieldValues2[0] *****((((()))))))*****', photo.allFieldValues2[0]);
                // console.log('test mytlo1',mytlo1); //04SR
                //   console.log('aft test myseclo1...  '+JSON.stringify(mytlo1));
                if (mytlo1.Name && mytlo1.Name.includes("'")) {
                    mytlo1.Name = mytlo1.Name.replace(/'/g, "");
                }
                const myseclo1 = JSON.stringify(mytlo1);
                //   console.log('test myseclo1',myseclo1); //03SR
                // console.log('test version',photo.versionID); //03SR
                // console.log('test form',photo.formId); //03SR
                let myRelo = Object.entries(mytlo);
                //   console.log('test myRelo',myRelo); //03SR
                let photoElementHTML =
                    `<div class="photo-eleme" data-mydynamic='${myseclo1}' data-myversion = "${photo.versionID}"  data-myformID="${photo.formId}" data-src="/sfc/servlet.shepherd/version/download/${photo.versionID}">
                    <img src="/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${photo.versionID}"/>
                    `;
                photoElementHTML = photoElementHTML + `<div data-id="Audit DateCheck" style="background-color: rgb(70, 69, 69);color:white; display: block;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> Audit Date </p><p style="padding-left:3px;font-size:12px;">  ${auditDateVal} </p></div> </div>`;
  
                for (const [key, value] of Object.entries(mytlo)) { 
                    // console.log('key val-',key,'value val-',value);
                    let owntarget = this.template.querySelector(`[data-id="${key}"]`);
                    
                    if(owntarget != null){
                    //   console.log('Calling this time main rendered callback and here is ownTarget'+owntarget);
                    if(owntarget.iconName === "utility:preview"){
                        photoElementHTML = photoElementHTML + `<div data-id="${key}Check" style="background-color: rgb(70, 69, 69);color:white; display: block;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> ${key} </p><p style="padding-left:3px;font-size:12px;">  ${value} </p></div> </div>`;
                    }
                    else if(owntarget.iconName === "utility:hide"){
                        photoElementHTML = photoElementHTML + `<div data-id="${key}Check" style="background-color: rgb(70, 69, 69);color:white; display: none;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> ${key} </p><p style="padding-left:3px;font-size:12px;">  ${value} </p></div> </div>`;
                    }
                    }
                    
                }
               
                photoElementHTML = photoElementHTML + ` </div>`;
                //   galleryContent += photoElementHTML;
                $(this.template.querySelector('.gallery-scroll-view')).append(photoElementHTML);
                  console.log('click 1 ');
                this.photoClickable(this);
            })
            // $(this.template.querySelector('.gallery-scroll-view')).append(galleryContent);
            //   console.log('renderedcallback1 '+JSON.stringify(this));
            //   this.photoClickable(this);
            try{
                $(this.template.querySelector('.gallery-scroll-view')).data('lightGallery').destroy(true);
            }
            catch (e) {}
    
            $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
                thumbnail:true,
                enableDrag:false,
                allowMediaOverlap: true,
            });
        })
        .catch(error => {
            console.error('Failed to load resources. Error:', error);
        });
        // Promise.all([
        //   loadScript(this, jQuery3),
        //   loadScript(this, jquerymodal + '/jquerymodal/jquery.modal.js'),
        //   loadScript(this, jquerymodal + '/jquerymodal/jquery.modal.css'),
        //   loadScript(this, lightgallery + '/lightgallery/js/lightgallery-all.js'),
        //   loadStyle(this, lightgallery + '/lightgallery/css/lightgallery.css'),
        //   loadStyle(this, photoimage),
        // ]).then(() => {
        // //   console.log('Entered into then block');
         
        // })
        // .catch(error => {
        //       console.log('Failed to load the JQuery Here is the Error is rendered callback : ' + error);
        //   });
     }
      if (!this._initializationCompleted) { console.log("aaa-111");
          
        this.showDataLoading = true;
          getAvailbleFieldFilters()
              .then((result) => { console.log("aaa-222",JSON.parse(result));
                  var so = JSON.stringify(result);
                  this.currentFilterTabContent = JSON.parse(result);
              })
              .catch((error) => {
                  this.error = error;
                  console.error('Error Call getAvailbleFieldFilters');
              });

              getAvailbleKAMFilters()
              .then((result) => {
                  var so = JSON.stringify(result);
                  this.currentKAMTabContent = JSON.parse(result);
              })
              .catch((error) => {
                  this.error = error;
                  console.error('Error Call getAvailbleFieldFilters');
              });

          getFieldTabNames()
              .then((result) => {
                  this.mylstFieldTabs = result;
              })
              .catch((error) => {
                  this.error = error;
                  console.error('Error Call getFieldTabNames');
              });

          getKAMTabNames()
              .then((result) => {
                  this.mylstKAMTabs = result;
              })
              .catch((error) => {
                  this.error = error;
                  console.error('Error Call getKAMTabNames');
              });

          getSavedFilterNames({
                  mypersona: this.isfilterpersona
              })
              .then((result) => {
                  this.items = JSON.parse(result);
                  
              })
              .catch((error) => {
                  this.error = error;
                  console.error('Error Call getSavedFilterNames');
              });

          getFormValues()
              .then((result) => {
                  this.formitems = JSON.parse(result);
              })
              .catch((error) => {
                  this.error = error;
                  console.error('Error Call getFormValues');
              });

          fetchPhotosForAppliedFilter({
                  filtervalues: this.mytemp,
                  questionIdValues: this.mySelectedQuestionIds,
                  myPersona: this.isfilterpersona,
                  myPage: this.pageNum,
                  formSubmittedDate: this.myFormSubmittedDate,
                  formSubmittedDateTo: this.myFormSubmittedDateTo
              })
              .then((result) => {
                  this.allimages = JSON.parse(result);
                  console.log('*** Image Info',JSON.stringify(this.allimages));
                  let lenOfAllImg = 0;
                //   console.log('Success Call fetchPhotosForAppliedFilter');
                  this.showDataLoading = false;
                  this.leng = true;
                  if(this.allimages.length === 0){
                    this.isPhotoNotAvailable = true;
                    this.leng = false;
                  }
                  else{
                    this.totallenrecord = this.allimages[0]['total'];
                    this.localphotos =  this.allimages;
                  }

                //   console.log('Entered into first time');
                  this.loadJQuery()
                  .then(() => this.loadJQueryModal())
                  .then(() => {
                    console.log('zoom resources loaded successfully');
                    this.loadJQueryModal2();
                })
                  .then(() => {
                    //   console.log('All resources loaded successfully fetchPhotoPart....');
                    //   console.log('Entered into then block');
                      $(this.template.querySelector('.gallery-scroll-view')).html('');
                      $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
                          thumbnail: true,
                          allowMediaOverlap: true,
                      });
                      let galleryContent = '';
                      this.localphotos.forEach((photo) => {
                          let mytlo = photo.allFieldValues2[0];
                          const myseclo = JSON.stringify(mytlo);
                          let mytlo1 = photo.allFieldValues[0];
                          if (mytlo1.Name && mytlo1.Name.includes("'")) {
                            mytlo1.Name = mytlo1.Name.replace(/'/g, "");
                        }
                          const myseclo1 = JSON.stringify(mytlo1);
                          let myRelo = Object.entries(mytlo);
                        //   console.log('data before loading.... '+myseclo1);
                         
                        // console.log('aft data before loading...  '+myseclo1);
                          let auditDateVal = photo.auditDate;
                          let photoElementHTML =
                              `<div class="photo-eleme" data-mydynamic='${myseclo1}' data-src="/sfc/servlet.shepherd/version/download/${photo.versionID}">
                            <img src="/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${photo.versionID}"/>
                            `;

                          photoElementHTML = photoElementHTML + '<div data-id="Audit DateCheck" style="background-color: rgb(70, 69, 69);color:white; display: block;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> Audit Date </p><p style="padding-left:3px;font-size:12px;">  ${auditDateVal} </p></div> </div>';
                          for (const [key, value] of Object.entries(mytlo)) {
                            // console.log('key val-111 ',key,'value val-111 ',value);
                              let owntarget = this.template.querySelector('[data-id="${key}"]');

                              if (owntarget != null) {
                                //   console.log('Calling this time main rendered callback and here is ownTarget' + owntarget);
                                  if (owntarget.iconName === "utility:preview") {
                                      photoElementHTML = photoElementHTML + '<div data-id="${key}Check" style="background-color: rgb(70, 69, 69);color:white; display: block;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> ${key} </p><p style="padding-left:3px;font-size:12px;">  ${value} </p></div> </div>';
                                  }
                                  else if (owntarget.iconName === "utility:hide") {
                                      photoElementHTML = photoElementHTML + '<div data-id="${key}Check" style="background-color: rgb(70, 69, 69);color:white; display: none;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> ${key} </p><p style="padding-left:3px;font-size:12px;">  ${value} </p></div> </div>';
                                  }
                              }
                          }
                        //   console.log('data loading.... ' + photoElementHTML);
                          photoElementHTML = photoElementHTML + ' </div>';
                        //   galleryContent += photoElementHTML;
                          $(this.template.querySelector('.gallery-scroll-view')).append(photoElementHTML);
                          console.log('click2 ');
                          this.photoClickable(this);
                      })
                    //   $(this.template.querySelector('.gallery-scroll-view')).append(galleryContent);
                    //     console.log('renderedcallback1 '+JSON.stringify(this));
                    //     this.photoClickable(this);
                      try {
                          $(this.template.querySelector('.gallery-scroll-view')).data('lightGallery').destroy(true);
                      }
                      catch (e) { }

                      $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
                          thumbnail: true,
                          enableDrag: false,
                          allowMediaOverlap: true,
                      });
                  })
                  .catch(error => {
                      console.error('Failed to load resources. Error:', error);
                  });
                //   Promise.all([
                //     loadScript(this, jQuery3),
                //    loadScript(this, jquerymodal + '/jquerymodal/jquery.modal.js'),
                //    loadScript(this, jquerymodal + '/jquerymodal/jquery.modal.css'),
                //    loadScript(this, lightgallery + '/lightgallery/js/lightgallery-all.js'),
                //    loadStyle(this, lightgallery + '/lightgallery/css/lightgallery.css'),
                //     loadStyle(this, photoimage),
                //   ]).then(() => {
                     
                //   })
                //   .catch(error => {
                //         console.log('Failed to load the JQuery Here is the Error is After Response : ' + error);
                //     });
                  // const objChild = this.template.querySelector('c-photo-gallery');
                //  objChild.addContactToList(this.allimages);
              })
              .catch((error) => {
                  this.error = error;
                  console.error('Error Call fetchPhotosForAppliedFilter First time call');
                  this.showDataLoading = false;
              });
          this._initializationCompleted = true;
      }
  }

  handleKAMFilterActivetab(event) {
    console.log('tabname '+event.target.value);
    this.mykamtabset = [];
    this.activetab = event.target.value;
 //   this.mytabset = [];
    for (var i = 0; i < this.currentKAMTabContent.length; i++) {
        let stemp = '';
        stemp = this.activetab;
        if (JSON.stringify(this.currentKAMTabContent[i][stemp]) == JSON.stringify(this.activetab)) {
            this.mykamtabset.push(this.currentKAMTabContent[i]);
        }
    }
    if(this.mykamtabset.length > 1){
    this.mykamtabset.sort((a, b) => parseFloat(a.SerialNumber) - parseFloat(b.SerialNumber));
    }
    console.log('filter '+JSON.stringify(this.mykamtabset ));
  }

  handleClearFilters(){
      if(this.mytemp.length === 0){
        const evt = new ShowToastEvent({
            title: 'There are no selected filter values under All Filters section.',
            message: '',
            variant: 'info',
        });
        this.dispatchEvent(evt);
       return;
      }
      this.selectedEditSavedFilterName = '';
      this.clearAllFilterNotification = true;
  }

  handleClearForm(){
    this.clearAllFormNotification = true;
   
}

  handleCancel(){
    this.clearAllFilterNotification = false;

  }
  handleCancelForm(){
    this.clearAllFormNotification = false;

  }

  handleProceedForm(){
    this.mySelectedFormIds = [];
    this.mySelectedQuestionIds = [];
    this.myFormSubmittedDate = '';
    this.myFormSubmittedDateTo = '';
    this.beforeTempQuestionId = [];
    this.beforeTempubmittedDate = '';
    this.beforeTempubmittedDateTo = '';
    const evt = new ShowToastEvent({
        title: 'All Survey/Question/Submitted date values are reset now.',
        message: '',
        variant: 'info',
    });
    this.dispatchEvent(evt);
    this.clearAllFormNotification = false;
}

  handleProceed(){
    this.mytemp = [];
    this.beforeTempFilterValues = [];
    /*let ctPerosna = this.isfilterpersona;
    if(ctPerosna){
        this.currentKAMTabContent = [];
    }
    else{
        this.currentFilterTabContent = [];
    }*/
  this.mylstFieldTabs = [];
  this.mylstKAMTabs = [];
  
    getFieldTabNames()
    .then((result) => {
        this.mylstFieldTabs = result;
    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call getFieldTabNames');
    });
  
    getKAMTabNames()
    .then((result) => {
        this.mylstKAMTabs = result;
    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call getKAMTabNames');
    });
    if(this.isfilterpersona && this.currentFilterTabContent !== undefined){
        for (let t = 0; t < this.currentFilterTabContent.length; t++) {
            this.currentFilterTabContent[t]['tempofieldval'] = '';
        }
    
  }
  else if(!this.isfilterpersona && this.currentKAMTabContent !== undefined){
    for (let p = 0; p < this.currentKAMTabContent.length; p++) {
        this.currentKAMTabContent[p]['tempofieldval'] = '';
  
    }
   
  }
 

  const evt = new ShowToastEvent({
    title: 'All filter values are reset now.',
    message: '',
    variant: 'info',
});
this.dispatchEvent(evt);
this.clearAllFilterNotification = false;

}

@api 
callThisMethodFromFilterPersona(currentPersona){
    this.showDataLoading = true;
    this.isPhotoNotAvailable = false;
    this.mytemp = [];
    let ctPerosna = currentPersona;
    this.mytabset = []; // RECENT 
    this.mylstFieldTabs = [];
    this.mylstKAMTabs = [];
  
  
    getFieldTabNames()
    .then((result) => {
        this.mylstFieldTabs = result;
    })
    .catch((error) => {
        this.error = error;
        console.log('Error Call getFieldTabNames');
    });
  
    getKAMTabNames()
    .then((result) => {
        this.mylstKAMTabs = result;
    })
    .catch((error) => {
        this.error = error;
        console.log('Error Call getKAMTabNames');
    });

    if(ctPerosna){
        this.currentKAMTabContent = [];
    }
    else{
        this.currentFilterTabContent = [];
    }

    getAvailbleFieldFilters()
    .then((result) => { console.log("aaa-333",JSON.parse(result));
        var so = JSON.stringify(result);
        this.currentFilterTabContent = JSON.parse(result);
    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call getAvailbleFieldFilters');
    });

    getAvailbleKAMFilters()
    .then((result) => {
        var so = JSON.stringify(result);
        this.currentKAMTabContent = JSON.parse(result);
    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call getAvailbleFieldFilters');
    });

   
    this.items = [];
    getSavedFilterNames({
        mypersona: ctPerosna
    })
    .then((result) => {
        this.items = JSON.parse(result);
    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call getSavedFilterNames');
    });


    fetchPhotosForAppliedFilter({
        filtervalues: this.mytemp,
        questionIdValues: this.mySelectedQuestionIds,
        myPersona: ctPerosna,
        myPage: this.pageNum,
        formSubmittedDate: this.myFormSubmittedDate,
        formSubmittedDateTo: this.myFormSubmittedDateTo
    })
    .then((result) => {
        this.allimages = [];
        this.allimages = JSON.parse(result);
        this.leng = true;
        let imageResult = this.allimages;
        this.localphotos = [];
        this.localphotos = imageResult;
        let lenOfAllImg = 0;
        //this.leng = true;
      //  const objChild = this.template.querySelector('c-photo-gallery');
       
        this.showDataLoading = false;
        if(this.allimages.length === 0){
            this.isPhotoNotAvailable = true;
            this.leng = false;
        }
        else{
            lenOfAllImg = this.allimages[0]['total'];
            this.totallenrecord = this.allimages[0]['total'];
        }
      //  this.addContactToList(imageResult, lenOfAllImg,this.pageNum);
          const objChild = this.template.querySelector('c-photo-pagination');
         objChild.setRecordsToDisplay(imageResult,lenOfAllImg);
       //  this.leng = true;

    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call Switch from Persona button'+error);
        this.showDataLoading = false;
    });
  }


  @track iconhidePart = true;
  handleFieldFilterActivetab(event) {
      this.mytabset = [];
      if(event !== undefined){
        this.activetab = event.target.value;
      }
      if(event === undefined){
          //this.mytabset = [];
          this.activetab = 'Account';
      }
      this.iconhidePart = this.activetab === 'Campaign'? false : true;
      this.retailTheaterTab = this.activetab === 'Retail Theater'? true : false;
   
   //   this.mytabset = [];
   console.log(' isfilterpersona '+this.isfilterpersona);

//    console.log("this.currentFilterTabContent",this.currentFilterTabContent);
      for (var i = 0; i < this.currentFilterTabContent.length; i++) {
          let stemp = '';
          stemp = this.activetab;
          if (JSON.stringify(this.currentFilterTabContent[i][stemp]) == JSON.stringify(this.activetab)) {
              this.mytabset.push(this.currentFilterTabContent[i]);
              /*  if(this.currentFilterTabContent[i]['isPicklist']){
                    this.template.querySelector("c-multi-pick-list-filter").onRefreshClick();
                    console.log('called child method');
                }*/
          }
      }
      if(this.mytabset.length > 1){
      this.mytabset.sort((a, b) => parseFloat(a.SerialNumber) - parseFloat(b.SerialNumber));
      }
    //   console.log('called child method '+JSON.stringify(this.mytabset));
    //   console.log('filter '+JSON.stringify(this.mykamtabset ));
  }

  showModalBox() {
    if(this.mytemp.length === 0){
        const evt = new ShowToastEvent({
            title: 'Please select at least one filter and Save.',
            message: '',
            variant: 'info',
        });
        this.dispatchEvent(evt);
    
        this.hideModalBox();

        return;
    }
      this.isShowModal = true;
  }

  hideModalBox() {
      this.isShowModal = false;
  }

  handleRefreshFilter(){
    this.items = [];

    getSavedFilterNamesRefresh({
        mypersona: this.isfilterpersona
    })
    .then((result) => {
        this.items = JSON.parse(result);
        
    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call getSavedFilterNames');
    });

    const evt = new ShowToastEvent({
        title: 'Saved Filter values are refreshed.',
        message: '',
        variant: 'info',
    });
    this.dispatchEvent(evt);


  }

  savefilter(event) {
    var filname = this.template.querySelector(".myclas");
    this.newfiltername = filname.value;

    if(filname.value == ''){

        const evt = new ShowToastEvent({
            title: 'Please enter filter name first.',
            message: '',
            variant: 'warning',
        });
        this.dispatchEvent(evt);
        return;
        
    }
    let personaaname = '';
    if (this.isfilterpersona === true) {
        personaaname = 'Field Filter';
    } else {
        personaaname = 'KAM Filter';
    }

    isFilterAlreadyAvailable({
        filterName: this.newfiltername,
        personaName: personaaname
    })
    .then((result) => {

        let myFlag = false;
        if(this.selectedEditSavedFilterName != this.newfiltername){
            myFlag = true;
        }

        let saveResult = result;
        if(saveResult == 'Available' && myFlag){
            const evt = new ShowToastEvent({
                title: 'This filter name is already exist. Please change the name and save it.',
                message: '',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
          return;
        }

        else if(saveResult == 'Not Available' || this.selectedEditSavedFilterName != ''){
            let questionido = JSON.stringify(this.mySelectedQuestionIds);
            let allselectfieldvalueo = JSON.stringify(this.mytemp);

    saveNewFilter({
            filterName: this.newfiltername,
            personaName: personaaname,
            questionIds: questionido,
            allselectfilterValues: allselectfieldvalueo,
            selectedEditFilter: this.selectedEditSavedFilterName,
            fromSubmittedDate: this.myFormSubmittedDate,
            toSubmittedDate: this.myFormSubmittedDateTo
        })
        .then((result) => {
            const evt = new ShowToastEvent({
                title: 'Success Message',
                message: 'Filter name is saved.',
                variant: 'success',
            });
            this.dispatchEvent(evt);

            this.hideModalBox();
        })
        .catch((error) => {


            const evt = new ShowToastEvent({
                title: 'Error Message',
                message: error,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.hideModalBox();
        });
    
    }
       
    })
    .catch((error) => {
        const evt = new ShowToastEvent({
            title: 'Error Message',
            message: error,
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.hideModalBox();
    });
}
  handleValueChange(event) {
      let moselectedvalues = [];
      let poarray = [];
      poarray = event.detail.item;
      for (var m = 0; m < poarray.length; m++) {
          moselectedvalues.push(poarray[m]['value']);
      }
      let moname = '';
      moname = this.activetab;
      let mymytemp = [];
      mymytemp = {
          "objectapiname": [moname],
          "fieldapiname": [event.detail.aponame],
          "fieldType": ["multiple"],
          "selectedvalues": moselectedvalues
      };
         this.mytemp = this.findExistingValues(this.mytemp, mymytemp.objectapiname, mymytemp.fieldapiname, mymytemp.selectedvalues, mymytemp);

         this.mytemp = this.mytemp.filter(row => row.selectedvalues.length > 0 && row.selectedvalues[0] !== "");
         console.log('this.mytemp 111 '+JSON.stringify(this.mytemp));
      if(this.isfilterpersona){
        for (var i = 0; i < this.currentFilterTabContent.length; i++) {
            let moname = '';
            moname = this.activetab;
            let myfieldoname = '';
            myfieldoname = event.detail.aponame;
            if (this.currentFilterTabContent[i][moname] === this.activetab && this.currentFilterTabContent[i]['APIName'] === myfieldoname) {
                this.currentFilterTabContent[i]['tempofieldval'] = mymytemp.selectedvalues;
            }
        }
      }
      else{

        for (var j = 0; j < this.currentKAMTabContent.length; j++) {
            let moname = '';
            moname = this.activetab;
            let myfieldoname = '';
            myfieldoname = event.detail.aponame;
            if (this.currentKAMTabContent[j][moname] === this.activetab && this.currentKAMTabContent[j]['APIName'] === myfieldoname) {
                this.currentKAMTabContent[j]['tempofieldval'] = mymytemp.selectedvalues;
            }
        }
      }

    //   if(this.activetab === 'Retail Theater'){
    //     this.retailTabBl = false;
    //   }
  }

  handleValueChangeField(event) {
      let moname = '';
      moname = this.activetab;
      let mymytemp = [];
      let selectedVal = event.target.value;

      if (event.target.name == 'Id' && moname == 'Account' && String(selectedVal).includes(',')) {
        selectedVal = String(selectedVal).split(',').map(val => val.trim()).join(',');
        
    }
    // console.log('fieldName '+event.target.name+' selectedVal '+selectedVal+'  obj '+ moname);
      mymytemp = {
          "objectapiname": [moname],
          "fieldapiname": [event.target.name],
          "fieldType": ["single"],
          "selectedvalues": [selectedVal]
      };
        this.mytemp = this.findExistingValues(this.mytemp, mymytemp.objectapiname, mymytemp.fieldapiname, mymytemp.selectedvalues, mymytemp);

        this.mytemp = this.mytemp.filter(row => row.selectedvalues.length > 0 && row.selectedvalues[0] !== "");
     console.log('campaign data',JSON.stringify(this.mytemp));
 if(this.isfilterpersona){
      for (var i = 0; i < this.currentFilterTabContent.length; i++) {
          let moname = '';
          moname = this.activetab;
          let myfieldoname = '';
          myfieldoname = event.target.name;
          if (this.currentFilterTabContent[i][moname] === this.activetab && this.currentFilterTabContent[i]['APIName'] === myfieldoname) {
              this.currentFilterTabContent[i]['tempofieldval'] = event.target.value;
          }
      }
    }
    else{
        for (var j = 0; j < this.currentKAMTabContent.length; j++) {
            let moname = '';
            moname = this.activetab;
            let myfieldoname = '';
            myfieldoname = event.target.name;
            if (this.currentKAMTabContent[j][moname] === this.activetab && this.currentKAMTabContent[j]['APIName'] === myfieldoname) {
                this.currentKAMTabContent[j]['tempofieldval'] = event.target.value;
            }
        }
    }
  }

  findExistingValues(arr, objectname, fieldname, selectedval, localarr) {

      let objectstr = '';
      let mytr = '';
      objectstr = objectname;
      let fieldstr = '';
      fieldstr = fieldname;
      var arrayLength = arr.length;
        
      let myobj = arr.find(x => JSON.stringify(x.fieldapiname) === JSON.stringify(fieldname) && JSON.stringify(x.objectapiname) === JSON.stringify(objectname));
      if (myobj !== undefined) {
          myobj.selectedvalues = selectedval;
      } else {
          arr.push(localarr);
      }
      return arr;
  }


  handleSavedFilterChange(event) {

      let mytemparr = [];
      mytemparr = event.detail.item;
     
      
    if(mytemparr.length === 0){

        this.mysavedfiltertemp = [];
        return;
    }
    this.selectedSavedFilterName = mytemparr[0].value;

      let myselctedsavedfiltro;
      myselctedsavedfiltro = JSON.stringify(mytemparr[0].value);

      getSelectedSavedJsonValuesFilter({
              filterName: myselctedsavedfiltro,
              mypersona: this.isfilterpersona
          })
          .then((result) => {
              this.mysavedfiltertemp = [];
              this.mysavedfiltertemp = JSON.parse(result);
            // Removed code which populate field values directly in currentTabset and p
            //placed that code indo Edit button action 
          })
          .catch((error) => {
              this.error = error;
              console.log('Error Call AFTER FORMTEMPLATE SELECTION');
          });

      getSelectedSavedJsonValuesQuestion({
              filterName: myselctedsavedfiltro,
              mypersona: this.isfilterpersona
          })
          .then((result) => {
              this.mysavedfilterquestiontemp = [];
              this.mysavedfilterquestiontemp = JSON.parse(result);
          })
          .catch((error) => {
              this.error = error;
              console.error('Error Call AFTER FORMTEMPLATE SELECTION');
          });

          getSelectedSavedJsonValuesFromDate({
            filterName: myselctedsavedfiltro,
            mypersona: this.isfilterpersona
        })
        .then((result) => {
            this.mysavedFromDate = result;
        })
        .catch((error) => {
            this.error = error;
            console.error('Error Call AFTER FROM DATE SELECTION');
        });

        getSelectedSavedJsonValuesToDate({
            filterName: myselctedsavedfiltro,
            mypersona: this.isfilterpersona
        })
        .then((result) => {
            this.mysavedToDate = result;
        })
        .catch((error) => {
            this.error = error;
            console.error('Error Call AFTER To DATE SELECTION');
        });


  }

  handleClick(){

    if(this.mysavedfiltertemp.length === 0){

      

            const evt = new ShowToastEvent({
                title: 'Please select one of saved filter and Edit.',
                message: '',
                variant: 'info',
            });
            this.dispatchEvent(evt);
        
            this.hideModalBox();
    
            return;
    
    
    
    }
    // console.log('My From Date is:::'+this.mysavedFromDate);
    // console.log('My To Date is:::'+this.mysavedToDate);
    this.myFormSubmittedDate = this.mysavedFromDate;
    this.myFormSubmittedDateTo = this.mysavedToDate;
    this.selectedEditSavedFilterName = this.selectedSavedFilterName;
    this.mylstFieldTabs = [];
    this.mylstKAMTabs = [];
 
    const evt = new ShowToastEvent({
        title: 'Please See the selected saved Filter values under All Filters section,Edit filter values and Save OR Apply.',
        message: '',
        variant: 'info',
    });
    this.dispatchEvent(evt);

    this.hideModalBox();
   

    this.mytabset = [];
   // this.mylstFieldTabs = [];
    getFieldTabNames()
    .then((result) => {
        this.mylstFieldTabs = result;
    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call getFieldTabNames');
    });

    getKAMTabNames()
    .then((result) => {
        this.mylstKAMTabs = result;
    })
    .catch((error) => {
        this.error = error;
        console.error('Error Call getKAMTabNames');
    });
    if(this.isfilterpersona && this.currentFilterTabContent !== undefined){
        for (let t = 0; t < this.currentFilterTabContent.length; t++) {
            this.currentFilterTabContent[t]['tempofieldval'] = '';
        }
    
}
else if(!this.isfilterpersona && this.currentKAMTabContent !== undefined){
    for (let p = 0; p < this.currentKAMTabContent.length; p++) {
        this.currentKAMTabContent[p]['tempofieldval'] = '';

    }
   

}
    /* getAvailbleFieldFilters()
     .then((result) => {
         var so = JSON.stringify(result);
         this.currentFilterTabContent = JSON.parse(result);
         console.log('Here is success result for all fields available for Field FIlter'+JSON.stringify(this.currentFilterTabContent));
     })
     .catch((error) => {
         this.error = error;
         console.log('Error Call getAvailbleFieldFilters');
     });*/
     this.handleFieldFilterActivetab();  //Newly Called by Viren
    this.mytemp = [];
    this.mytemp = this.mysavedfiltertemp;
    if(this.isfilterpersona){
        for (var m = 0; m < this.mysavedfiltertemp.length; m++) {
            for (var i = 0; i < this.currentFilterTabContent.length; i++) {
                let objapina = '';
                let fieldapina = '';
                let objectapina = '';
                let fieldapi = '';
                objapina = JSON.stringify(this.mysavedfiltertemp[m]['objectapiname'][0]);
                fieldapina = JSON.stringify(this.mysavedfiltertemp[m]['fieldapiname'][0]);
                objectapina = JSON.stringify(this.currentFilterTabContent[i]['ObjectTabName']);
                fieldapi = JSON.stringify(this.currentFilterTabContent[i]['APIName']);
                if (objectapina == objapina && fieldapi == fieldapina) {
                    if (this.currentFilterTabContent[i]['isText']) {
                        this.currentFilterTabContent[i]['tempofieldval'] = this.mysavedfiltertemp[m]['selectedvalues'][0];
                    } else {
                        let finalvaluesto = [];
                        if (typeof this.mysavedfiltertemp[m]['selectedvalues'] === 'object' && this.mysavedfiltertemp[m]['selectedvalues'] !== null) {
                            for (var z = 0; z < this.mysavedfiltertemp[m]['selectedvalues'].length; z++) {
                                finalvaluesto.push(this.mysavedfiltertemp[m]['selectedvalues'][z]);
                            }
                            this.currentFilterTabContent[i]['tempofieldval'] = finalvaluesto;
                        }
                    }
    
                }
    
            }
        }
       // this.isfilterpersona = false;
       // this.isfilterpersona = true;
    }
        else{

            for (var n = 0; n < this.mysavedfiltertemp.length; n++) {
                for (var j = 0; j < this.currentKAMTabContent.length; j++) {
                    let objapina = '';
                    let fieldapina = '';
                    let objectapina = '';
                    let fieldapi = '';
                    objapina = JSON.stringify(this.mysavedfiltertemp[n]['objectapiname'][0]);
                    fieldapina = JSON.stringify(this.mysavedfiltertemp[n]['fieldapiname'][0]);
                    objectapina = JSON.stringify(this.currentKAMTabContent[j]['ObjectTabName']);
                    fieldapi = JSON.stringify(this.currentKAMTabContent[j]['APIName']);
                    if (objectapina == objapina && fieldapi == fieldapina) {
                        if (this.currentKAMTabContent[j]['isText']) {
                            this.currentKAMTabContent[j]['tempofieldval'] = this.mysavedfiltertemp[n]['selectedvalues'][0];
                        } else {
                           
                            let finalvaluesto = [];
                            if (typeof this.mysavedfiltertemp[n]['selectedvalues'] === 'object' && this.mysavedfiltertemp[n]['selectedvalues'] !== null) {
                        
                                for (var z = 0; z < this.mysavedfiltertemp[n]['selectedvalues'].length; z++) {
                                    finalvaluesto.push(this.mysavedfiltertemp[n]['selectedvalues'][z]);
                                }
        
                                this.currentKAMTabContent[j]['tempofieldval'] = finalvaluesto;
                            }
                        }
        
                    }
        
                }
            }
        }
        
        this.loadingEditFilter = false;
  }

  

  handleTemplateChange(event) {

      let mytemparr = [];
      mytemparr = event.detail.item;
      this.mySelectedFormIds = [];
      for (var i = 0; i < mytemparr.length; i++) {
          this.mySelectedFormIds.push(mytemparr[i].Id);
      }
      getQuestionValues({
              Ids: this.mySelectedFormIds
          })
          .then((result) => {
              this.myQuestions = [];
              this.myQuestions = JSON.parse(result);
          })
          .catch((error) => {
              this.error = error;
              console.log('Error Call AFTER FORMTEMPLATE SELECTION');
          });

  }


  handleLookup(event) {

      this.myselo = JSON.parse(JSON.stringify(event.detail.selRecords));
      let moselectedvalues = [];
      let poarray = [];
      poarray = event.detail.selRecords;
      for (var m = 0; m < poarray.length; m++) {
          moselectedvalues.push(poarray[m]['recId']);
      }
      console.log(' moselectedvalues '+JSON.stringify(moselectedvalues));
      let moname = '';
      moname = this.activetab;
      let mymytemp = [];
      mymytemp = {
          "objectapiname": [moname],
          "fieldapiname": [event.detail.fieldAPI],
          "fieldType": ["lookup"],
          "selectedvalues": moselectedvalues
      };
        this.mytemp = this.findExistingValues(this.mytemp, mymytemp.objectapiname, mymytemp.fieldapiname, mymytemp.selectedvalues, mymytemp);

        this.mytemp = this.mytemp.filter(row => row.selectedvalues.length > 0 && row.selectedvalues[0] !== "");
      console.log(' this.mytemp '+JSON.stringify(this.mytemp));
      if(this.isfilterpersona){
      for (var i = 0; i < this.currentFilterTabContent.length; i++) {
          let moname = '';
          moname = this.activetab;
          let myfieldoname = '';
          myfieldoname = event.detail.fieldAPI;
          if (this.currentFilterTabContent[i][moname] === this.activetab && this.currentFilterTabContent[i]['APIName'] === myfieldoname) {
              this.currentFilterTabContent[i]['tempofieldval'] = mymytemp.selectedvalues;
          }
      }
    }
    else{

        for (var j = 0; j < this.currentKAMTabContent.length; j++) {
            let moname = '';
            moname = this.activetab;
            let myfieldoname = '';
            myfieldoname = event.detail.fieldAPI;
            if (this.currentKAMTabContent[j][moname] === this.activetab && this.currentKAMTabContent[j]['APIName'] === myfieldoname) {
                this.currentKAMTabContent[j]['tempofieldval'] = mymytemp.selectedvalues;
            }
        }


    }

  }


  handleQuestionChange(event) {


      let mytemparr = [];
      mytemparr = event.detail.item;
      this.mySelectedQuestionIds = [];
      for (var i = 0; i < mytemparr.length; i++) {
          this.mySelectedQuestionIds.push(mytemparr[i].Id);
      }

  }

  handleFormDateFrom(event){
      this.myFormSubmittedDate = event.detail.value;
  }

  handleFormDateTo(event){
    this.myFormSubmittedDateTo = event.detail.value;
}
handleCheckForm(event){
    if(this.checkIcon_button_tag_form === "action:approval"){
        this.checkIcon_button_tag_form = "action:new";
        this.checkOrUncheckForm = false;
        this.title_checkbox_1="Click to include All Filter Section for Search";
        
    }else if(this.checkIcon_button_tag_form === "action:new"){
        this.checkIcon_button_tag_form = "action:approval";
        this.title_checkbox_1="Click to exclude All Filter Section for Search";
        this.checkOrUncheckForm = true;
    }
}

handleCheckFilter(event){

    if(this.checkIcon_button_tag_filter === "action:approval"){
        this.checkIcon_button_tag_filter = "action:new";
        this.title_checkbox="Click to include Survey Section for Search";
        this.checkOrUncheckFilter = false;
        
    }else if(this.checkIcon_button_tag_filter==="action:new"){
        this.checkIcon_button_tag_filter="action:approval";
        this.title_checkbox="Click to exclude Survey Section for Search";
        this.checkOrUncheckFilter = true;
        this.isDVisible = true;
        if(this.show == 'Show'){
          this.show = 'Hide';
      }
    }
}


    handleFormSendFilter(event) {
        this.isPhotoNotAvailable = false;
        let tempFlagToCheckForm = false;
        if (this.mySelectedQuestionIds.length === 0 && (this.myFormSubmittedDate !== '' && this.myFormSubmittedDateTo !== '')) {
            tempFlagToCheckForm = true;
            // console.log('Entered into Phela IF Block');
        }
        if (this.mySelectedQuestionIds.length === 0 && (this.myFormSubmittedDate === '' && this.myFormSubmittedDateTo === '')) {
            tempFlagToCheckForm = false;
            // console.log('Entered into Dusra IF Block');
        }
        if (this.mySelectedQuestionIds.length !== 0) {
            tempFlagToCheckForm = true;
        }
        let tempFlagToCheckFormDate = false;
        if ((this.myFormSubmittedDate === '' && this.myFormSubmittedDateTo !== '') ||
            (this.myFormSubmittedDate !== '' && this.myFormSubmittedDateTo === '')) {
            tempFlagToCheckFormDate = true;
        }
        if (tempFlagToCheckFormDate) {
            const evt = new ShowToastEvent({
                title: 'Please enter From date and To date',
                message: '',
                variant: 'info',
            });
            this.dispatchEvent(evt);

            this.hideModalBox();

            return;

        }
        if (this.myFormSubmittedDate !== '' && this.myFormSubmittedDateTo !== '') {
            let d1 = Date.parse(this.myFormSubmittedDate);
            let d2 = Date.parse(this.myFormSubmittedDateTo);
            if (d2 < d1) {
                const evt = new ShowToastEvent({
                    title: 'From date can\'t be greater than To date',
                    message: '',
                    variant: 'info',
                });
                this.dispatchEvent(evt);

                this.hideModalBox();

                return;
            }
        }

        this.showDataLoading = true;
        this.beforeTempFilterValues = this.mytemp;
        // console.log('filter data '+JSON.stringify(this.beforeTempFilterValues));
        this.formApplyButton = true;
        this.filterApplyButton = false;
        fetchPhotosForAppliedFilter({
            filtervalues: this.beforeTempFilterValues,
            questionIdValues: this.mySelectedQuestionIds,
            myPersona: this.isfilterpersona,
            myPage: this.pageNum,
            formSubmittedDate: this.myFormSubmittedDate,
            formSubmittedDateTo: this.myFormSubmittedDateTo
        })
            .then((result) => {
                this.allimages = [];
                this.allimages = JSON.parse(result);
                this.leng = true;
                let imageResult = this.allimages;
                let lenOfAllImg = 0;
                // console.log('result444 ' + JSON.stringify(result));
                // console.log('this.allimages' + this.allimages);

                //this.leng = true;
                //  const objChild = this.template.querySelector('c-photo-gallery');

                if (this.allimages.length === 0) {
                    this.isPhotoNotAvailable = true;
                    this.leng = false;
                }
                else {

                    // this.localphotos = [];  // VIREN REMOVDE 23NOV
                    this.localphotos = imageResult;
                    lenOfAllImg = this.allimages[0]['total'];
                    this.totallenrecord = this.allimages[0]['total'];
                    // console.log('Entered into IMAGE RESULT::' + lenOfAllImg);
                }
                //this.addContactToList(imageResult, lenOfAllImg);

                const objChild = this.template.querySelector('c-photo-pagination');
                objChild.setRecordsToDisplay(imageResult, lenOfAllImg);
                //  this.leng = true;

            })
            .catch((error) => {
                this.error = error;
                console.error('Error Call and HERE IS THE MODIFIED ERROR IS' + error);
                this.showDataLoading = false;
            });

    }

    handlesenddata() {
        // this.allimages = [];
        this.isPhotoNotAvailable = false;
        // let flag = true;
        //Below block to handle FOrm Section related stuff
        // console.log('event click');
        // console.log('campaign data', JSON.stringify(this.mytemp));
        // const isCampaignSelected = this.mytemp.some((item) =>
        //     item.objectapiname.includes("Campaign")
        // );

        // // If "Campaign" is selected, disallow access to the "Account" object
        // if (isCampaignSelected) {
        //     this.mytemp
        //         .filter((item) => item.objectapiname.includes("Account"))
        //         .forEach((item) => {
        //             flag =false;
        //             // You can implement your access restriction logic here, e.g., remove or hide the data.
        //             console.log(`Disallow access to ${item.fieldapiname[0]} in Account object.`);
        //         });
        // } else {
        //     flag = true;
        //     // "Campaign" is not selected, allow access to the "Account" object data
        //     console.log("Allow access to Account object data.");
        // }
        let tempFlagToCheckFormDate = false;
        if ((this.myFormSubmittedDate === '' && this.myFormSubmittedDateTo !== '') ||
            (this.myFormSubmittedDate !== '' && this.myFormSubmittedDateTo === '')) {
            tempFlagToCheckFormDate = true;
        }
        if (tempFlagToCheckFormDate) {
            const evt = new ShowToastEvent({
                title: 'Please enter From date and To date',
                message: '',
                variant: 'info',
            });
            this.dispatchEvent(evt);

            this.hideModalBox();

            return;

        }
        if (this.myFormSubmittedDate !== '' && this.myFormSubmittedDateTo !== '') {
            let d1 = Date.parse(this.myFormSubmittedDate);
            let d2 = Date.parse(this.myFormSubmittedDateTo);
            if (d2 < d1) {
                const evt = new ShowToastEvent({
                    title: 'From date can\'t be greater than To date',
                    message: '',
                    variant: 'info',
                });
                this.dispatchEvent(evt);

                this.hideModalBox();

                return;
            }
        }
        this.filterApplyButton = true;
        this.formApplyButton = false;
        this.beforeTempQuestionId = this.mySelectedQuestionIds;
        this.beforeTempubmittedDate = this.myFormSubmittedDate;
        this.beforeTempubmittedDateTo = this.myFormSubmittedDateTo;
        //Above Block to handle Form Section related stuff
        this.showDataLoading = true;
        // console.log('filter data111 '+JSON.stringify(this.mytemp));
        // if(flag){
        //     console.log('excute');
        // }else{
        //     console.error('error');
        // }
        fetchPhotosForAppliedFilter({
            filtervalues: this.mytemp,
            questionIdValues: this.beforeTempQuestionId,
            myPersona: this.isfilterpersona,
            myPage: this.pageNum,
            formSubmittedDate: this.beforeTempubmittedDate,
            formSubmittedDateTo: this.beforeTempubmittedDateTo
        })
            .then((result) => {
                // console.log('result 222 ',result);
                this.allimages = [];
                this.allimages = JSON.parse(result);
                this.leng = true;
                let imageResult = this.allimages;
                let lenOfAllImg = 0;
                //this.leng = true;
                //  const objChild = this.template.querySelector('c-photo-gallery');

                if (this.allimages.length === 0) {
                    this.isPhotoNotAvailable = true;
                    this.leng = false;
                }
                else {
                    //  this.localphotos = [];  VIREN MODIFIED IT NOV
                    this.localphotos = imageResult;
                    lenOfAllImg = this.allimages[0]['total'];
                    this.totallenrecord = this.allimages[0]['total'];
                }
                //this.addContactToList(imageResult, lenOfAllImg);

                const objChild = this.template.querySelector('c-photo-pagination');
                objChild.setRecordsToDisplay(imageResult, lenOfAllImg);
                //  this.leng = true;

            })
            .catch((error) => {
                this.error = error;
                console.error('Error Call and HERE IS THE MODIFIED ERROR IS' + error);
                this.showDataLoading = false;
            });

    }

  appliedsavedfilter(event) {
    this.isPhotoNotAvailable = false;

    if(this.mysavedfiltertemp.length === 0){

        const evt = new ShowToastEvent({
            title: 'Please select one of saved filter and apply.',
            message: '',
            variant: 'info',
        });
        this.dispatchEvent(evt);
    
        this.hideModalBox();

        return;


    }
    this.showDataLoading = true;

       
    this.myFormSubmittedDate = this.mysavedFromDate;
    this.myFormSubmittedDateTo = this.mysavedToDate;
      fetchPhotosForAppliedFilter({
              filtervalues: this.mysavedfiltertemp,
              questionIdValues: this.mysavedfilterquestiontemp,
              myPersona: this.isfilterpersona,
              myPage: this.pageNum,
              formSubmittedDate: this.mysavedFromDate,
              formSubmittedDateTo: this.mysavedToDate

          })
          .then((result) => {
             this.allimages = [];
              this.allimages = JSON.parse(result);
              this.leng = true;
            //   console.log('Entered INTO SAVED EXISTING apply filter button'+this.allimages);
              let imageResult = this.allimages;
              let lenOfAllImg = 0;
              //this.leng = true;
            //  const objChild = this.template.querySelector('c-photo-gallery');
             
              this.showDataLoading = false;
              if(this.allimages.length === 0){
                this.isPhotoNotAvailable = true;
                this.leng = false;
              }
              else{
                lenOfAllImg = this.allimages[0]['total'];
                this.totallenrecord = this.allimages[0]['total'];
            }
            this.addContactToList(imageResult, lenOfAllImg);
            const objChild = this.template.querySelector('c-photo-pagination');
               objChild.setRecordsToDisplay(imageResult,lenOfAllImg);

          })
          .catch((error) => {
              this.error = error;
              this.showDataLoading = false;
              console.error('Error Call and here is the Error 1308'+this.error);
          });

  }


    @api addContactToList(strname, lenoftotal) {

        // this.allimages = [];
        // const objChild = this.template.querySelector('c-photo-pagination');
        //  objChild.setRecordsToDisplay();


        //  $(this.template.querySelector('.gallery-scroll-view')).remove();
        $(this.template.querySelector('.gallery-scroll-view')).html('');
        // this.photoSpinner =  true;
        // console.log('received value is' + JSON.stringify(strname));
        this.photoval = strname;
        if (this.photoval !== '') {
            this.isPhotoAvailable = true;
        }
        // console.log('isPhotoAvailable....' + this.isPhotoAvailable);
        this.loadJQuery()
        .then(() => this.loadJQueryModal())
        .then(() => {
            console.log('zoom resources loaded successfully');
            this.loadJQueryModal2();
        })
        .then(() => {
            // console.log('All resources loaded successfully @api...');
            $(this.template.querySelector('.gallery-scroll-view')).html('');

            $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
                thumbnail: true,
                allowMediaOverlap: true

            });

            // console.log("Applied gallery");

            this.photoval.forEach((photo) => {
                // console.log("me inside the for each this time", photo);
                let mytlo = photo.allFieldValues2[0];
                const myseclo = JSON.stringify(mytlo);
                let mytlo1 = photo.allFieldValues[0];
                if (mytlo1.Name && mytlo1.Name.includes("'")) {
                    mytlo1.Name = mytlo1.Name.replace(/'/g, "");
                }
                const myseclo1 = JSON.stringify(mytlo1);
                let myRelo = Object.entries(mytlo);
                // console.log('myseclo1 222 '+myseclo1);
               
                // console.log('aft myseclo1 222 '+myseclo1);
                let mylo = { "Name": "7-ELEVEN RIS 23837", "State": null, "Start Date": null, "Sales Region": "West", "Account Segment": "TM Uncovered", "Bans": "Menthol Ban;Category Ban;Potency Ban - 0.77%;Potency Ban - 1.5%", "City": null, "Sales Division": "NorCal", "Type": "National Chain Retailer", "Ultimate Parent Owner": "00570000003gXRqAAM", "Parent Account": "0017X00000iBU8TQAW", "Account Service By": null, "Account Owner": "0051O00000D7qyEQAR" };
                let auditDateVal = photo.auditDate;
                let photoElementHTML =
                    `<div class="photo-eleme" data-mydynamic='${myseclo1}' data-myversion = "${photo.versionID}"  data-src="/sfc/servlet.shepherd/version/download/${photo.versionID}">
                <img src="/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${photo.versionID}"/>	
             `;
                photoElementHTML = photoElementHTML + `<div data-id="Audit DateCheck" style="background-color: rgb(70, 69, 69);color:white; display: block;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> Audit Date </p><p style="padding-left:3px;font-size:12px;">  ${auditDateVal} </p></div> </div>`;
                for (const [key, value] of Object.entries(mytlo)) {
                    // console.log('Here is the key and value pair PAIR CHECK' + '${key}' + '${value}');

                    // console.log('Applied Before QuerySelector');
                    let owntarget = this.template.querySelector(`[data-id="${key}"]`);
                    if (owntarget != null) {
                        // console.log('Applied After QuerySelector'+owntarget);
                        if (owntarget.iconName === "utility:preview") {
                            // console.log('Entered into owntarget and dataid is PREVIEW'+ "${key}");
                            photoElementHTML = photoElementHTML + `<div data-id="${key}Check" style="background-color: rgb(70, 69, 69);color:white; display: block;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> ${key} </p><p style="padding-left:3px;font-size:12px;">  ${value} </p></div> </div>`;
                        }
                        else if (owntarget.iconName === "utility:hide") {
                            // console.log('Entered into owntarget and dataid is HIDE'+ "${key}");
                            photoElementHTML = photoElementHTML + `<div data-id="${key}Check" style="background-color: rgb(70, 69, 69);color:white; display: none;font-size:12px;"><div style="display:flex;padding-top:5px;padding-left:3px;padding-bottom:5px;"><p style="background-color:white;border-radius:5px;color:rgb(70, 69, 69);width:80px;font-size:12px;padding-left:3px;"> ${key} </p><p style="padding-left:3px;font-size:12px;">  ${value} </p></div> </div>`;
                        }
                    }
                }
                photoElementHTML = photoElementHTML + ` </div>`;
                // galleryContent += photoElementHTML;
                //    console.log('HERE IS FINAL photoElementHTML value div'+photoElementHTML);
                $(this.template.querySelector('.gallery-scroll-view')).append(photoElementHTML);
                console.log('addContactToList '+JSON.stringify(this));
                this.photoClickable(this);

            });
            // $(this.template.querySelector('.gallery-scroll-view')).append(galleryContent);
            // console.log('renderedcallback1 '+JSON.stringify(this));
            // this.photoClickable(this);
            try {
                $(this.template.querySelector('.gallery-scroll-view')).data('lightGallery').destroy(true);
            }
            catch (e) {
                console.error('Exception is there'+e);
            }

            $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
                thumbnail: true,
                enableDrag: false,
                allowMediaOverlap: true
            });



            $(this.template.querySelector('.gallery-scroll-view')).on('onAfterSlide.lg', function (event, prevIndex, index, fromTouch, fromThumb) {
            });

            this.showDataLoading = false;
        })
        .catch(error => {
            console.error('Failed to load resources. Error:', error);
        });
        // Promise.all([
        //     loadScript(this, jQuery3),
        //     loadScript(this, jquerymodal + '/jquerymodal/jquery.modal.js'),
        //     loadScript(this, lightgallery + '/lightgallery/js/lightgallery-all.js'),
        //     loadStyle(this, lightgallery + '/lightgallery/css/lightgallery.css'),
        //     loadStyle(this, photoimage),
        // ]).then(() => {
        //     console.log('Entered into then block connectedCallback');
           
        // }).catch(error=>{
        //     console.error('error: '+error);
        // })


        //   this.teamon = !this.teamon;


        //   console.log('VALUE OF FORCEFUL TRACK IS'+this.teamon);
        //   this.showDataLoading = false;

        // const objChild = this.template.querySelector('c-photo-pagination');
        // objChild.setRecordsToDisplay();
    }      

    photoClickable(context) { console.log("here image click");
        const galleryScrollView = this.template.querySelector('.gallery-scroll-view');
        $(galleryScrollView).off('onAfterSlide.lg');
        let encounteredIndices = [];
        // $(this.template.querySelector('.gallery-scroll-view')).on('onAfterSlide.lg', function (event, index) {
        $(galleryScrollView).on('onAfterSlide.lg', function (event, index){
          
        //     const counterElement = document.getElementById('lg-counter-current');
        // const counterValue = counterElement ? parseInt(counterElement.textContent):null;
        // console.log("Current counter value:", counterValue);
        setTimeout(() => {
            const counterElement = document.getElementById('lg-counter-current');
            const counterValue = counterElement ? parseInt(counterElement.textContent) : '0';
            console.log("Current counter value:", counterValue);
            index = counterValue > 0 ? counterValue - 1 : index;
            $('.lg-img-wrap').find('.slds-scope').remove();
            console.log("index",index);


            // const element = this.template.querySelector('#lg-counter-current');

            // // To get the HTML content inside the element
            // const htmlContent = element ? element.innerHTML : '';

            // console.log("htmlContent",htmlContent);

            const thisPhotoElement = $('.photo-eleme').eq(index);
            console.log("thisPhotoElement",thisPhotoElement);
            console.log("thisPhotoElement.data('mydynamic')",thisPhotoElement.data('mydynamic'));
            //  console.log("hi me",thisPhotoElement);

            const accountName = thisPhotoElement.data(event.name);
            // console.log('My Photo Glalery debug is'+ JSON.stringify(accountName));
            //const myname=Object.values(accountName.mydynamic);
            let mynameString = thisPhotoElement.data('mydynamic');
            // mynameString = JSON.parse(mynameString);
            // console.log('mynameString'+ mynameString);
            // const myname = mynameString;
            const myname = thisPhotoElement.data('mydynamic');
            const myformID = thisPhotoElement.data('myformid');
            const FinalaccountURL = thisPhotoElement.data('accountid');
            //const myname= $('#photo-eleme').data('key').key
            //$('#myElement').data('key').key;
            //const myname=thisPhotoElement.data('mydynamic');
            // console.log('((( MY JSON FINAL SPRINT4VALUE IS UPDATED new new new old old:::(((())))))))))'+ JSON.stringify(myname));
            // console.log('MY myformID JSON FINAL SPRINT4VALUE IS UPDATED new new new old old:::'+ JSON.stringify(myformID));
            // console.log('myname22 ' + myname+' thisPhotoElement '+JSON.stringify(mynameString));
            // console.log(JSON.parse(JSON.stringify(myname)));
            // let finalo = myname["Account Segment"];
            let finalo = myname;
            let finloformID = myformID;



            //  console.log("hi me final json input for photo gallery new value demo demos dona done ", JSON.stringify(finalo));
            console.log("myname",myname);
            let mydiv = ``;
            for (let key in myname) {
                let goplo = '';

                goplo = myname[key];

                //    console.log('((((((***$$$$$***)))))))myname[key]',myname[key]);
                let a = `${myname[key] === null ? '' : myname[key]}`;
                // console.log('key :: ', key,' a :: ',a);
                let mylop = `<h1 class="slds-grid  slds-p-left_large slds-m-bottom_medium">
   <b class="slds-badge slds-p-horizontal_small" style="border-radius:10px;color:black"> ${key} </b>  <p class="slds-truncate slds-p-left_medium " title=${a}> ${a}</p>
    </h1>`;
                mydiv += mylop;
            }
            // console.log('Final value of div elements are::::' + mydiv);
            //console.log('Final value of Image is::::'+ this.img_icon);
            $('.lg-image').after(`
 <div class="slds-scope mybox" >
    
     <div style="position:fixed;position:absolute;right:100px;top:80px;width:350px;height:540px;">
     <div  style="background:rgba(190, 190, 187, 0.987);color:black;padding:15px;border-radius:10px 10px 0px 0px;"><b style="font-size:25px;">Photo Details</b></div>
          </div>  
  <div style="background-color:white;border-radius:0px 0px 10px 10px;width:350px;height:540px;position:fixed;right:100px;overflow-y: auto;top:145px;color:black;border-bottom:0.5px solid rgba(131, 130, 131, 0.993);">
<div class="slds-grid slds-grid_align-end">



     
  <img id="tys-img" src="/resource/1645116044000/Survey" title="Click to view Survey"/>
  
  </div>
 
  <div class="api  slds-p-top_medium">
 
  ${mydiv}
 
 </div>

   </div>
      </div>`
            );
            $('img#ty-img').on("click", function () {
                // console.log('Image Got clicked');
                context.mynewmethod();
            })
            $('img#tys-img').on("click", function () {
                // console.log('formid is', finloformID);
                context.openEditForm(finloformID);
            })
        }, 100); 
       
        // index = counterValue;


           
            /*$('button#edit-form').on( "click", function() {
                console.log('formid is',finloformID);
                context.openEditForm(finloformID);
               })*/
                // encounteredIndices=[];
        });
        
    }

mynewmethod(){
    // console.log('This is my new Method directly called from chatter photo',this.accountURLID);
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            recordId: this.accountURLID,
            objectApiName: 'Account',
            actionName: 'view'
        },
    }).then(url => {
        console.log('url',url);
        window.open(url);
   });
}

navigateToAccount() {
    console.log('this accountID'+this.accountURLID);
    this[NavigationMixin.Navigate]({
    type: 'standard__recordPage',
    attributes:{
    "recordId": this.accountURLID,
    "objectApiName": 'Account',
    "actionName": 'view'
    }
    });
    }


openEditForm (finloformID) {
    // console.log('insdie openedit form 3344',finloformID);
    //let url = '/apex/disco__FormDetail?Id=' + finloformID;
    let url = '/' + finloformID;
    var win = window.open(url, '_blank');
    win.focus();

}
handlePagination(event){
this.showDataLoading = true;
//  console.log('Pagination action handled from child component', JSON.stringify(event.detail.records));
//  console.log('Page number which i have to call now is::'+ event.detail.pnum);
 this.pageNum = event.detail.pnum;
 let ctPersona = this.isfilterpersona;
//  console.log('Persona Name is:::'+ctPersona);
 this.beforeTempQuestionId = this.mySelectedQuestionIds;
 this.beforeTempubmittedDate = this.myFormSubmittedDate;
 this.beforeTempubmittedDateTo = this.myFormSubmittedDateTo;
 this.beforeTempFilterValues = this.mytemp;

 fetchPhotosForAppliedFilter({
    filtervalues: this.beforeTempFilterValues,
    questionIdValues: this.beforeTempQuestionId,
    myPersona: ctPersona,
    myPage: this.pageNum,
    formSubmittedDate: this.beforeTempubmittedDate,
    formSubmittedDateTo: this.beforeTempubmittedDateTo
})
.then((result) => {
    this.allimages = [];
   
    this.allimages = JSON.parse(result);
    this.leng = true;
    // console.log('Entered INTO Filter change method'+this.allimages);
    let imageResult = this.allimages;
    this.showDataLoading = false;
    let lenOfAllImg = 0;
    //this.leng = true;
  //  const objChild = this.template.querySelector('c-photo-gallery');
  //  this.addContactToList(imageResult);
    this.showDataLoading = false;
    if(this.allimages.length === 0){
        this.isPhotoNotAvailable = true;
        this.leng = false;
    }
    else{
        lenOfAllImg = this.allimages[0]['total'];
    }
      //const objChild = this.template.querySelector('c-photo-pagination');
    // objChild.setRecordsToDisplay(imageResult,lenOfAllImg);
    console.log('Length of total records::::'+lenOfAllImg);
      this.localphotos = imageResult;
      console.log('Calling from this method and pagenumber is'+this.pageNum);
     this.addContactToList(imageResult, lenOfAllImg);
   //  this.leng = true;

})
.catch((error) => {
    this.error = error;
    this.showDataLoading = false;
    console.log('Error Call and here is the Error is 1529'+this.error);
});

 //this.localphotos = event.detail.records;
 //this.addContactToList(event.detail.records);

}

// async downloadAllImages() {
//     this.photoval.forEach(async (imageData) => {
//         const imageUrl = await getImageUrl({ versionId: imageData.versionID });
//         const response = await fetch(imageUrl);
//         const blob = await response.blob();

//         const link = document.createElement('a');
//         const url = window.URL.createObjectURL(blob);
//         link.href = url;
//         link.download = `${imageData.docTitle}.${imageData.imageType}`;
//         link.style.display = 'none';

//         document.body.appendChild(link);
//         link.click();
//         document.body.removeChild(link);
//         window.URL.revokeObjectURL(url);
//     });
// }
downloadAllImages() {
    this.photoval.forEach(imageData => {
        getImage({ versionId: imageData.versionID })
            .then((blob) => {
                this.downloadImage(blob, imageData.docTitle, imageData.imageType);
            })
            .catch((error) => {
                console.error('Error downloading image:', error);
            });
    });
}
downloadImage(blob, docTitle, imageType) {
    const link = document.createElement('a');
    const downloadUrl = window.URL.createObjectURL(blob);
    link.href = downloadUrl;
    link.download = `${docTitle}.${imageType}`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(downloadUrl);
}

handleClearFilter(){
    // console.log('this.mytabset '+JSON.stringify(this.mytabset));
    // console.log('this.mytemp '+JSON.stringify(this.mytemp));
    // this.handleFieldFilterActivetab();
    console.log(' this.retailTabBl :: '+this.retailTabBl);
    this.mytabset = [...this.mytabset.map(item => {
        this.template.querySelector('c-multi-pick-list-filter').clearReatilData();

        // this.template.querySelector('c-multi-pick-list-filter').onRefreshClick();
        let helptext;
        if (item.labeltype === 'Search by Door Owner') {
            helptext = 'Please enter at least 3 characters. References active Account Owners based on role.';
        } else if (item.labeltype === 'Search by Account KAM') {
            helptext = 'Please enter at least 3 characters. References active Ultimate Parent Account owners based on role.';
        }else if(item.labeltype === 'Search by Ultimate Parent Account'){
            helptext = 'Please enter at least 3 characters.';
        }
        return {
            ...item,
            iconBl:item.labeltype === 'Search By Account Id' ? false : true,
            helpText:helptext,
            tooltip: item.labeltype === 'Search By Account Id' ? true : false,
            tempofieldval: [] 
        };    
    })];
    this.mytabsetvalues = this.mytabset;
    console.log('this.mytemp '+JSON.stringify(this.mytemp));
    if(this.mytemp.length>0){
        this.mytemp = this.mytemp.filter(item => !item.objectapiname.includes("Retail Theater"));
        this.handlesenddata();
    }
    this.retailClear = true;
    this.retailTabBl = true;
    // this.handleRefreshFilter();
    //[{"objectapiname":["Retail Theater"],"fieldapiname":["Device_Kit_Silver__c"],"fieldType":["multiple"],"selectedvalues":["In Stock"]}]
    // console.log('this.mytabset '+JSON.stringify(this.mytabset));
}



}