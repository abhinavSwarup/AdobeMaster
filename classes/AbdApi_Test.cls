/**
 * @Company     : Adobe Systems Inc.
 * @Description :
 * ****************************************************************************************
 * This class provides the test for the OpportunityPageActionHandler
 * ****************************************************************************************
 * @History     :  Refer to GIT Repository: https://git.corp.adobe.com/SFDC/SfDev
 */
@isTest (SeeAllData = true)
private class Abdapi_Test {
     /**
     * @Description Tests the Abdapi subclass and the processPageAction method.
     *
     * @Return void
     */
    @isTest static void testAbdapiPositive() {

        Test.startTest();

            Map<String, String> mapParameters = new Map<String, String>();

            User usr=UnitTestHelper.getUserInstance();
            System.RunAs(new User(Id = Userinfo.getUserId())) {
                insert usr;
            }
            Opportunity newOpp = [select Id  from Opportunity limit 1];
            Account newAcct = [select Id  from Account limit 1];

            mapParameters.put('Id', newOpp.Id);
            mapParameters.put('Account_Id', newAcct.Id);
            mapParameters.put('ButtonValue', '1');

            Abdapi.OrderCreate HendrixCreateOrder = new Abdapi.OrderCreate();
            HendrixCreateOrder.processPageAction(mapParameters);

        Test.stopTest();
           
    }

    @isTest static void testAbdapinegative() {

        Test.startTest();

            Map<String, String> mapParameters = new Map<String, String>();

            User usr=UnitTestHelper.getUserInstance();
            System.RunAs(new User(Id = Userinfo.getUserId())) {
                insert usr;
            }
            Opportunity newOpp = [select Id  from Opportunity limit 1];
            Account newAcct = [select Id  from Account limit 1];

            mapParameters.put('Id', newOpp.Id);
            mapParameters.put('Account_Id', newAcct.Id);
            mapParameters.put('ButtonValue', '0');

            Abdapi.OrderCreate HendrixCreateOrder = new Abdapi.OrderCreate();
          try {
            HendrixCreateOrder.processPageAction(mapParameters);
              } catch (exception ex) {
            System.debug(LoggingLevel.ERROR, 'processPageAction throw the error: ' + ex.getMessage());
            }
        Test.stopTest();
           
    }
    @isTest static void testAbdapinullcase() {

        Test.startTest();

            Map<String, String> mapParameters = new Map<String, String>();

            User usr=UnitTestHelper.getUserInstance();
            System.RunAs(new User(Id = Userinfo.getUserId())) {
                insert usr;
            }

            mapParameters.put('Id', null );
            mapParameters.put('Account_Id', null );
            mapParameters.put('ButtonValue', null );
            Abdapi.OrderCreate HendrixCreateOrder = new Abdapi.OrderCreate();
          try {
            HendrixCreateOrder.processPageAction(mapParameters);
              } catch (exception ex) {
            System.debug(LoggingLevel.ERROR, 'processPageAction throw the error: ' + ex.getMessage());
            }
        Test.stopTest();
           
    }
}