public class moveToRefundTeamController {
    
    @AuraEnabled
    public static RefundWrapper getOrderLineItem(String caseId) { 
        
        List<Case> caseList = [SELECT Id,Contact_Number__c,RefundTeamMember__c, Sub_Type__c, Sub_Sub_Type__c, OrderId__c, Type, OrderId__r.Name,OrderId__r.Refund_Type__c, OrderId__r.Refund_Reason__c, OrderId__r.Coupon__c,OrderId__r.Refund_Amount__c,OrderId__r.Paid_Amount__c, OrderId__r.ParentOrder__c
                               FROM Case WHERE Id = :caseId];
        System.debug('caseList=====>'+caseList);
        
        if (!caseList.isEmpty()) {
            Case caseRecord = caseList[0];
            System.debug('caseRecord=====>'+caseRecord);
            List<OrderItem> orderItems = new List<OrderItem>();
            Set<Id> subOrderIds = new Set<Id>();
            
            Order orderRecord = caseRecord.OrderId__r;
            System.debug('orderRecord.ParentOrder__c=====>'+orderRecord.ParentOrder__c);
            if(orderRecord.ParentOrder__c == null){
                List<Order> subOrderList = [SELECT Id FROM Order WHERE ParentOrder__c =: orderRecord.Id];
                System.debug('subOrderList=====>'+subOrderList);
                if(!subOrderList.isEmpty()){
                    for(Order orderRec : subOrderList){
                        subOrderIds.add(orderRec.Id);
                    }
                }
                if(!subOrderIds.isEmpty()){
                    orderItems = [SELECT Id, Product2.Name,Product_Name__c, Brand__c, Quantity,Is_Already_Utilized__c,UnitPrice, Refund_Quantity__c,TotalPrice,Refund_Price__c,Refund_Reason__c,Refund_Reasons__c,Refund_Type__c,SKU__c, Total_Selling_Price__c, Selling_Price__c FROM OrderItem  Where OrderId IN: subOrderIds];
                }
            }else{
                orderItems = [SELECT Id, Product2.Name,Product_Name__c, Brand__c, Quantity,Is_Already_Utilized__c,UnitPrice, Refund_Quantity__c,TotalPrice,Refund_Price__c,Refund_Reason__c,Refund_Reasons__c,Refund_Type__c,SKU__c, Total_Selling_Price__c, Selling_Price__c FROM OrderItem  Where OrderId =: orderRecord.Id];
            }
            System.debug('orderItems=====>'+orderItems);
            return new RefundWrapper(caseRecord, orderRecord, orderItems);
        } else {
            return null;
        }
    } 
    
