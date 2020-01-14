/**
 * @Company     : Adobe Systems Inc.
 * @Description :
 * ******************************************************************************************
 * Standard query handler for Adobe Global Service object.
 * ******************************************************************************************
 * @History     : Refer to GIT Repository: https://git.corp.adobe.com/SFDC/SfDev
 */
public with sharing class A_L_ExceptionQueryHandler implements QueryHandler {

   
//  -------------------------------------------------------------------------------------------------------------------
//  Constants
//  -------------------------------------------------------------------------------------------------------------------

//  -------------------------------------------------------------------------------------------------------------------

	public A_L_ExceptionQueryHandler() {
		
	}

	//  -------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc:   Implements the queryBase method of the interface.
     */
    public static void queryBase(List<SObject> listSObjects) {

    }

	//  -------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc:   Implements the queryData method of the interface.
     */
    public static void queryData(List<SObject> listSObjects) {

    }
//  -------------------------------------------------------------------------------------------------------------------
    /**
     * @Desc:   Implements the queryDataAfter method of the interface.
     */
    public static void queryDataAfter(List<SObject> listSObjects) {

    }
//  -------------------------------------------------------------------------------------------------------------------
    

    public static Id retrieveOrgWideEmailId(){
        return [select Id from OrgWideEmailAddress where Address = 'sfdcsprt@adobe.com'].get(0).Id;
    }

    public static List<Adobe_Sales_Team__c> retrieveASTMembers(Id oppRecId) {
        return  [Select (Select Sales_Team_Member__r.Name, Sales_Team_Member__r.Email,
                    Sales_Team_Member__r.FullName__c, Sales_Team_Member__r.profile.name
        			from Adobe_Sales_Team__r) ast
				from Opportunity oppt 
				where oppt.Id =: oppRecId
                ].get(0).Adobe_Sales_Team__r;
    }
    
}