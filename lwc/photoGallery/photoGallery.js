import { LightningElement,api, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import photoimage from '@salesforce/resourceUrl/photoimage';
import photochatter from '@salesforce/resourceUrl/PhotoChatter';
import jQuery3 from '@salesforce/resourceUrl/jQuery3';
import photogallery from '@salesforce/resourceUrl/photogallery';
//import disco__lightgallery from '@salesforce/resourceUrl/disco__lightgallery';
//import disco__jquerymodal from '@salesforce/resourceUrl/disco__jquerymodal';
import photoGalleryHeader from '@salesforce/label/c.PB_Photo_Gallery';

export default class PhotoGallery extends LightningElement {

img_icon=  photochatter;
@api photos = [];
@track localphotos = [];
@track leng = false;
@track teamon = false;
photoval = [];
chartjsInitialized = false;
@track isPhotoAvailable = false;
@track photoSpinner = false;

label = {
    photoGalleryHeader
};

@api addContactToList(strname){

    // const objChild = this.template.querySelector('c-photo-pagination');
   //  objChild.setRecordsToDisplay();

    
  //  $(this.template.querySelector('.gallery-scroll-view')).remove();
  $(this.template.querySelector('.gallery-scroll-view')).html('');
  
    console.log('Value of image is::::'+this.img_icon);
   // this.photoSpinner =  true;
    console.log('received value is' + strname);
    this.photoval = strname;
    if(this.photoval !== ''){
        this.isPhotoAvailable = true;
    }
    console.log('Enteredinto Child method and value is'+ this.photoval);
    console.log("This time inside CHILD METHOD AND CALLING DATA FORCEFULLKY");
            console.log("me inside the than modifewd after rerender");
            $(this.template.querySelector('.gallery-scroll-view')).html('');

            // $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
            //     thumbnail: true,
            //     allowMediaOverlap: true

            // });

            console.log("Applied gallery");

         

            this.photoval.forEach((photo) => {
console.log("me inside the for each");
const mytlo = photo.allFieldValues[0];
const myseclo = JSON.stringify(mytlo);
console.log('My FINAL JSON DATA TRANSFER FIRST'+ myseclo);
let mylo = {"Name":"7-ELEVEN RIS 23837","State":null,"Start Date":null,"Sales Region":"West","Account Segment":"TM Uncovered","Bans":"Menthol Ban;Category Ban;Potency Ban - 0.77%;Potency Ban - 1.5%","City":null,"Sales Division":"NorCal","Type":"National Chain Retailer","Ultimate Parent Owner":"00570000003gXRqAAM","Parent Account":"0017X00000iBU8TQAW","Account Service By":null,"Account Owner":"0051O00000D7qyEQAR"};
                const photoElementHTML =
                    `<div class="photo-eleme" data-mydynamic='${myseclo}' data-myversion = "${photo.versionID}"  data-src="/sfc/servlet.shepherd/version/download/${photo.versionID}">
                    <img src="/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${photo.versionID}"/>	
                </div> `;
                $(this.template.querySelector('.gallery-scroll-view')).append(photoElementHTML);

            });
            try{
               // $(this.template.querySelector('.gallery-scroll-view')).data('lightGallery').destroy(true);
            }
            catch (e) {}
    
            // $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
            //     thumbnail:true,
            //     enableDrag:false,
            //     allowMediaOverlap: true
            // });
           
            
        
            $(this.template.querySelector('.gallery-scroll-view')).on('onAfterSlide.lg', function(event, prevIndex, index, fromTouch, fromThumb){
            });

            this.teamon = !this.teamon;
         
            console.log('VALUE OF FORCEFUL TRACK IS'+this.teamon);

   // const objChild = this.template.querySelector('c-photo-pagination');
   // objChild.setRecordsToDisplay();
           
}

    renderedCallback() {
        this.img_icon=  photochatter;
        console.log('ENTERED INTO METHOD OF RENDER PHOTO GALLERY');

        if(this.photos !== null && this.photos.length > 0){

            this.leng =  true;
        }

       if (this.chartjsInitialized) {
            console.log("Again called rerender of imagegallery");
            console.log("me inside the than modifewd after rerender");
            console.log('My JSON value which i received from parent is:::::'+ JSON.stringify(this.photos));
            $(this.template.querySelector('.gallery-scroll-view')).empty();

            // $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
            //     thumbnail: true,
            //     allowMediaOverlap: true,
            // });

            console.log("Applied gallery");

         

            this.localphotos.forEach((photo) => {
console.log("me inside the for each");
const mytlo = photo.allFieldValues[0];
const myseclo = JSON.stringify(mytlo);
console.log('My FINAL JSON DATA TRANSFER SECOND'+ myseclo);
let mylo = {"Name":"7-ELEVEN RIS 23837","State":null,"Start Date":null,"Sales Region":"West","Account Segment":"TM Uncovered","Bans":"Menthol Ban;Category Ban;Potency Ban - 0.77%;Potency Ban - 1.5%","City":null,"Sales Division":"NorCal","Type":"National Chain Retailer","Ultimate Parent Owner":"00570000003gXRqAAM","Parent Account":"0017X00000iBU8TQAW","Account Service By":null,"Account Owner":"0051O00000D7qyEQAR"};
                const photoElementHTML =
                    `<div class="photo-eleme"  data-mydynamic='${myseclo}' data-myversion = "${photo.versionID}" data-src="/sfc/servlet.shepherd/version/download/${photo.versionID}">
                    <img src="/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${photo.versionID}"/>	
                </div> `;
                $(this.template.querySelector('.gallery-scroll-view')).append(photoElementHTML);
                this.yuvraj();

            })
            try{
                //$(this.template.querySelector('.gallery-scroll-view')).data('lightGallery').destroy(true);
            }
            catch (e) {}
    
            // $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
            //     thumbnail:true,
            //     enableDrag:false,
            //     allowMediaOverlap: true
            // });
            
            $(this.template.querySelector('.gallery-scroll-view')).on('onAfterSlide.lg', function(event, prevIndex, index, fromTouch, fromThumb){
            });

              //const objChild = this.template.querySelector('c-photo-pagination');
             // objChild.setRecordsToDisplay();

            return;

        }
        this.chartjsInitialized = true;

        Promise.all([
            loadScript(this, jQuery3)
            //loadScript(this, disco__jquerymodal + '/jquerymodal/jquery.modal.js'),
            // loadScript(this, disco__lightgallery + '/lightgallery/js/lightgallery-all.js'),
            // loadStyle(this, disco__lightgallery + '/lightgallery/css/lightgallery.css'),
            // loadScript(this, disco__lightgallery + '/lightgallery/js/lg-zoom.js'),
            // loadStyle(this, photoimage),
            // loadStyle(this, photogallery),
        ]).then(() => {
            console.log("me inside the than modifewd after rerender");
            $(this.template.querySelector('.gallery-scroll-view')).html('');

            // $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
            //     thumbnail: true,
            //     allowMediaOverlap: true,
            // });

            console.log("Applied gallery");

         

            this.localphotos.forEach((photo) => {
console.log("me inside the for each");
         const mytlo = photo.allFieldValues[0];
        const myseclo = JSON.stringify(mytlo);
        console.log('My FINAL JSON DATA TRANSFER THIRD'+ myseclo);
        let mylo = {"Name":"7-ELEVEN RIS 23837","State":null,"Start Date":null,"Sales Region":"West","Account Segment":"TM Uncovered","Bans":"Menthol Ban;Category Ban;Potency Ban - 0.77%;Potency Ban - 1.5%","City":null,"Sales Division":"NorCal","Type":"National Chain Retailer","Ultimate Parent Owner":"00570000003gXRqAAM","Parent Account":"0017X00000iBU8TQAW","Account Service By":null,"Account Owner":"0051O00000D7qyEQAR"};
                const photoElementHTML =
                    `<div class="photo-eleme" data-mydynamic='${myseclo}' data-src="/sfc/servlet.shepherd/version/download/${photo.versionID}">
                    <img src="/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=${photo.versionID}"/>	
                </div> `;
                $(this.template.querySelector('.gallery-scroll-view')).append(photoElementHTML);
               
                this.yuvraj();
            })
            try{
                //$(this.template.querySelector('.gallery-scroll-view')).data('lightGallery').destroy(true);
            }
            catch (e) {}
    
            // $(this.template.querySelector('.gallery-scroll-view')).lightGallery({
            //     thumbnail:true,
            //     enableDrag:false,
            //     allowMediaOverlap: true,
            // });
            
           


        })

            .catch(error => {
                console.log('Failed to load the JQuery : ' + error);
            });
    }
    yuvraj()
   {
        $(this.template.querySelector('.gallery-scroll-view')).on('onAfterSlide.lg', function(event, index){
  
    $('.lg-img-wrap').find('.slds-scope').remove();
    const thisPhotoElement = $('.photo-eleme').eq(index);
    console.log("hi me",thisPhotoElement);
   // const accountName = thisPhotoElement.data('src');
   const accountName =  thisPhotoElement.data(event.name);
   console.log('My Photo Glalery debug is'+ JSON.stringify(accountName));
    //const myname=Object.values(accountName.mydynamic);
    const myname= thisPhotoElement.data('mydynamic'); 
  //const myname= $('#photo-eleme').data('key').key
  //$('#myElement').data('key').key;
   //const myname=thisPhotoElement.data('mydynamic');
   console.log('MY JSON FINAL SPRINT4VALUE IS UPDATED new new new old old:::'+ JSON.stringify(myname));
   console.log(myname);
   console.log(JSON.parse(JSON.stringify(myname)));
  // let finalo = myname["Account Segment"];
  let finalo = myname;



    console.log("hi me final json input for photo gallery new value demo demos dona done ", JSON.stringify(finalo));
    let mydiv = ``;
    for(let key in myname) {
      let goplo = '';
      goplo = myname[key];
      let a = `${myname[key] === null ? '' :myname[key]}`;
      let mylop=  `<h1 class="slds-grid  slds-p-left_large slds-m-bottom_medium">
      <b class="slds-badge slds-p-horizontal_small" style="border-radius:10px;color:black"> ${key} </b>  <p class="slds-p-left_medium "> ${a}</p>
       </h1>`;
        mydiv += mylop; 
    }
    console.log('Final value of div elements are::::'+ mydiv);
    console.log('Final value of Image is::::'+ this.img_icon);
    $('.lg-image').after(`
    <div class="slds-scope mybox" >
       
        <div style="position:static;position:absolute;right:100px;top:110px;width:400px;height:550px;">
        <div  style="background:rgba(190, 190, 187, 0.987);color:black;padding:15px;border-radius:5px;"><b style="font-size:25px;">Photo Details</b></div>
             </div>  
     <div style="background-color:white;border-radius:10px;width:400px;height:550px;position:absolute;right:100px;top:170px;color:black;border-bottom:8px solid rgba(131, 130, 131, 0.993);">
   <div class="slds-grid slds-grid_align-end">
     <img src="/resource/1630415754000/PhotoChatter" onclick=${this.mynewmethod}/></div>
     <div class="api slds-col_bump-right slds-p-top_xx-large">
      
     ${mydiv}
     
    </div>

      </div>
         </div>`
);

});

}

handlePagination(event){
    console.log('Pagination action handled from child component', JSON.stringify(event.detail.records));
    this.localphotos = event.detail.records;
    this.addContactToList(event.detail.records);
}

myFilterMethod(myva){
    console.log('My received value from mehtod is ::'+ JSON.stringify(myva));
    return (myva === null? "" : myva);
}

mynewmethod(){
 console.log('Method has been clicked from image src :::');

}



}