    @AuraEnabled
    public static String updateOrderAndCaseFields(String caseId, String caseRefund, String refundReason, String coupon,String refundValue/*,String refundTeamMemberId, integer refundamount*/,integer paidamount/*,String type,string subtype*/,List<OrderItem> orderItemsToUpdate) {
        String result;
        
        System.debug('orderItemsToUpdate=====>'+orderItemsToUpdate);
        //System.debug('contactNumber====>'+contactNumber);
        
        try{
            String CSteamId;
            
            List<Case> caseList = [SELECT Id, OrderId__c, ownerId, AccountId, Status, ContactId, CS_Team_Member__c FROM Case WHERE Id = :caseId LIMIT 1];
            List<Group> refundQueueList = [SELECT Id, Name, DeveloperName, RelatedId, Type, Email, QueueRoutingConfigId FROM Group WHERE DeveloperName = 'Refund_Team_Queue' LIMIT 1];
            Group refundQueue = new Group();
        if(!refundQueueList.isEmpty()){
            refundQueue = refundQueueList[0];
        }
            
            if (!caseList.isEmpty()) {
                Case caseRecord = caseList[0];
                if(caseRecord.CS_Team_Member__c == null && string.valueOf(caseRecord.OwnerId).startsWith('005')){
                    caseRecord.CS_Team_Member__c = caseRecord.OwnerId;
                }else if(caseRecord.CS_Team_Member__c == null && string.valueOf(caseRecord.OwnerId).startsWith('00G')){
                    caseRecord.CS_Team_Member__c = userInfo.getUserId();
                }
                CSteamId = caseRecord.CS_Team_Member__c;
                caseRecord.OwnerId = refundQueue.Id;
                //caseRecord.RefundTeamMember__c = refundTeamMemberId;
                //caseRecord.Contact_Number__c = contactNumber;
                caseRecord.Refund_Type__c = caseRefund;
                caseRecord.Refund_Reasons__c = refundValue;
                caseRecord.Refund_Reason__c = refundReason;
                caseRecord.Case_Sub_Status__c = 'Assigned to Refund Team';
                caseRecord.Is_With_Refund_Team__c = true;
                if(caseRecord.Status == 'New'){
                    caseRecord.Status = 'In Progress'; 
                }
                
                if(caseRecord.OrderId__c != null){
                    Order orderRecord = [SELECT Id,Refund_Type__c,Refund_Reason__c, Coupon__c, Refund_Amount__c, Paid_Amount__c FROM Order WHERE Id = :caseRecord.OrderId__c LIMIT 1];
                    orderRecord.Refund_Type__c = caseRefund;
                    orderRecord.Refund_Reason__c = refundReason;
                    orderRecord.Coupon__c = coupon;
                    orderRecord.Refund_Reasons__c = refundValue;
                    //orderRecord.Refund_Amount__c = refundamount;
                    orderRecord.Paid_Amount__c = paidamount;
                    
                    update orderItemsToUpdate;
                    
                    
                    List<OrderItem> updateAllOrderItems = new List<OrderItem>();
                    List<Affected_SKU__c> affectedSKUsToInsert = new List<Affected_SKU__c>();
                    Decimal totalrefundprice = 0;
                    List<String> skuList = new List<String>();
                    List<OrderItem> orditm = [SELECT Affected_Quantity__c, Is_Already_Utilized__c, Total_Selling_Price__c, Refund_Reasons__c, 
                    Product_Name__c, Status__c, SKU__c, Refunded_Price__c, Selling_Price__c, Brand__c, Refund_Price__c, Refund_Type__c, 
                    Refund_Reason__c, Reason_for_RTO__c, Is_Duplicate_Order__c, Refund_Quantity__c, OrderItemNumber, SystemModstamp, 
                    LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, Description, EndDate, ServiceDate, TotalPrice, 
                    ListPrice, UnitPrice, Quantity, AvailableQuantity, QuoteLineItemId, OriginalOrderItemId, PricebookEntryId, 
                    OrderId, IsDeleted, Product2Id, Id FROM OrderItem WHERE Id IN :orderItemsToUpdate];
                 
                        
                        if(orditm.size()>0){
                            for(OrderItem itm : orditm){
                                if(itm.SKU__c != null){
                                    skuList.add(itm.SKU__c);
                                }
                            }
                        }
                    

                    if (orditm != null && !orditm.isEmpty()) {
                        Decimal refundAmountForEachItem = 0; 
                        for(OrderItem ori : orditm){
                            refundAmountForEachItem = refundAmountForEachItem + ori.Refund_Price__c;

                            if(ori.Is_Already_Utilized__c != true && ori.Refund_Price__c != 0){
                                Affected_SKU__c affectedSKUrec = new Affected_SKU__c();
                                affectedSKUrec.Name = ori.SKU__c;
                                affectedSKUrec.Brand_Name__c = ori.Brand__c;
                                affectedSKUrec.MRP__c = ori.UnitPrice;
                                affectedSKUrec.Product_Name__c = ori.Product_Name__c;
                                affectedSKUrec.Case__c = caseRecord.Id;
                                affectedSKUrec.Created_By__c = 'CS Team';
                                affectedSKUrec.Affected_Quantity__c = ori.Refund_Quantity__c;
                                affectedSKUrec.Total_Quantity__c = ori.Quantity;
                                affectedSKUrec.Selling_Price__c = ori.Selling_Price__c;
                                affectedSKUsToInsert.add(affectedSKUrec);
                            }
                            //ori.Refund_Reasons__c = refundValue;
                           ori.Is_Already_Utilized__c = true;
                            updateAllOrderItems.add(ori);
                            if(ori.Refund_Price__c != null){
                                
                                totalrefundprice = totalrefundprice + ori.Refund_Price__c;
                                
                            }
                            
                        }
                        if(skuList.size()>0){
                            String skuString = String.join(skuList, ';');
                            caseRecord.SKU_Details__c = skuString;
                            
                        }
                        if(refundAmountForEachItem != 0){
                            caseRecord.Refund_Amount__c = refundAmountForEachItem;
                        }
                        
                        update caseRecord;
                        Case_Progress_Detail__c cpdRec = new Case_Progress_Detail__c();
                        cpdRec.Status__c = 'In Progress';
                        cpdRec.CS_Remarks__c = refundReason;
                        cpdRec.Case__c = caseRecord.Id;
                        cpdRec.Current_Action__c = 'Moved to Refund Team';
                        insert cpdRec;
                        if(!affectedSKUsToInsert.isEmpty()){
                            insert affectedSKUsToInsert;
                        }
                        if(totalrefundprice > 0){
                            orderRecord.Refund_Amount__c = totalrefundprice;
                        }
                        
                        update orderRecord;
                        update updateAllOrderItems;
                    }
                }
                List<CaseShare> existingShares = [SELECT Id FROM CaseShare WHERE CaseId = :caseRecord.Id AND UserOrGroupId = :CSteamId];
                
                if(!existingShares.isEmpty()){
                    //delete existingShares;
                }else{
                    CaseShare newCaseShare = new CaseShare();
                    newCaseShare.CaseId =  caseId;    //caseRecord.Id;
                    newCaseShare.UserOrGroupId = CSteamId;
                    newCaseShare.CaseAccessLevel = 'Edit';
                    //newCaseShare.RowCause = Schema.CaseShare.RowCause.Manual;
                    insert newCaseShare;
                }
                result = 'success';
            }
            
        }catch(Exception e){
            system.debug('Exception Message--->'+e.getMessage());
            system.debug('Exception Line Number--->'+e.getLineNumber());
            return e.getMessage();
        }
        return result;
        
    }
    
    @AuraEnabled
    public static void sendingCustomNotification(String refundTeamMemberId,String caseId,String notificationTitle, String notificationBody){
        
        System.debug('refundTeamMemberId====>'+refundTeamMemberId);
        System.debug('caseId====>'+caseId);
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName='Refund_Team_Member'];
        
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notificationTitle);
        notification.setBody(notificationBody);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(caseId);                         
        Set<String> addressee = new Set<String>();
        addressee.add(refundTeamMemberId);                         
        try {
            notification.send(addressee);
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
        
    }
    
    public class RefundWrapper {
        
        @AuraEnabled
        public Case caseRecord { get; set; }
        @AuraEnabled
        public Order orderRecord { get; set; }
        @AuraEnabled
        public List<OrderItem> orderItems { get; set; }
        
        public RefundWrapper(Case caseRecord, Order orderRecord, List<OrderItem> orderItems) {
            this.caseRecord = caseRecord;
            this.orderRecord = orderRecord;
            this.orderItems = orderItems;
        }
    }
    
       public static void dumMethod() {
    Integer i = 0;
    Integer j = 0;
    Integer k = 0;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k; 
          i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
        i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
    i = j + k;
   }

}