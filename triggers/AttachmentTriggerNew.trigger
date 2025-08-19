trigger AttachmentTriggerNew on ContentDocumentLink (before insert) {
AttachmentTriggerHandlerNew.AttachmentDataHandler(trigger.new);
}