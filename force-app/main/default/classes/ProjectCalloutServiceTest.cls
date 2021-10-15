@isTest
private class ProjectCalloutServiceTest {
    //Implement mock callout tests here
	  @TestSetup
	  static void makeData(){
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        
        Account acct = new Account();
        acct.Name='Test Account';
        insert acct;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Super-Duper Big Deal';
        opp.Type='New Project';
        opp.AccountId = acct.id;
        opp.amount = 500;
        opp.CloseDate = date.today();
        opp.StageName = 'Closed Won';
        oppsToInsert.add(opp);
        
        insert oppsToInsert;
        
        ServiceTokens__c st = new ServiceTokens__c();
        st.Name = ProjectCalloutService.PROJECT_SERVICE_TOKEN_NAME;
        st.Token__c = 'test_token';
        insert st;
    }

    @isTest
    private static void testSuccess() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Super-Duper Big Deal'];       
        List<Id> ids = new List<Id>{opportunity.id};

        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        
        Test.startTest();
        ProjectCalloutService.PostOpportunityToPMS(ids);        
        Test.stopTest();

        opportunity = [SELECT StageName FROM Opportunity WHERE Name = 'Super-Duper Big Deal'];
        system.assertEquals('Submitted Project', opportunity.StageName);
    }

    @isTest
    private static void testFailure() {
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Name = 'Super-Duper Big Deal'];       
        List<Id> ids = new List<Id>{opportunity.id};

        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        
        Test.startTest();
        ProjectCalloutService.PostOpportunityToPMS(ids);        
        Test.stopTest();

        opportunity = [SELECT StageName FROM Opportunity WHERE Name = 'Super-Duper Big Deal'];
        system.assertEquals('Resubmit Project', opportunity.StageName);
    }
}