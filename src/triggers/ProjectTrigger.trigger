trigger ProjectTrigger on Project__c (after update) {
    BillingCalloutService.callBillingService(Trigger.new);
}