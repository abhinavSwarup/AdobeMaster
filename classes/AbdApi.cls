/**
 * @Company     : Adobe Systems Inc.
 * @Description :
 * ***************************************************************************************************
 * This class is to represent the Common Service API for Post Sales Hendix Integration 
 * which provides attributes of Account,Opportunity and Contact
 * ***************************************************************************************************
 * @History     :
 * Refer to GIT for History
 * @Desc: Validate if Create Order should proceed and open a webpage for User to log into HENDRIX. Pass Acct, Opportunity & Contact ID's during login process.
*/
public class Abdapi {
    
    public class OrderCreate implements CommonPageActionHandler{
        public CommonTypes.PageActionResult processPageAction(Map<String,String> mapParameters) {
           System.debug(LoggingLevel.INFO, 'CreateOrder <-- processPageAction() \n mapParameters = ' + mapParameters);
            CommonTypes.PageActionResult actionResult = new CommonTypes.PageActionResult();
            GeneralException actionException = new GeneralException();
            String HendrixURL;
            Id srcOpptyId = mapParameters.get('Id');
            Id srcAcctId  = mapParameters.get('Account_Id');
            string srcButtonVal= mapParameters.get('ButtonValue');
            Async_Process_Queue__c newApqObj = new Async_Process_Queue__c();
            newApqObj.Input_Object_Id__c = srcOpptyId;
            newApqObj.Process__c = 'OpportunityPageActionHandler.HendrixCreateOrder';
            newApqObj.Input_From__c = 'OpportunityPageActionHandler';
            List<OpportunityContactRole> listContactId = new List<OpportunityContactRole>([Select Id FROM OpportunityContactRole WHERE OpportunityId =: srcOpptyId order by CreatedDate]);          
            System.debug(LoggingLevel.INFO, 'ContactId : ' + listContactId[0].Id);
            System.debug(LoggingLevel.INFO, 'Oppty_Id : ' + srcOpptyId);
            System.debug(LoggingLevel.INFO, 'AccountId : ' + srcAcctId);
            
            if(srcOpptyId == null || srcAcctId == null || srcButtonVal == null) {
                actionException.setMessage('Missing one or more parameters for Hendrix Order Creation proecess : ' + mapParameters);
                throw actionException;
            }

              if(srcButtonVal == '1') {
                System.debug(LoggingLevel.INFO, 'Logic when Entry Criteria is Met \n mapParameters = ' + mapParameters);
                //Create an Entry in APQ-ID Table
                newApqObj.Status__c = 'Started';
                TriggerControl.setTriggersInactiveAll(AsyncProcessQueueHandler.class);
                Insert newApqObj;
                Id srcAPQID = newApqObj.Id;
                if(listContactId.size() > 0) {
                    HendrixURL = 'https://hendrix-d2.corp.adobe.com/radon_java_webapp/hx5/#/sfdc?accountID=' + srcAcctId + '&contactID=' + listContactId[0].Id + '&opportunityID=' + srcOpptyId + '&apq_Id=' + srcAPQID;
                }
                System.debug(LoggingLevel.INFO, 'URLHendrix : ' + HendrixURL);

                actionresult.isSuccess = TRUE;
                actionResult.returnURL = HendrixURL;
               
            } else {
               System.debug(LoggingLevel.INFO, 'Logic when Entry Criteria is NOT Met \n mapParameters = ' + mapParameters);
                actionResult.errorMsg = System.Label.Opp_CreateOrder;
                //actionResult.errorMsg = 'The entrance criteria to create order is not satisfied. Please ensure the following criteria is met.<br/> * Contact role present on opportunity <br/> * Product is added to the opportunity <br/> * Opportunity Stage is “07- Execute to Close “ <br/> * Approval process completed (Approval Status = Approved) <br/> * Route to market is populated';
                
            }
            return actionResult;
        }

    } 
        

}
