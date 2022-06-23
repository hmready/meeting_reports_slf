/**
 * Created by alena.marozava on 21.06.2022.
 */

public with sharing class MeetingReportApexShareRecalculationJob implements Schedulable {

    private static final Integer RUN_PERIOD_MINUTES = 30;
    private static final List<String> masterTypes = new List<String>{
        Opportunity.class.getName(), Order.class.getName(), Quote.class.getName()
    };

    public void execute(SchedulableContext context) {
       executeSolutionWithMetadata();
    }

    private void executeSolution() {
        ApexShareCalculator.recalculate(
                Datetime.now().addMinutes(-RUN_PERIOD_MINUTES),
                new List<MasterShareCalculatorDataRetriever> {
                        new OpportunityShareCalculatorRetriever(),
                        new QuoteShareCalculatorRetriever(),
                        new OrderShareCalculatorRetriever()
                },
                new MeetingReportChildShareManager()
        );
    }

    private void executeSolutionWithMetadata() {
        ApexShareCalculator.recalculate(
                Datetime.now().addMinutes(-RUN_PERIOD_MINUTES),
                MasterShareRetrieversContainer.getRetrieversWithMetadata(masterTypes),
                new MeetingReportChildShareManager()
        );
    }
}