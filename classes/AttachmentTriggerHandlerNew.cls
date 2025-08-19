public without sharing class AttachmentTriggerHandlerNew {
public static void AttachmentDataHandler(List<ContentDocumentLink> contentdata){
Set<Id> LinkedEntityIds = new Set<Id>();
list<Case> casesToUpdate = new list<Case>();

for(ContentDocumentLink con:contentdata)
{
String s1 = String.valueof(con.LinkedEntityId);
if(s1.startsWith('500')) //This is unique identifier for case id
{
LinkedEntityIds.add(con.LinkedEntityId);
}

}
if(LinkedEntityIds.size()>0){
//for(Case cs:[select id,status from Case where id in :LinkedEntityIds AND Status = 'New' AND RecordType.Name = 'DK courtesy payment']){
for(Case cs:[select id,status from Case where id in :LinkedEntityIds]){
cs.status='Open';
casesToUpdate.add(cs);
}

//update casesToUpdate;
}
}

}