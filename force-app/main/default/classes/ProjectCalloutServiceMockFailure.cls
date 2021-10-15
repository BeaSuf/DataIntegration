public class ProjectCalloutServiceMockFailure implements HttpCalloutMock{
   //Implement http mock callout failure here     
      public HTTPResponse respond(HTTPRequest request) {
         // Create a fake response
         HttpResponse response = new HttpResponse();
         response.setHeader('Content-Type', 'application/json');
         response.setStatus('Error');
         response.setStatusCode(500);
         return response; 
      } 
}