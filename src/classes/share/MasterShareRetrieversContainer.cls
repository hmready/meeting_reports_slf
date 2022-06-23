/**
 * Created by alena.marozava on 23.06.2022.
 */

public with sharing class MasterShareRetrieversContainer {

    private static final Map<String, MasterShareCalculatorDataRetriever> retrievers =
            new Map<String, MasterShareCalculatorDataRetriever>();

    static {
        initRetrievers();
    }

    public static List<MasterShareCalculatorDataRetriever> getRetrieversWithMetadata(List<String> types) {
        List<MasterShareCalculatorDataRetriever> availableRetrievers = new List<MasterShareCalculatorDataRetriever>();
        for (String type : types) {
            availableRetrievers.add(retrievers.get(type));
        }
        return availableRetrievers;
    }

    private static void initRetrievers() {
        retrievers.put(
                Quote.class.getName(), new MasterShareCalculatorDataRetrieverImpl(Quote.class.getName())
        );
        retrievers.put(
                Order.class.getName(), new MasterShareCalculatorDataRetrieverImpl(Order.class.getName())
        );
        retrievers.put(
                Opportunity.class.getName(), new MasterShareCalculatorDataRetrieverImpl(Opportunity.class.getName())
        );
    }

}