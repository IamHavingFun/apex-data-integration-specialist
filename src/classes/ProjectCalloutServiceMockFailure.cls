@isTest
global class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest request) {
		Account acct = DataFactory.buildAccount(0);
		// Create a fake response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setBody('FAIL');
		response.setStatusCode(500);
		return response;
	}
}