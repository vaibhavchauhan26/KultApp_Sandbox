({
    doInit : function(component, event, helper) {
        debugger;
       	helper.doInithelper(component, event, helper);
    },
    replyToTweet : function(component) {
        debugger;
        component.set("v.showSpinner",true);
        
        var replyMessage = component.get("v.tweetReply");
        var tweetId  = component.get("v.tweetId");
        var action = component.get("c.sendReplyToTheTweet");
        action.setParams({
            "tweetId" : tweetId ,
            "message" : replyMessage 
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner",false);
                component.set("v.isModalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Reply posted to twitter',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    refreshFeed : function(component, event, helper) {
        debugger;
        component.set("v.showSpinner",true);
        var recId = component.get("v.recordId");
        var action = component.get("c.getUpdatedComments");
        action.setParams({
            recordId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                helper.doInithelper(component, event, helper);
             }else{
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action); 
        
    },
    openModel : function(component, event, helper) {
        debugger;
        var comment       = event.getSource().get('v.value');
        var commentedBy   = event.getSource().get('v.name');
        var commentId     = event.getSource().get('v.title');
        component.set("v.selectedCommentId",commentId);
        component.set("v.selectedCommentValue",comment);
        component.set("v.selectedCommentRepliedBy",commentedBy);
        component.set("v.isModalOpen",true);
    },
    closeModel : function(component, event, helper) {
        debugger;
        component.set("v.isModalOpen",false);
        component.set("v.showReplies",false);
    },
    postComment : function(component, event, helper) {
        debugger;
        component.set("v.spinner",true);
        var commentId      = component.get("v.selectedCommentId");
        var commentMessage = component.get("v.replyMessage");
        
        var action         = component.get("c.replyToComment");
        action.setParams({
            commentId: commentId,
            commentMessage : commentMessage
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The comment has been posted successfully!!"
                });
                toastEvent.fire();
                component.set("v.isModalOpen",false);
            }else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    viewCommentReplies : function(component, event, helper) {
        debugger;
        component.set("v.spinner",true);
        var comment       = event.getSource().get('v.value');
        var commentedBy   = event.getSource().get('v.name');
        var commentId     = event.getSource().get('v.title');
        component.set("v.selectedCommentId",commentId);
        component.set("v.selectedCommentValue",comment);
        component.set("v.selectedCommentRepliedBy",commentedBy);
        
        var action         = component.get("c.getRepliesDetails");
        action.setParams({
            commentId: commentId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var serverresponse = response.getReturnValue();
                if(serverresponse.length > 0){
                    component.set("v.relatedReplyList",serverresponse);
                    component.set("v.showReplies",true);
                    component.set("v.spinner",false);    
                }else{
                    //component.set("v.relatedReplyList",[]);
                    //component.set("v.showReplies",true);
                    component.set("v.spinner",false);  
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'No Replies Yet!',
                        message: 'No replies on this comment!!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                
            }else{
                
            }
        });
        $A.enqueueAction(action); 
    },
    next: function(component, event, helper) {
        debugger;
        var sObjectList = component.get("v.relatedCommentList");
        console.log('sObjectList///', sObjectList);
        var startValue = component.get("v.startValue");
        var endValue = component.get("v.endValue");
        var perPage = component.get("v.perPageSize");
        console.log('startValue///', startValue);
        console.log('endValue///', endValue);
        var totalRecords = component.get("v.totalRecords");
        var values = [];
        //for eg-------------------------------------------------------------------------
        // this is page 2 and there are 10 records
        // endValue is 4
        //if total no. of records == 4+5+1 (i.e. 10)
        //Or if total no. of records >  10, then evaluate this part----------------------
        if (totalRecords >= endValue + perPage + 1) {
            for (var i = endValue + 1; i < endValue + perPage + 1; i++) {
                values.push(sObjectList[i]);
            }
            if (totalRecords == endValue + perPage + 1) {//if total records == 4+5+1-----------
                component.set("v.isLastPage", true);
            }
        }//------------------------------------------------------------------------------
        else {//if total number of records are lesser than 4+5+1(10) i.e. 8
            for (var i = endValue + 1; i < totalRecords; i++) {
                values.push(sObjectList[i]);
            }
            component.set("v.isLastPage", true);
        }//------------------------------------------------------------------------------
        component.set("v.PaginationList", values);
        component.set("v.startValue", endValue + 1);
        component.set("v.endValue", endValue + perPage);
        console.log('start value////' + component.get("v.startValue"));
        console.log('end value////' + component.get("v.endValue"));
        
    },
    
    previous: function(component, event, helper) {
        debugger;
        component.set("v.isLastPage", false);
        var sObjectList = component.get("v.relatedCommentList");
        console.log('sObjectList///', sObjectList);
        var startValue = component.get("v.startValue");
        var endValue = component.get("v.endValue");
        var perPage = component.get("v.perPageSize");
        console.log('startValue///', startValue);
        console.log('endValue///', endValue);
        var totalRecords = component.get("v.totalRecords");
        var values = [];
        for (var i = startValue - perPage; i < startValue; i++) {
            console.log('i' + i);
            values.push(sObjectList[i]);
        }
        component.set("v.PaginationList", values);
        component.set("v.startValue", startValue - perPage);
        component.set("v.endValue", startValue - 1);
        console.log('start value////' + component.get("v.startValue"));
        console.log('end value////' + component.get("v.endValue"));
    },
    
    
    
})