/**
* Company     : Adobe Systems Inc.
* Description : Test class to validate the functionality of the AdobeGlobalServiceHandler.
* History     : 
*  Refer GIT for history
*/
@isTest
private class A_L_ExceptionHandler_Test {
	@testSetup
    static void  createTestdata() { 
        CommonTestDataFactory.deActivateTriggerHandlers(new Set<String>{
            'OpportunityLineItemHandler',
            'OpportunityHandler',
            'AccountHandler',
            'AdobeSalesTeamHandler'
        });
        ISO_Country_Code__c oIsoCont = UnitTestHelper.getISOCountryCodeInstance();
        insert oIsoCont;
        
        Map<String, Id> mapOpportunityRecordTypesId = new Map<String, Id>();
        for(RecordType rt : [Select Id, Name, SObjectType from RecordType where SobjectType = 'Opportunity' AND name = 'Adobe Internal Opportunity' order by name asc]) {
            mapOpportunityRecordTypesId.put(rt.Name, Rt.Id);
        }
        
        ID stdPriceBookID = Test.getStandardPricebookId();
        
        //Create Mock Account
        Account objAct = UnitTestHelper.getAccountInstance();
        insert objAct;

        //Create Mock Opportunity
        Opportunity objOpp1 = UnitTestHelper.getOpportunityInstance(objAct.id);
        objOpp1.RecordTypeId = mapOpportunityRecordTypesId.get('Adobe Internal Opportunity');
        objOpp1.Pricebook2Id= stdPriceBookID ;
        objOpp1.StageName = '02 - Prospect';
        insert objOpp1; 
        
        //Create Adobe Sales Team
        Adobe_Sales_Team__c ast1 = new Adobe_Sales_Team__c();
        ast1.Adobe_Territory_Member__c = UnitTestHelper.getATMInsatnces(1, new List<User> {UnitTestHelper.getUserInstance()}, new List<Account> {objAct}).get(0).Id;
        ast1.Sales_Team_Member__c = userInfo.getUserId();
        ast1.Opportunity__c = objOpp1.Id;
        insert ast1;

        //Create Mock A_L_Exception record        
        A_L_Exception__c alexp1 = new A_L_Exception__c();
        alexp1.Opportunity__c = objOpp1.Id;
        alexp1.A_L_Package__c = 'AEM';
        alexp1.Status__c = 'Exception Requested';
        insert alexp1;
        
    }
	@isTest static void testALApprovalMail() {
		List<A_L_Exception__c> listALExcp = [select Id from A_L_Exception__c];
		listALExcp.get(0).Status__c = 'Exception Approved';
		update listALExcp;
	}
	
}