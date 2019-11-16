public class ProjectCalloutService {
    //Wrap opportunity object for request body
    public class Opp {
        public String opportunityId;
        public String opportunityName;
        public String accountName;
        public String closeDate;
        public Decimal amount;
        
        public Opp( 
            String oppId, 
            String oppName, 
            String oppAcctName,
            String oppCloseDate, 
            Decimal oppAmount) {
                this.opportunityId = oppId;
                this.opportunityName = oppName;
                this.accountName = oppAcctName;
                this.closeDate = oppCloseDate;
                this.amount = oppAmount;
        }
    }

    @InvocableMethod(label='POST Opportunity')
	public static void PostOpportunityToPMS(List<Id> oppIdList){
        //Gather relevant opportunities
        List<Opportunity> oppList = new List<Opportunity>([
            SELECT 
            	Id, 
            	Name, 
            	Account.Name, 
            	CloseDate, 
            	Amount
        	FROM 
        		Opportunity
        	WHERE Id IN : oppIdList]);
        
        //Enqueue job
        QueueablePMSCall oppJob = new QueueablePMSCall(oppList);
        System.enqueueJob(oppJob);
    }

    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts {
        List<Opportunity> oppsToPost = new List<Opportunity>();
        public QueueablePMSCall(List<Opportunity> oppsToPost) {
            this.oppsToPost = oppsToPost;
        }

        public void execute(QueueableContext context) {
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for(Opportunity opp : oppsToPost) {
                //Check callout status and update opportunities appropriately
                try {
                    if(callout(opp).getStatusCode() == 201) {
                        opp.StageName = 'Submitted Project';
                        oppsToUpdate.add(opp);
                    }
                    else {
                        opp.StageName = 'Resubmit Project';
                        oppsToUpdate.add(opp);
                    }
                    update oppsToUpdate;
                } catch(System.CalloutException e) {
                    System.debug(e.getMessage());
                }
            }
        }
    }

    public static HttpResponse callout(Opportunity opp) {
        //Get service token
        ServiceTokens__c serviceToken = ServiceTokens__c.getvalues('Token');
		Opportunity oppToPost = [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity WHERE Id =: opp.Id];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ProjectService');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Token', serviceToken.Token__c);
        request.setBody(JSON.serialize(
            new Opp(
                oppToPost.Id, 
                oppToPost.Name, 
                oppToPost.Account.Name, 
                String.valueOf(oppToPost.CloseDate),
                oppToPost.Amount)
        ));
        HttpResponse response = http.send(request);

        return response;
    }
}