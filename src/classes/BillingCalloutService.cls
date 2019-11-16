public class BillingCalloutService {
    
    public static void callBillingService(List<Project__c> projectList) {
        //Handle bulk operation
        Set<Id> projectSet = new Set<Id>();
        for(Project__c project : [SELECT Status__c, ProjectRef__c, Billable_Amount__c FROM Project__c WHERE Id IN : projectList]) {
            if(project.Status__c == 'Billable' && project.ProjectRef__c != NULL && project.Billable_Amount__c != NULL) {
                projectSet.add(project.Id);
            }
            else {
                return;
            }
        }
        callout(projectSet);
    }

    @future(callout=true)
    public static void callout(Set<Id> projectIds) {
        ServiceCredentials__c credentials = ServiceCredentials__c.getValues('Credentials');

        Map<Id, String> projectStatusMap = new Map<Id, String>();
        List<Project__c> projectList = new List<Project__c>([SELECT Id, ProjectRef__c,  Billable_Amount__c FROM Project__c WHERE Id IN : projectIds]);
        for(Project__c project : projectList) {

            //Instantiate project and pass in necessary parameters
            BillingServiceProxy.project soapProject = new BillingServiceProxy.project();
            soapProject.username = credentials.Username__c;
            soapProject.password = credentials.Password__c;
            soapProject.projectid = project.ProjectRef__c;
            soapProject.billAmount = project.Billable_Amount__c;

            //Get send project and get response
            BillingServiceProxy.InvoicesPortSoap11 soapPort = new BillingServiceProxy.InvoicesPortSoap11();
            String response = soapPort.billProject(soapProject);
            projectStatusMap.put(project.Id, response);
        }

        Set<Id> projectIdSet = new Set<Id>();
        //Loop through map to update Projects with status of 'OK'
        for(Id projectId : projectStatusMap.keySet()) {
            if(projectStatusMap.get(projectId) == 'OK') {
                projectIdSet.add(projectId);
            }
        }

        if(!projectIdSet.isEmpty()) {
            List<Project__c> projectsToUpdate = new List<Project__c>();
            for(Project__c project : [SELECT Id, Status__c FROM Project__c WHERE Id IN : projectIdSet]) {
                project.Status__c = 'Billed';
                projectsToUpdate.add(project);
            }

            update projectsToUpdate;
        }
    }
}