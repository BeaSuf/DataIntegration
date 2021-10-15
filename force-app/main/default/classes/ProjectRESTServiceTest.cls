@isTest
private class ProjectRESTServiceTest {
    //Implement Apex REST service tests here
    @TestSetup
    static void makeData(){        
        Account acct = new Account();
        acct.Name='Test Account';
        insert acct;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Super-Duper Big Deal';
        opp.Type='New Project';
        opp.AccountId = acct.id;
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today();
        
        insert opp;      
    }

    @isTest
    static void testPostProjectDataSuccess(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Super-Duper Big Deal'];
        // Call the method to test
        String result = ProjectRESTService.postProjectData('123', 
                                                            'Super-Duper New Project', 
                                                            opp.id, 
                                                            Date.today(), 
                                                            Date.today().addDays(1), 
                                                            1111, 
                                                            'Running');
        // Verify results
        System.assertEquals('OK', result);

        opp = [SELECT DeliveryInstallationStatus__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('In progress', opp.DeliveryInstallationStatus__c);
    }

    @isTest
    static void testPostProjectDataFailure(){
        // Call the method to test
        String result = ProjectRESTService.postProjectData('123', 
                                                            'Super-Duper New Project', 
                                                            'fake_id', 
                                                            Date.today(), 
                                                            Date.today().addDays(1), 
                                                            1111, 
                                                            'Running');
        // Verify results
        System.assertEquals('Invalid id: fake_id', result);
    }
}