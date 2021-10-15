@isTest
private class BillingCalloutServiceTest {
    //Implement mock callout tests here
    @TestSetup
    static void makeData(){
      ServiceCredentials__c sc = new ServiceCredentials__c();
      sc.Name = BillingCalloutService.BILLING_SERVICE_CREDENTIALS;
      sc.Username__c = 'test_username';
      sc.Password__c = 'test_password';
      insert sc;

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
        insert opp;

        List<Project__c> projects = new List<Project__c>();
        for (Integer i = 0; i < 100; i++) {          
          Project__c project = new Project__c();
          project.Name = 'test_project';
          project.ProjectRef__c = 'test_project_ref' + i;
          project.Billable_Amount__c = 100000;
          project.Status__c = 'Running';
          project.Opportunity__c = opp.Id;
          projects.add(project);
        }
        insert projects;       
    }

    @isTest
    static void testCallBillingServiceSuccess(){
        List<Project__c> projects = [SELECT Id, Status__c FROM Project__c WHERE Name = 'test_project'];
        for (Project__c prj : projects) {
            prj.Status__c = 'Billable';
        }

        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock());
        Test.startTest();
        update projects;
        Test.stopTest();

        projects = [SELECT Id, Status__c FROM Project__c WHERE Name = 'test_project'];
        System.assertEquals('Billed', projects[0].Status__c);
    }

    @isTest
    static void testCallBillingServiceFailure(){
        List<Project__c> projects = [SELECT Id, Status__c FROM Project__c WHERE Name = 'test_project'];
        for (Project__c prj : projects) {
            prj.Status__c = 'Billable';
        }

        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure());
        Test.startTest();
        update projects;
        Test.stopTest();

        projects = [SELECT Id, Status__c FROM Project__c WHERE Name = 'test_project'];
        System.assertEquals('Billable', projects[0].Status__c);
      
    }
}