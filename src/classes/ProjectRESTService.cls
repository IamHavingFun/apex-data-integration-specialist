@RestResource(urlMapping='/project')
global with sharing class ProjectRESTService {
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, Date StartDate, Date EndDate, Double Amount, String Status) {
        Project__c project = new Project__c(
            ProjectRef__c = ProjectRef,
            Name = ProjectName,
            Opportunity__c = OpportunityId,
            Start_Date__c = StartDate,
            End_Date__c = EndDate,
            Billable_Amount__c = Amount,
            Status__c = Status
        );

        //Update Opportunity Delivery Installation Status
        List<Opportunity> oppsToUpdate = new List<Opportunity>([SELECT DeliveryInstallationStatus__c FROM Opportunity WHERE Id =: OpportunityId]);
        for(Opportunity opp : oppsToUpdate) {
            opp.DeliveryInstallationStatus__c = 'In progress';
        }

        //Creating savepoint
        Savepoint sp = Database.setSavepoint();

        try {
            update oppsToUpdate;
            upsert project;
        }catch(Exception e) {
            //Rollback database to previous state
            Database.rollback(sp);
            return e.getMessage();
        }
        
        return 'OK';
    }
}