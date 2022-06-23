/**
 * Created by alena.marozava on 17.06.2022.
 */

public with sharing class MeetingReportChildShareManager implements ChildShareCalculatorManager {

    public static final String APEX_ROW_CAUSE = 'Master__c';

    public void createNewShares(List<ApexBaseShare> shares) {
        List<Meeting_Report__Share> meetingReportShares = new List<Meeting_Report__Share>();
        for (ApexBaseShare source : shares) {
            meetingReportShares.add(convert(source));
        }
        insert meetingReportShares;
    }


    public void deleteOldShares(Set<Id> parentIds) {
        List<Meeting_Report__Share> shares = [
                SELECT Id FROM Meeting_Report__Share
                WHERE RowCause = :getRowCause() AND ParentId IN :parentIds
        ];
        delete shares;
    }

    public Map<Id, Id> retrieveAndMapParentIds(Set<Id> masterIds) {
        Map<Id, Id> meetingReportIdToMasterId = new Map<Id, Id>();
        for (Meeting_Report__c meetingReport : [
                SELECT Id, Quote__c, Order__c, Opportunity__c
                FROM Meeting_Report__c
                WHERE Quote__c IN :masterIds OR Opportunity__c IN :masterIds OR Order__c IN :masterIds
        ]) {
            meetingReportIdToMasterId.put(meetingReport.Id, getMasterObjectId(meetingReport));
        }
        return meetingReportIdToMasterId;
    }

    public String getRowCause() {
        return APEX_ROW_CAUSE; // TODO: Should be available from Schema
    }

    private Meeting_Report__Share convert(ApexBaseShare source) {
        Meeting_Report__Share newShare = new Meeting_Report__Share();
        newShare.ParentId = source.parentId;
        newShare.UserOrGroupId = source.userOrGroupId;
        newShare.AccessLevel = source.accessLevel;
        newShare.RowCause = getRowCause();
        return newShare;
    }

    private ID getMasterObjectId(Meeting_Report__c meetingReport) {
        if (meetingReport.Quote__c != null) {
            return meetingReport.Quote__c;
        }
        if ( meetingReport.Order__c != null) {
            return meetingReport.Order__c;
        }
        return meetingReport.Opportunity__c;
    }
}