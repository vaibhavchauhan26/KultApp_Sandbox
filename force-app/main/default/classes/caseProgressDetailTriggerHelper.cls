public class caseProgressDetailTriggerHelper {
    public static void sendNotificationToCSTeam(List<Case_Progress_Detail__c> cpdList){
        try{
            Set<Id> caseIds = new Set<Id>();
            for(Case_Progress_Detail__c cpdRec : cpdList){
                if(cpdRec.CS_Remarks__c == null){
                    caseIds.add(cpdRec.Case__c);
                }
            }
            Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, CS_Team_Member__c FROM Case WHERE Id IN: caseIds]);
            CustomNotificationType customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'child_case_creation'];
            for(Case_Progress_Detail__c cpdRec : cpdList){
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                String notificationBody = 'A remark has been mentioned on the case, please check the details.'; 
                notification.setBody(notificationBody);
                notification.setTitle('Remark mentioned on the case');
                notification.setSenderId(UserInfo.getUserId());
                notification.setNotificationTypeId(customNotiList.Id); 
                notification.setTargetId(cpdRec.Case__c);
                System.debug('notification:::::::::::>' + notification); 
                notification.send(new set<String>{caseMap.get(cpdRec.Case__c).CS_Team_Member__c});
            }
        }catch(exception e){
            System.debug('Error Message: ' + e.getMessage() + ' at Line Number ' + e.getLineNumber());
        }
    }
    
    public static void UpdateRefundWHStatusHelper1(List<Case_Progress_Detail__c> cpdList){
        List<Case_Progress_Detail__c> createdByProfileDetails = [Select Id, WH_Team_Remarks__c,Case__c,CreatedBy.Profile.Name 
                                                                 From Case_Progress_Detail__c 
                                                                 Where Id IN :cpdList];
        
        System.debug('createdByProfileDetails====>'+createdByProfileDetails);
        List<Case> cseList = new List<Case>();
        
        for(Case_Progress_Detail__c cp : createdByProfileDetails){
            System.debug('cp.CreatedBy.Profile.Name11==> ' + cp.CreatedBy.Profile.Name);
            if(cp.WH_Team_Remarks__c != null){
                Case cs = new Case();
                cs.Id = cp.Case__c;
                System.debug('cp.CreatedBy.Profile.Name22==> ' + cp.CreatedBy.Profile.Name);
                if(cp.CreatedBy.Profile.Name == 'WareHouse Team' || cp.CreatedBy.Profile.Name == 'Customer Service Executive'){
                    cs.Refund_WH_Team_Status__c = cp.CreatedBy.Profile.Name == 'WareHouse Team' ? 'WH Team - '+ cp.Status__c : 'Refund Team - '+ cp.Status__c;  
                    System.debug('cs.Refund_WH_Team_Status__c====>'+cs.Refund_WH_Team_Status__c);
                    cseList.add(cs);
                }
            }
        }
        update cseList;
    }
    public static void UpdateRefundWHStatusHelper(List<Case_Progress_Detail__c> cpdList) {
        List<Case_Progress_Detail__c> createdByProfileDetails = [SELECT Id, WH_Team_Remarks__c, Case__c,Status__c , CreatedBy.Profile.Name 
                                                                 FROM Case_Progress_Detail__c 
                                                                 WHERE Id IN :cpdList];
        System.debug('createdByProfileDetails====>'+createdByProfileDetails);
        List<Case> caseListToUpdate = new List<Case>();
        
        for (Case_Progress_Detail__c cp : createdByProfileDetails) {
            System.debug('cp.CreatedBy.Profile.Name111==> ' + cp.CreatedBy.Profile.Name);

            Case cs = new Case(Id = cp.Case__c);
            if (cp.WH_Team_Remarks__c != null && (cp.CreatedBy.Profile.Name == 'WareHouse Team' || cp.CreatedBy.Profile.Name == 'Customer Service Executive')) {
                System.debug('cp.CreatedBy.Profile.Name123==> ' + cp.CreatedBy.Profile.Name);
                if (cp.CreatedBy.Profile.Name == 'WareHouse Team') {
                    System.debug('cp.CreatedBy.Profile.Name1`121==> ' + cp.CreatedBy.Profile.Name);
                    cs.Refund_WH_Team_Status__c = 'WH Team - ' + cp.Status__c;
                } else if (cp.CreatedBy.Profile.Name == 'Customer Service Executive') {
                    System.debug('cp.CreatedBy.Profile.Name1qwer==> ' + cp.CreatedBy.Profile.Name);
                    cs.Refund_WH_Team_Status__c = 'Refund Team - ' + cp.Status__c;
                }
            }
            if(cp.Status__c == 'Responded' || cp.Status__c == 'Resolved'){
                cs.Last_Response__c = System.Now();
            }
            caseListToUpdate.add(cs);
        }
        update caseListToUpdate;
    }
    
    
}