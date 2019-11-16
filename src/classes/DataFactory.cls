public class DataFactory {
    public static Vehicle__c buildVehicle(Integer i) {
        Vehicle__c vehicle = new Vehicle__c(
            Name = 'TEST ' + i
        );
        return vehicle;
    }
    
    public static Case buildCase(Id vehicleId) {
        Case maintenanceRequest = new Case(
            Status = 'New',
            Origin = 'Web',
            Type = 'Routine Maintenance',
            Vehicle__c = vehicleId
        );
        return maintenanceRequest;
    }

    public static Account buildAccount(Integer i) {
        Account account = new Account(
            Name = 'TEST ' + i
        );
        return account;
    }

    public static Opportunity buildOpportunity(Integer i, Account acct) {
        Opportunity opportunity = new Opportunity(
            Name = 'TEST ' + i,
            Account = acct,
            CloseDate = System.today(),
            StageName = 'Closed Won',
            Amount = 10000.00
        );
        return opportunity;
    }

    public static ServiceTokens__c buildTokenCustomSetting() {
        ServiceTokens__c serviceToken = new ServiceTokens__c(
            Name = 'Token',
            Token__c = 'Token'
        );
        return serviceToken;
    }

    public static Project__c buildProject(Id oppId) {
        Project__c project = new Project__c(
            Name = 'TEST',
            ProjectRef__c = '123',
            Opportunity__c = oppId,
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            Billable_Amount__c = 10000,
            Status__c = 'Billable'
        );

        return project;
    }

    public static ServiceCredentials__c buildCredentialSetting() {
        ServiceCredentials__c credentials = new ServiceCredentials__c(
            Name = 'Credentials',
            Username__c = 'TEST',
            Password__c = 'TEST'
        );

        return credentials;
    }
}