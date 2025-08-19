trigger AttachmentTrigger on Attachment (after insert) {
    USPSShipmentAttachmentHandler.attachToCase(trigger.New);
}