public class showAllRelatedCasesController {
    @AuraEnabled(cacheable = true)
    public static List<Case> getCaseList(String chatTranscripId){
        try{
            if(chatTranscripId != null && string.valueOf(chatTranscripId).startsWith('570')){
                List<LiveChatTranscript> caseList1 = [SELECT Id, CaseId FROM LiveChatTranscript WHERE Id=: chatTranscripId LIMIT 1];
                String caseId;
                if(!caseList1.isEmpty()){
                    caseId = caseList1[0].CaseId;
                }
                if(caseId != null){
                    //Case caseRec = [SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, ContactId, AccountId FROM Case WHERE Id=: caseId LIMIT 1];
                    Case cse = [SELECT Id, CaseNumber, Subject, Type, Order_Number__c,RecordType.Name,OrderId__r.Name ,OrderId__r.OrderNumber,OrderId__c,ContactPhone,AccountId,ContactId,Email_Id__c,Contact_Number__c,ContactMobile,Instagram_ID__c FROM Case WHERE Id = :caseId];
                    Set<Id> caseAccountIds = new Set<Id>();
                    Set<Id> caseContactIds = new Set<Id>();
                    set<String> TypeString = new set<String>();
                    set<String> EmailString = new set<String>();
                    set<String> PhoneString = new set<String>();
                    set<String> MobileString = new set<String>();
                    set<String> InstagramString = new set<String>();
                    set<String> contactNumberString = new set<String>();
                    if (cse.AccountId != null || cse.ContactId != null || cse.Email_Id__c != null || cse.ContactPhone != null || 
                    cse.Instagram_ID__c != null || cse.ContactMobile != null || cse.Contact_Number__c != null){
                    caseAccountIds.add(cse.AccountId);
                    caseContactIds.add(cse.ContactId);
                    EmailString.add(cse.Email_Id__c);
                    // PhoneString.add(cse.ContactPhone);
                    InstagramString.add(cse.Instagram_ID__c);
                    // MobileString.add(cse.ContactMobile);
                    contactNumberString.add(cse.Contact_Number__c);
                    }
                    // String orderId;
                    // String accountId;
                    // String caseContactId;
                    // String caseAccountId;
                    // if(caseRec.OrderId__c != null){
                    //     orderId = caseRec.OrderId__c;
                    // }
                    // if(caseRec.OrderId__r.AccountId != null){
                    //     accountId = caseRec.OrderId__r.AccountId;
                    // }
                    // if(caseRec.ContactId != null){
                    //     caseContactId = caseRec.ContactId;
                    // }
                    // if(caseRec.AccountId != null){
                    //     caseAccountId = caseRec.AccountId;
                    // }
                //List<Case> caseList =[SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, Status, Origin, Subject, Priority,Sub_Sub_Type__c, Sub_Type__c FROM Case WHERE (OrderId__c =: orderId OR AccountId =: accountId OR ContactId =: caseContactId OR AccountId =: caseAccountId) AND Status != 'Closed' ORDER BY CreatedDate DESC];
                List<Case> caseList = [SELECT Id, Subject, Origin, Status,OrderId__r.Name, Order_Number__c,RecordType.Name,OrderId__r.OrderNumber,CaseNumber,Sub_Type__c,Sub_Sub_Type__c,ContactPhone,
        Account.Name,AccountId,Contact.Name,ContactId,Email_Id__c,Contact_Number__c,ContactMobile,Instagram_ID__c FROM Case WHERE 
        (AccountId IN :caseAccountIds OR ContactId IN :caseContactIds OR Email_Id__c IN :EmailString 
        OR Contact_Number__c IN :contactNumberString OR Instagram_ID__c IN :InstagramString) AND Status != 'Closed' Order By CreatedDate];
        System.debug('caseList:::::::::::>' + caseList);
        return caseList;
                }
                return null;
            }else if(chatTranscripId != null && string.valueOf(chatTranscripId).startsWith('500')){
            // Case caseRec = [SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, ContactId, AccountId FROM Case WHERE Id=: chatTranscripId LIMIT 1];

            Case cse = [SELECT Id, CaseNumber, Subject, Order_Number__c,RecordType.Name,OrderId__r.Name ,OrderId__r.OrderNumber,OrderId__c,ContactPhone,AccountId,ContactId,Email_Id__c,Contact_Number__c,ContactMobile,Instagram_ID__c FROM Case WHERE Id = :chatTranscripId];
            Set<Id> caseAccountIds = new Set<Id>();
            Set<Id> caseContactIds = new Set<Id>();
            set<String> TypeString = new set<String>();
            set<String> EmailString = new set<String>();
            set<String> PhoneString = new set<String>();
            set<String> MobileString = new set<String>();
            set<String> InstagramString = new set<String>();
            set<String> contactNumberString = new set<String>();
            Set<String> orderIdSet = new Set<String>();
            if (cse.AccountId != null || cse.ContactId != null || cse.Email_Id__c != null || cse.ContactPhone != null || 
            cse.Instagram_ID__c != null || cse.ContactMobile != null || cse.Contact_Number__c != null){
            caseAccountIds.add(cse.AccountId);
            caseContactIds.add(cse.ContactId);
            EmailString.add(cse.Email_Id__c);
            // PhoneString.add(cse.ContactPhone);
            InstagramString.add(cse.Instagram_ID__c);
            // MobileString.add(cse.ContactMobile);
            contactNumberString.add(cse.Contact_Number__c);
            orderIdSet.add(cse.OrderId__c);
            }

            // String orderId;
            // String accountId;
            // String caseContactId;
            // String caseAccountId;
            // if(caseRec.OrderId__c != null){
            //     orderId = caseRec.OrderId__c;
            // }else{
            //     orderId = '0';
            // }
            // if(caseRec.OrderId__r.AccountId != null){
            //     accountId = caseRec.OrderId__r.AccountId;
            // }else{
            //     accountId = '0';
            // }
            // if(caseRec.ContactId != null){
            //     caseContactId = caseRec.ContactId;
            // }else{
            //     caseContactId = '0';
            // }
            // if(caseRec.AccountId != null){
            //     caseAccountId = caseRec.AccountId;
            // }else{
            //     caseAccountId = '0';
            // }
            //List<Case> caseList =[SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, Status, Origin, Subject, Priority,Sub_Sub_Type__c, Sub_Type__c FROM Case WHERE (OrderId__c =: orderId OR AccountId =: accountId OR ContactId =: caseContactId OR AccountId =: caseAccountId) AND Status != 'Closed' ORDER BY CreatedDate DESC];
            List<Case> caseList = [SELECT Id, Type, Subject, Origin, Status,OrderId__r.Name, Order_Number__c,RecordType.Name,OrderId__r.OrderNumber,CaseNumber,Sub_Type__c,Sub_Sub_Type__c,ContactPhone,
            Account.Name,AccountId,Contact.Name,ContactId,Email_Id__c,Contact_Number__c,ContactMobile,Instagram_ID__c FROM Case WHERE 
            (AccountId IN :caseAccountIds OR ContactId IN :caseContactIds OR Email_Id__c IN :EmailString 
            OR Contact_Number__c IN :contactNumberString OR Instagram_ID__c IN :InstagramString OR OrderId__c IN: orderIdSet) AND Status != 'Closed' Order By CreatedDate DESC];
            System.debug('caseList:::::::::::>' + caseList);
            return caseList;
        }else if(chatTranscripId != null && string.valueOf(chatTranscripId).startsWith('00T')){
            // Case caseRec = [SELECT Id, CaseNumber, OrderId__c, OrderId__r.AccountId, ContactId, AccountId FROM Case WHERE Id=: chatTranscripId LIMIT 1];

            Task taskRec = [SELECT Case__c, Id, CreatedDate, Subject, WhatId FROM Task WHERE Id =: chatTranscripId LIMIT 1];
            Date extractedDate = taskRec.CreatedDate.Date();
            List<Task> taskList = [SELECT Case__c, Id, CreatedDate, Subject, WhatId FROM Task WHERE WhatId =: taskRec.WhatId AND Exotel_CTI__Call_Direction__c != null];
            Set<Id> caseIds = new Set<Id>();
            for(Task tsk : taskList){
                if(tsk.Case__c != null){
                    caseIds.add(tsk.Case__c);
                }
            }
            List<Case> caseList = new List<Case>();
            if(!caseIds.isEmpty()){
                caseList = [SELECT Id, Type, Subject, Origin, Status,OrderId__r.Name, Order_Number__c,RecordType.Name,OrderId__r.OrderNumber,CaseNumber,Sub_Type__c,Sub_Sub_Type__c,ContactPhone,
                Account.Name,AccountId,Contact.Name,ContactId,Email_Id__c,Contact_Number__c,ContactMobile,Instagram_ID__c FROM Case WHERE Id IN: caseIds AND Status != 'Closed' AND DAY_ONLY(CreatedDate) =: extractedDate Order By CreatedDate DESC];
            }
            return caseList;
        }else{
                return null;
            }
        }catch(exception e){
            System.debug('Error Message==> ' + e.getMessage() + ' at line number ' + e.getLineNumber());
            return null;
        }
    }
}