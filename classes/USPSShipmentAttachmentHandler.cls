public class USPSShipmentAttachmentHandler {
    public static void attachToCase(List<Attachment> triggerNew){
        List<ContentVersion> files = new List<ContentVersion>();
        Map<Id,List<Attachment>> attachmentsMap = filter(triggerNew);
        for(zkusps__Shipment__c s : [
            SELECT Id,Case__c,Case__r.CaseNumber
            FROM zkusps__Shipment__c
            WHERE Case__c != NULL AND Id IN:attachmentsMap.keySet()
        ]){
            for(Attachment att : attachmentsMap.get(s.Id).deepclone(false,false,false)){
                ContentVersion cv = toContentVersion(att, getFileName(s.Case__r.CaseNumber, getExtention(att.Name)));
                files.add(cv);
            }
        }

        insert files;
    }

    private static Map<Id,List<Attachment>> filter(List<Attachment> attachments){
        Map<Id,List<Attachment>> filteredRecords = new Map<Id,List<Attachment>>();
        for(Attachment att : attachments){
            if(att.ParentId.getSobjectType() == zkusps__Shipment__c.sObjectType){
                if(filteredRecords.get(att.ParentId) == NULL){
                    filteredRecords.put(att.ParentId,new List<Attachment>());
                }
                filteredRecords.get(att.ParentId).add(att);
            }
        }

        return filteredRecords;
    }

    private static ContentVersion toContentVersion(Attachment att, String fname){
        return new ContentVersion(
            VersionData = att.Body,
            Title = fname,
            Description = att.Description,
            PathOnClient = '/' + fname,
            FirstPublishLocationId = att.ParentId,
            SharingPrivacy = ( att.isPrivate ? 'P' : 'N' )
        );
    }

    private static String getFileName(String caseNum, String ext){
        return 'Label ' + caseNum + ' | ' + System.now().format() + (String.isBlank(ext) ? '' : '.' + ext);
    }

    private static String getExtention(String attName){
        List<String> s = attName.split('\\.');
        return s.isEmpty() ? '' : s[s.size() - 1];
    }
}