@RestResource(urlMapping='/project')
global with sharing class ProjectRESTService {
    //Implement service logic here
    @HttpPost
    global static String postProjectData(String projectRef, 
                                        String projectName, 
                                        String opportunityId, 
                                        Date startDate, 
                                        Date endDate, 
                                        Double amount, 
                                        String status){
        // Create a savepoint 
        Savepoint sp = Database.setSavepoint();

        String result;

        try {            
            Project__c thisProject = new Project__c();
            thisProject.ProjectRef__c = projectRef;
            thisProject.Name = projectName;
            thisProject.Opportunity__c = opportunityId;
            thisProject.Start_Date__c = startDate;
            thisProject.End_Date__c = endDate;
            thisProject.Billable_Amount__c = amount;
            thisProject.Status__c = status;
    
            upsert thisProject;
    
            Opportunity opp = new Opportunity();
            opp.Id = opportunityId;
            opp.DeliveryInstallationStatus__c = 'In progress';
            update opp;

            result = 'OK';

        } catch (Exception ex) {
            Database.rollback(sp);
            result = ex.getMessage();
        }        

        return result;
    }
}