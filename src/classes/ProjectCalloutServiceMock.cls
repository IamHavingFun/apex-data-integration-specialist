@isTest
global class ProjectCalloutServiceMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest request) {
		Account acct = DataFactory.buildAccount(0);
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"opportunityId": "00641000004EKmFAAW", "opportunityName": "Super-Duper Big Deal", "accountName": "ACME Corp, Inc.", "closeDate": "2016-10-30","amount": 150000}');
        response.setStatusCode(201);
        return response;
    }
}