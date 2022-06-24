/**
 * Created by alena.marozava on 20.06.2022.
 */

@IsTest
private class MeetingReportStatusManagementJobTest {
    private static final String TODAY_NAME = 'Today Report';
    private static final String IN_TWO_DAYS_NAME = 'In 2 days Report';
    private static final String IN_THREE_DAYS_NAME = 'In 3 days Report';

    @TestSetup
    static void setup() {
        Opportunity opportunity = new Opportunity(Name = 'Opp', StageName = 'ClosedWon', CloseDate = Date.today());
        insert opportunity;

        Account account = new Account(Name = 'Acc');
        insert account;

        Meeting_Report__c reportToday = new Meeting_Report__c(
                Account__c = account.Id,
                Opportunity__c = opportunity.Id,
                Due_Date__c = Date.today(),
                Name = TODAY_NAME,
                Meeting_Date__c = Date.today().addDays(-2),
                Status__c = MeetingReportConstants.STATUS_DRAFT,
                Subject__c = 'Some',
                Critical__c = true
        );

        Meeting_Report__c reportInTwoDays = reportToday.clone(true, true);
        reportInTwoDays.Id = null;
        reportInTwoDays.Name = IN_TWO_DAYS_NAME;
        reportInTwoDays.Due_Date__c = Date.today().addDays(2);
        reportInTwoDays.Critical__c = false;

        Meeting_Report__c reportInThreeDays = reportInTwoDays.clone(true, true);
        reportInThreeDays.Name = IN_THREE_DAYS_NAME;
        reportInThreeDays.Due_Date__c = Date.today().addDays(3);

        insert new List<Meeting_Report__c> { reportToday, reportInTwoDays, reportInThreeDays};
    }

    @IsTest
    private static void shouldUpdateStatusesWithNoErrors() {

        Test.startTest();
        Database.executeBatch(new MeetingReportStatusManagementJob());
        Test.stopTest();

        Meeting_Report__c reportTodayUpd = [SELECT ID, Name, Status__c, Critical__c FROM Meeting_Report__c WHERE Name = :TODAY_NAME];
        System.assertEquals(false, reportTodayUpd.Critical__c, 'Critical set to FALSE for TODAY report');
        System.assertEquals(
                MeetingReportConstants.STATUS_PUBLISHED,
                reportTodayUpd.Status__c,
                'Status updated to published for TODAY report'
        );

        Meeting_Report__c reportInTwoDaysUpd = [SELECT ID, Status__c, Critical__c FROM Meeting_Report__c WHERE Name = :IN_TWO_DAYS_NAME];
        System.assertEquals(true, reportInTwoDaysUpd.Critical__c, 'Critical set to TRUE for IN 2 DAYS report');
        System.assertEquals(
                MeetingReportConstants.STATUS_DRAFT,
                reportInTwoDaysUpd.Status__c,
                'Status IS NOT updated for IN 2 DAYS report'
        );

        Meeting_Report__c reportInThreeDaysUpd = [SELECT ID, Status__c, Critical__c FROM Meeting_Report__c WHERE Name = :IN_THREE_DAYS_NAME];
        System.assertEquals(
                false,
                reportInThreeDaysUpd.Critical__c,
                'Critical IS NOT updated for IN 3 DAYS report'
        );
        System.assertEquals(
                MeetingReportConstants.STATUS_DRAFT,
                reportInThreeDaysUpd.Status__c,
                'Status IS NOT updated for IN 3 DAYS report'
        );
    }
}