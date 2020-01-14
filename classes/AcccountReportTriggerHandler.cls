/**
 * Company     : Adobe Systems Incorporated
 * Description : 
 * ****************************************************************************************
 * This class is invoked when Acount Report Record is Inserted, and retrieves the ATM for the
 * appropriate Outlook Product Group as specified in the LIR OPG Notification Custon Settings
 * ****************************************************************************************
 * @History    : Refer to GIT Repository: https://git.corp.adobe.com/SFDC/SfDev
 */ 
public class AcccountReportTriggerHandler {
     public static void OnAfterInsert(List<Account_Reports__c> listNewAccountReports){
        List<ID> accountIds = new List<ID>();
        Map<ID, Set<ID>> mapAccountIdtoUserId = new Map<ID, Set<ID>>();
        KeyValueListStore__c kvlsLIRPreText = KeyValueListStore__c.getInstance('LIRReportPreChatterText');
        KeyValueListStore__c kvlsLIRPostText = KeyValueListStore__c.getInstance('LIRReportPostChatterText');    
        Map<String, LIR_Notification_OPG__c> getOPGData = LIR_Notification_OPG__c.getAll();
        Set<String> setOPGData = new Set<String>();
        for (String dataSetName : getOPGData.keySet()) {
            LIR_Notification_OPG__c lno = getOPGData.get(dataSetName);
            if (lno != null) {
                setOPGData.addAll(lno.OPG__c.split(',',0));
            }
        }
        for(Account_Reports__c accountReport : listNewAccountReports){
            accountIds.add(accountReport.Account__c);
        }
        for(Adobe_Territory_Member__c atm:[SELECT id,Outlook_Product_Group__c,User_ID__c,Account__c from Adobe_Territory_Member__c WHERE Account__c IN:accountIds]){
            Set<String> setATMOPGData = new Set<String>();
            if (atm.Outlook_Product_Group__c != null){
                setATMOPGData.addAll(atm.Outlook_Product_Group__c.split(';',0));
            }
            if (setATMOPGData.removeAll(setOPGData)) {
                if (mapAccountIdtoUserId.containsKey(atm.Account__c)) {
                    mapAccountIdtoUserId.get(atm.Account__c).add(atm.User_ID__c);
                } else {
                    Set<ID> userId = new Set<ID>();
                    userId.add(atm.User_ID__c);
                    mapAccountIdtoUserId.put(atm.Account__c, userId);
                }
            }
        }
        for (Account_Reports__c accountReport : listNewAccountReports) {
                if (accountReport.Chatter_Post__c) {
                    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();                    
                    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                    if (accountReport.Chatter_Text__c != null) {
                        textSegment.text = accountReport.Chatter_Text__c;
                    } else if(kvlsLIRPreText != null) {
                        textSegment.text = kvlsLIRPreText.Value__c; 
                    }
                    messageInput.messageSegments.add(textSegment);
                    Set<ID> setAccountIds;
                    if (accountReport.Account__c != null) {
                        setAccountIds = mapAccountIdtoUserId.get(accountReport.Account__c);
                    }
                    if (setAccountIds != null && !setAccountIds.isEmpty()) {
                        for (ID userId : setAccountIds) {
                            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                            mentionSegment.Id = userId;
                            messageInput.messageSegments.add(mentionSegment);
                        }
                    }
                    textSegment = new ConnectApi.TextSegmentInput();
                    textSegment.text = kvlsLIRPostText != null ? '. ' + accountReport.Name + ' ' + kvlsLIRPostText.Value__c : '. Static Post Custom Setting';
                    messageInput.messageSegments.add(textSegment);
                    feedItemInput.subjectId = accountReport.Id;
                    feedItemInput.body = messageInput;
                    try {
                        ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
                    } catch (UnsupportedOperationException ex) {
                        System.debug(LoggingLevel.INFO, 'Posting feed element failed: ' + ex.getMessage());
                    }
                }
        }       
    }
}