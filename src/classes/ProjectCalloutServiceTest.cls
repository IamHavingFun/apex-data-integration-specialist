@isTest
private class ProjectCalloutServiceTest {
	//Setting up test data
	@TestSetup
	static void makeData(){
		ServiceTokens__c token = DataFactory.buildTokenCustomSetting();
		insert token;
		Account acct = DataFactory.buildAccount(0);
		insert acct;
		Opportunity opp = DataFactory.buildOpportunity(0, acct);
		insert opp;
	}

	//Testing callout response
	@isTest
	public static void testCallout() {
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
			Opportunity opp = [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity LIMIT 1];
			HttpResponse response = ProjectCalloutService.callout(opp);
		Test.stopTest();
		System.assertEquals(201, response.getStatusCode());
	}

	//Test successful POST
	@isTest
	public static void testOppSuccess() {
		List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Account.Name FROM Opportunity]);
		List<Id> oppIdList = new List<Id>();
		for(Opportunity opp : oppList) {
			oppIdList.add(opp.Id);
		}
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
			ProjectCalloutService.PostOpportunityToPMS(oppIdList);
		Test.stopTest();

		List<Opportunity> successOpps = new List<Opportunity>([SELECT Id FROM Opportunity WHERE StageName = 'Submitted Project']);
		System.assertEquals(1, successOpps.size());
	}

	//Test failed POST
	@isTest
	public static void testOppFailure() {
		List<Opportunity> oppList = new List<Opportunity>([SELECT Id FROM Opportunity]);
		List<Id> oppIdList = new List<Id>();
		for(Opportunity opp : oppList) {
			oppIdList.add(opp.Id);
		}

		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
			ProjectCalloutService.PostOpportunityToPMS(oppIdList);
		Test.stopTest();

		List<Opportunity> failedOpps = new List<Opportunity>([SELECT Id FROM Opportunity WHERE StageName = 'Resubmit Project']);
		System.assertEquals(1, failedOpps.size());
	}	
}