/**
 * Created by alena.marozava on 23.06.2022.
 */
@IsTest
public with sharing class MeetingReportShareRecalculationJobTest {

    @TestSetup
    static void setup() {

        User user = createUser('Admin', 'adminUserTest@some.de');
        insert user;

        Opportunity opportunity = new Opportunity(Name = 'Opp1', StageName = 'ClosedWon', CloseDate = Date.today());
        insert opportunity;

        Account account = new Account(Name = 'Acc');
        insert account;

        List<OpportunityShare> oppShares = createOpportunityShares(opportunity, user);
        insert oppShares;

        List<Meeting_Report__c> reports = new List<Meeting_Report__c>{
                createMeetingReport('Name 1', account, opportunity),
                createMeetingReport('Name 2', account, opportunity)
        };
        insert reports;

        List<Meeting_Report__Share> mrShares = createMeetingReportShare(user, reports);
        insert mrShares;

    }

    @IsTest
    static void shouldCorrectlyRecalculateMeetingReportShares() {
        Test.startTest();
        new MeetingReportShareRecalculationJob().execute(null);
        Test.stopTest();

        Id userId = [SELECT Id FROM User WHERE Email = 'adminUserTest@some.de'].Id;
        List<Meeting_Report__Share> apexShares = [
                SELECT Id, AccessLevel, RowCause, ParentId, UserOrGroupId
                FROM Meeting_Report__Share
                WHERE RowCause = :MeetingReportChildShareManager.APEX_ROW_CAUSE
        ];

        System.assertEquals(8, [SELECT Id FROM Meeting_Report__Share].size(), 'Total number of records must be equal to expected');
        System.assertEquals(4, apexShares.size(), 'Should be created 4 new APEX shares and old APEX records deleted');
        assertAccessLevels(apexShares, userId);
    }

    private static void assertAccessLevels(List<Meeting_Report__Share> apexShares, Id userId) {
        for (Meeting_Report__Share share : apexShares) {
            String expectedAccessLevel = share.UserOrGroupId == userId ? ApexBaseShare.READ_ACCESS : ApexBaseShare.EDIT_ACCESS;
            System.assertEquals(expectedAccessLevel, share.AccessLevel);
        }
    }

    private static Meeting_Report__c createMeetingReport(String name, Account account, Opportunity opportunity) {
        return new Meeting_Report__c(
                Account__c = account.Id,
                Opportunity__c = opportunity.Id,
                Due_Date__c = Date.today(),
                Name = name,
                Meeting_Date__c = Date.today().addDays(-2),
                Status__c = MeetingReportConstants.STATUS_DRAFT,
                Subject__c = 'Some',
                Critical__c = true
        );
    }

    private static List<OpportunityShare> createOpportunityShares(Opportunity opportunity, User user) {
        return new List<OpportunityShare>{
                createOpportunityShare(user, opportunity, 'Manual', ApexBaseShare.READ_ACCESS)
        };
    }

    private static List<Meeting_Report__Share> createMeetingReportShare(User user, List<Meeting_Report__c> reports) {
        List<Meeting_Report__Share> shares = new List<Meeting_Report__Share>();
        for (Meeting_Report__c report : reports) {
            shares.add(createMeetingReportShare(user, report, 'Manual'));
            shares.add(createMeetingReportShare(user, report, MeetingReportChildShareManager.APEX_ROW_CAUSE));
        }
        return shares;
    }

    private static OpportunityShare createOpportunityShare(
            User user, Opportunity opportunity, String rowCause, String access
    ) {
        return new OpportunityShare(
                UserOrGroupId = user.Id,
                OpportunityAccessLevel = access,
                OpportunityId = opportunity.Id,
                RowCause = rowCause
        );
    }

    private static Meeting_Report__Share createMeetingReportShare(User user, Meeting_Report__c report, String cause) {
        return new Meeting_Report__Share(
                UserOrGroupId = user.Id,
                ParentId = report.Id,
                AccessLevel = ApexBaseShare.READ_ACCESS,
                RowCause = cause
        );
    }

    public static User createUser(String alias, String email) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        User user = new User(
                Alias = alias,
                Email = email,
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = profile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = email + System.currentTimeMillis(),
                Phone = ''
        );

        return user;
    }
}