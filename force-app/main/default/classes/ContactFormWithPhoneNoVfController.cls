public class ContactFormWithPhoneNoVfController {
    

    @RemoteAction
    public static Account searchCustomer(string formattedPhone){
        try{
            if(formattedPhone != null){
                Account customerRecord = [SELECT Id,Name,Phone_10_Digit__c, Alternate_Phone_No__c From Account WHERE Phone_10_Digit__c =: formattedPhone LIMIT 1];
                if(customerRecord != null)
                return customerRecord;
            }
            return null;
        }catch(Exception e){
            system.debug('Error :'+e.getMessage());
            return null;
        }
    }

    @RemoteAction
    public static Order searchOrder(string searchValue){
        try{
            if(searchValue != null){
                Order orderecord = [SELECT Id,Name,Status,Account.Name,Account.Phone_10_Digit__c,Account.Alternate_Phone_No__c From Order WHERE Name =: searchValue];
                if(orderecord != null){
                    return orderecord;
                }
            }
            return null;
        }catch(Exception e){
            return null;
        }
    }
    
    @RemoteAction
    public static List<RecordTypeDependentPicklist__mdt> getMetaData(){
        try{
            List<RecordTypeDependentPicklist__mdt> recordsOfMetaData = [select id,Type__c,Sub_Type__c,Sub_Sub_Type__c from RecordTypeDependentPicklist__mdt ];
            return recordsOfMetaData;
        }catch(Exception e){
            system.debug('Error :'+e.getMessage());
            return null;
        }
        
    }

    @RemoteAction
    public static String saveCaseWithCustomerDetails(String recordTypeName, Account accRec, Case caserecord){
        try{
            update accRec;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            caserecord.RecordTypeId = recordTypeId;
            caserecord.AccountId = accRec.Id;
            insert caserecord;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }

    @RemoteAction
    public static String saveOrderDetails(String recordTypeName, String orderId, Account accRec, case caserecord){
        try{
            update accRec;
            Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            caserecord.RecordTypeId = recordTypeId;
            caserecord.AccountId = accRec.Id;
            caserecord.OrderId__c = orderId;
            insert caserecord;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }
    
    
    
    
    
    
    
    // public Lead ledRec {get;set;}
    // public String leadRecordString{get;set;}
    // public Contact conRec{get;set;}
    // public String contactRecordString{get;set;}
    
    // public Case cseRec{get;set;}
    // public String CaseRecordString{get;set;}
    // public Order ordRec{get;set;}
    // public String OrderRecordString{get;set;}
    // public Account accRec{get;set;}
    // public String AccountRecordString{get;set;}
    
    // Public ContactFormWithPhoneNoVfController() {
    //     try{
    //         String phoneNumber = Apexpages.currentPage().getParameters().get('id'); 
    //         conRec = [SELECT Id,Name,Account.Name,Email,Phone FROM Contact Where phone =: phoneNumber  LIMIT 1];
    //         System.debug('conRec ::'+conRec);
    //         if(conRec !=null){
    //             contactRecordString=JSON.serialize(conRec);
    //         }else{
    //             contactRecordString = 'Not Found';
    //         }
            
    //     }catch(Exception e){
    //         System.debug('Error ::'+e.getMessage() + ' Error Line ::'+e.getLineNumber());
    //     }
    // }
    
    // @RemoteAction
    // public Static List<String> getPickListValuesMethod(String ObjectApi_name, String Field_Name){
    //     try{
    //         List<String> lstPickvals                        = new List<String>();
    //         Schema.SObjectType targetType                   = Schema.getGlobalDescribe().get(ObjectApi_name);
    //         Sobject Object_name                             = targetType.newSObject();
    //         Schema.sObjectType sobject_type                 = Object_name.getSObjectType(); 
    //         Schema.DescribeSObjectResult sobject_describe   = sobject_type.getDescribe();
    //         Map<String, Schema.SObjectField> field_map      = sobject_describe.fields.getMap();
    //         List<Schema.PicklistEntry> pick_list_values     = field_map.get(Field_Name).getDescribe().getPickListValues();
            
    //         for (Schema.PicklistEntry a : pick_list_values) {
    //             lstPickvals.add(String.ValueOf(a.getLabel()).trim());  
    //         }
    //         System.debug('lstPickvals>>>> ::'+lstPickvals);
    //         return lstPickvals;
    //     }Catch(Exception e){
    //         System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
    //     }
    //     return null;
    // }
    
    // @RemoteAction
    // public Static lead updateLeadDetails(String leadId, String firstname,String lastname,String company,string state,String city,String street){
    //     //    System.debug('leadId ::'+leadId + ' && led Record ::'+led);
    //     try{
    //         Lead led = new Lead();
    //         led.Id = leadId;
    //         led.FirstName = firstname;
    //         led.LastName =lastname;
    //         led.Company = company;
    //         led.State = state;
    //         led.City = city;
    //         led.Street = street;
    //         update led;
    //         //   System.debug('Updated Lead ID::'+led.Id + ' && City Address:::'+led.Address);
    //         // System.debug('City Address:::'+led.Address);
    //         return led; 
    //     }catch(Exception e){
    //         System.debug('Error ::'+e.getMessage() + ' Error Line ::'+e.getLineNumber()); 
    //     }
    //     return null;
    // }
    
    // @RemoteAction
    // public Static lead updateLeadDate(String leadId, integer day, integer month, integer year ){
    //     lead led = new lead();
    //     led.Id = leadId;
    //     if(day==0 && month==0 && year==0){
            
    //     }else{
    //         // led.Followup_Date__c = Date.newInstance(year, month, day);
            
    //     }
    //     // led.Followup_Date__c = leddate;
    //     update led;
    //     return led;
    // }
    
    
}