public class BillingCalloutService {
    //Implement business and callout logic methods here

    public static final String BILLING_SERVICE_CREDENTIALS = 'BillingServiceCredential';
    static final ServiceCredentials__c serviceCredentials = ServiceCredentials__c.getValues(BILLING_SERVICE_CREDENTIALS);    

    public static void callBillingService(List<Project__c> newProjects, Map<Id, Project__c> oldProjectsMap){
        List<Project__c> projectsToBill = new List<Project__c>();

        for (Project__c newProject : newProjects) {
            Project__c oldProject = oldProjectsMap.get(newProject.Id);  
            if(newProject.Status__c == 'Billable' && newProject.Status__c != oldProject.Status__c){
                projectsToBill.add(newProject);
            }          
        }

        if(projectsToBill.size() > 0){
            //@future methods accepting only primitives or list of primitives 
            callout(JSON.serialize(projectsToBill));
        }
    }

    @future(callout=true)
    static void callout(String projectsToBillSerialiszed){
        List<Project__c> projects = (List<Project__c>)JSON.deserialize(projectsToBillSerialiszed, List<Project__c>.class);
        List<Project__c> projectsToUpdate = new List<Project__c>();

        BillingServiceProxy.InvoicesPortSoap11 billingService = new BillingServiceProxy.InvoicesPortSoap11();

        for (Project__c project : projects) {
            BillingServiceProxy.project externalProject = new BillingServiceProxy.project();
            externalProject.billAmount = project.Billable_Amount__c;
            externalProject.projectid = project.ProjectRef__c;
            externalProject.username = serviceCredentials.Username__c;
            externalProject.password = serviceCredentials.Password__c;    
            
            String status = billingService.billProject(externalProject);       
            if(status == 'OK'){
                project.Status__c = 'Billed';
                projectsToUpdate.add(project);
            }
        }
        
        if(projectsToUpdate.size() > 0){
            update projectsToUpdate;
        }
    }
}