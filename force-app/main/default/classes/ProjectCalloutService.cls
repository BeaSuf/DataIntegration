public with sharing class ProjectCalloutService {

    public static final String PROJECT_SERVICE_TOKEN_NAME = 'ProjectServiceToken';

    @InvocableMethod(callout=true 
                    label='Post Opportunity To PMS' 
                    description='Updates "New Project" typed Opportunities corresponding to the specified opportunities IDs.' 
                    category='Opportunities')
    public static void PostOpportunityToPMS(List<Id> ids){        
        if(ids.size() > 0){
            System.enqueueJob(new QueueablePMSCall(ids));         
        }
    }

    static void postToPMS(String serviceToken, Opportunity opp){
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:ProjectService');
        request.setMethod('POST');
        request.setHeader('token', serviceToken);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serialize(new CalloutInformationWrapper(opp)));
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        // Parse the JSON response
        if(response.getStatusCode() == 201 && response.getStatus() == 'OK') {
            opp.StageName = 'Submitted Project';
            System.debug('Success: ' + response.getStatus());
        } else {
            opp.StageName = 'Resubmit Project';
            System.debug('Failure: ' + response.getStatusCode() + ' ' + response.getStatus());
        }   
        
        update opp;
    }
    
    static void collectDataAndCallOut(List<Id> ids){
        Opportunity opp = [SELECT Id, Name, Account.Name, CloseDate, Amount FROM Opportunity WHERE Id = :ids[0]];  

        String serviceToken = ServiceTokens__c.getValues(PROJECT_SERVICE_TOKEN_NAME).Token__c;            
        System.debug('token' + serviceToken);  

        postToPMS(serviceToken, opp);
    }

    public class QueueablePMSCall implements Queueable, Database.AllowsCallouts{
        private List<Id> ids;        
                
        public QueueablePMSCall(List<Id> ids){
            this.ids = ids;
        }
    
        public void execute(QueueableContext qc){
            collectDataAndCallOut(ids);
        }        
    }

    public class CalloutInformationWrapper{
        string opportunityId;
        string opportunityName;
  		string accountName;
  		string closeDate;
  		Decimal amount;
        
        public CalloutInformationWrapper(Opportunity opp){
            this.opportunityId = opp.Id;
            this.opportunityName = opp.Name;
            this.accountName = opp.Account.Name;
            this.closeDate = String.valueOf(opp.CloseDate).mid(0,10);
            this.amount = opp.Amount;
        }
	}
}