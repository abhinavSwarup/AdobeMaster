/**
 * Company     : Adobe Inc.
 * Description : 
 * ****************************************************************************************
 * 
 * ****************************************************************************************
 * @History    : https://git.corp.adobe.com/SFDCGitReviews/DeploymentDM
 */ 
 @isTest
 private with sharing class AcccountReportTriggerHandler_Test {
  
    @isTest
    static void AccountReportUnitTest()
    {
         Database.insert(new LIR_Notification_OPG__c(Name = 'OPG1', OPG__c = 'ACROBAT,SIGN,CREATIVE,COLDFUSION,PPBU'));         
         Database.insert(new ISO_Country_Code__c(Country_Name__c = 'UNITED STATES', Name = 'US'));

         Account account = Unittesthelper.getAccountInstance();
         Database.SaveResult sr = Database.insert(account);

         Adobe_Territory_Member__c atm = new Adobe_Territory_Member__c(
            Account__c = sr.getId(),
            User_ID__c = UserInfo.getUserId(),
            Territory_Team_Member__c = 'Account Manager',
            Account_Manager_Type__c = 'TAM',
            Outlook_Product_Group__c = 'SIGN;CREATIVE'
         );
         Database.insert(atm);
        
         Account_Reports__c accRep = new Account_Reports__c(Account__c = sr.getId(), Chatter_Text__c = 'Test Chat', Chatter_Post__c = true);
         insert accRep;
        
         Account_Reports__c qaccRep = [Select Id from  Account_Reports__c where ID=:accRep.Id];
         System.assertEquals(accRep.Id, qaccRep.Id);
         
         accRep.Chatter_Text__c='Test Chat';
         update accRep;
         
         delete accRep;
         
    }
 }