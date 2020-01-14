/**
 * @Company     : Adobe Systems Inc.
 * @Description :
 * ****************************************************************************************
 * Trigger handler for Adobe Global Services object.
 * ****************************************************************************************
 * @History     :  Refer to GIT Repository: https://git.corp.adobe.com/SFDC/SfDev
 */

public with sharing class A_L_ExceptionHandler extends ObjectHandler {
	
	List<A_L_Exception__c> listALExp;
	private static Id orgWideEmailId {get; private set;}
	private static final String ADOBE_QUOTA_USER_PROFILE = 'Adobe Quota User';
    private static final String OPEN_USER = 'Open';
    private static final String GHOST_USER = 'Ghost';

	// ---------------------------------------------------------------------------------------------------------
	//  Inner Classes
	// ---------------------------------------------------------------------------------------------------------

    /********************************************************************************************************
    // Name        : Constructor
    // Description : class which is used to allow the ObjectHandler to dynamically create the target class
    // Assumptions :
    *********************************************************************************************************/
    public class Constructor implements ObjectHandler.IConstructable {
        public ObjectHandler construct(List<SObject> sObjectList) {
            return new A_L_ExceptionHandler(sObjectList);
        }
    }

	// --------------------------------------------------------------------------------------------------------
	//  Public Methods
	// --------------------------------------------------------------------------------------------------------
    /*********************************************************************************************************
    // Name        : AdobeGlobalServiceHandler
    // Description : Class Constructor
    // Assumptions :
    **********************************************************************************************************/
    public A_L_ExceptionHandler (List<A_L_Exception__c> sObjectList) {
        // Initializes the ObjectHandler
        super(sObjectList);
        listALExp = sObjectList;

    }

	public static void onAfterUpdate(Map<Id,A_L_Exception__c> oldALExp, Map<Id,A_L_Exception__c> newALExp) {
    	
    	for(A_L_Exception__c tempALExp : oldALExp.values()) {
    		if(tempALExp.Status__c=='Exception Requested' && newALExp.get(tempALExp.Id).Status__c=='Exception Approved'){
    			sendEmailNotification(newALExp.get(tempALExp.Id).Opportunity__c, tempALExp.Id, tempALExp.Opportunity_DR_Reg_Id__c);
    		}
    	}

    	orgWideEmailId = A_L_ExceptionQueryHandler.retrieveOrgWideEmailId();
    }

    private static void sendEmailNotification(Id oppRecId, Id tempALExpId, String oppDRId) {
    	//Retrieving AST members
    	List<Adobe_Sales_Team__c> adobeSalesTeamMembers = A_L_ExceptionQueryHandler.retrieveASTMembers(oppRecId);
    	System.debug(adobeSalesTeamMembers);
		//Setting Mail recipients
		List<String> toAddresses = new List<String>();
		if(adobeSalesTeamMembers != null && adobeSalesTeamMembers.size()>0){
	    	for(Adobe_Sales_Team__c tempAST : adobeSalesTeamMembers){
	    		if(tempAST !=null
	    			&& tempAST.Sales_Team_Member__r.FullName__c != null 
	    			&& tempAST.Sales_Team_Member__r != null 
	    			&& tempAST.Sales_Team_Member__r.Email != ''
		            && !tempAST.Sales_Team_Member__r.FullName__c.containsIgnoreCase(GHOST_USER) 
		            && !tempAST.Sales_Team_Member__r.FullName__c.containsIgnoreCase(OPEN_USER) 
		            && tempAST.Sales_Team_Member__r.profile.name != ADOBE_QUOTA_USER_PROFILE)
	            {
		        	toAddresses.add(tempAST.Sales_Team_Member__r.Email);
		      	}
	    	}
		}
		//Setting Email Instance
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddresses);
		mail.setOrgWideEmailAddressId(orgWideEmailId);
		mail.saveAsActivity = false;
		mail.setSubject('A&L Exception Approved Confirmation for '+oppDRId);
		mail.setTreatBodiesAsTemplate(true);

		//Setting HTML body
		String htmlBody = Label.A_L_Exception_approved_mail;
		htmlBody = htmlBody.replace('{!A_L_Exception__c.Opportunity__r.Deal_Registration_Id__c}', oppDRId);
		mail.setHtmlBody(htmlBody);

		try{
	    	List<Messaging.SingleEmailMessage> listMessages = new List<Messaging.SingleEmailMessage>();
	    	listMessages.add(mail);
	    	if(!Test.isRunningTest()){
	      		Messaging.sendEmail(listMessages);
	      	}
	    }catch(Exception e) {
	    	System.debug(LoggingLevel.INFO, 'Email delivery failure with error: ' + e.getMessage());
	    }
    }

}