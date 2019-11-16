@isTest
private class BillingCalloutServiceTest {
	@TestSetup
	static void makeData(){
		Account acct = DataFactory.buildAccount(0);
		insert acct;

		Opportunity opp = DataFactory.buildOpportunity(0, acct);
		insert opp;

		Project__c project = DataFactory.buildProject(opp.Id);
		insert project;

		ServiceCredentials__c credentials = DataFactory.buildCredentialSetting();
		insert credentials;
	}

	@isTest
	static void testSuccess() {

		Test.startTest();
			Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
			BillingCalloutService.callBillingService([SELECT Id FROM Project__c]);
		Test.stopTest();

		List<Project__c> projectList = new List<Project__c>([SELECT Id FROM Project__c WHERE Status__c = 'Billed']);
		System.assertEquals(1, projectList.size());
	}

	@isTest
	static void testFailure() {
		Test.startTest();
			Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
			BillingCalloutService.callBillingService([SELECT Id FROM Project__c]);
		Test.stopTest();

		List<Project__c> projectList = new List<Project__c>([SELECT Id FROM Project__c WHERE Status__c = 'Billable']);
		System.assertEquals(1, projectList.size());
	}
}