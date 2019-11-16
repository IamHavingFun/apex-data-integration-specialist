@isTest
private class ProjectRESTServiceTest {
	@TestSetup
	static void makeData(){
		Account acct = DataFactory.buildAccount(0);
		insert acct;

		Opportunity opp = DataFactory.buildOpportunity(0, acct);
		insert opp;
	}

	@isTest static void testPOSTSuccess() {
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		String response = ProjectRESTService.postProjectData(null, null, String.valueOf(opp.Id), null, null, null, null);
		Opportunity updatedOpp = [SELECT DeliveryInstallationStatus__c FROM Opportunity LIMIT 1];
		System.assertEquals('OK', response);
		System.assertEquals('In progress', updatedOpp.DeliveryInstallationStatus__c);
	}     

	@isTest static void testPOSTFailure() {
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		String response = ProjectRESTService.postProjectData(null, null, null, null, null, null, null);
		Opportunity updatedOpp = [SELECT DeliveryInstallationStatus__c FROM Opportunity LIMIT 1];
		System.assertNotEquals('OK', response);
		System.assertNotEquals('In progress', updatedOpp.DeliveryInstallationStatus__c);
	}    
}