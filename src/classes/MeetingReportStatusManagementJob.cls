public class MeetingReportStatusManagementJob
        implements Database.Batchable<sObject>, Database.Stateful, System.Schedulable {

    private static String SEND_TO_EMAIL = 'tech.work.sales05+support@gmail.com';
    private static String SUBJECT_MSG = 'Meeting report status update result';
    private static String SUCCESS_MSG = 'All meeting reports statuses were successfully updated!';
    private static String ERRORS_MSG = 'Update of some meeting reports failed: ';
    private static String SENDER_DISPLAY_NAME = 'Support Team';

    private Map<Id, String> recordIdToErrors = new Map<Id, String>();

    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new MeetingReportStatusManagementJob());
    }

    public List<Meeting_Report__c> start(Database.BatchableContext context) {
        List<Meeting_Report__c> query = [
                SELECT ID, Status__c, Due_Date__c, Critical__c
                FROM Meeting_Report__c
                WHERE Due_Date__c = NEXT_N_DAYS:2 OR Due_Date__c = TODAY
        ];
        return query;
    }

    public void execute(Database.BatchableContext context, List<Meeting_Report__c> scope) {
        for (Meeting_Report__c report : scope) {
            updateReport(report);
        }
        List<Database.SaveResult> result = Database.update(scope, false);
        recordIdToErrors.putAll(DatabaseResultUtil.getErrorsGroupedById(result));
    }

    public void finish(Database.BatchableContext context) {
        sendEmailWithResult();
    }

    private Meeting_Report__c updateReport(Meeting_Report__c report) {
        if (report.Due_Date__c == Date.today()) {
            report.Status__c = MeetingReportConstants.STATUS_PUBLISHED;
            report.Critical__c = false;
        } else {
            report.Critical__c = true;
        }
        return report;
    }

    private void sendEmailWithResult() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { SEND_TO_EMAIL });
        mail.setSubject(SUBJECT_MSG);
        mail.setPlainTextBody(hasJobErrors() ? buildErrorMsg() : SUCCESS_MSG);
        mail.setSenderDisplayName(SENDER_DISPLAY_NAME);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail });
    }

    private String buildErrorMsg() {
        String body = ERRORS_MSG;
        for (Id id : recordIdToErrors.keySet()) {
            body = body + 'ID: ' + id + '\n' + recordIdToErrors.get(id) + '\n';
        }
        return body;
    }

    private Boolean hasJobErrors() {
        return !recordIdToErrors.isEmpty();
    }
}