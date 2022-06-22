/**
 * Created by alena.marozava on 20.06.2022.
 */

/** Implements logic of providing sharing records of Master object for Children. */
public with sharing class ApexShareCalculator {

    /**
     * For Children objects represented with @param childShareManager recalculates sharing records
     * based on sharing records of Master objects represented with @param retrievers.
     * Recalculation is done based on those Master sharing records which where updated after @param lastRecalculated
     * Based on each Master sharing rule generated rule for each child with corresponding access level.
     */
    public static void recalculate(
        Datetime lastRecalculated,
        List<MasterShareCalculatorDataRetriever> retrievers,
        ChildShareCalculatorManager childShareManager
    ) {
        for (MasterShareCalculatorDataRetriever retriever : retrievers) {
            recalculate(lastRecalculated, retriever, childShareManager);
        }
    }

    public static void recalculate(
            Datetime lastRecalculated,
            MasterShareCalculatorDataRetriever retriever,
            ChildShareCalculatorManager childShareManager
    ) {
        Map<Id, List<ApexBaseShare>> masterShares = retriever.retrieve(lastRecalculated);
        Map<Id, Id> parentIdToMasterId = childShareManager.retrieveAndMapParentIds(masterShares.keySet());
        childShareManager.deleteOldShares(parentIdToMasterId.keySet());
        childShareManager.createNewShares(generate(masterShares, parentIdToMasterId, childShareManager.getRowCause()));
    }

    private static List<ApexBaseShare> generate(
            Map<Id, List<ApexBaseShare>> masterIdToShare,
            Map<Id, Id> parentIdToMasterId,
            String rowCause
    ) {
        List<ApexBaseShare> result = new List<ApexBaseShare>();
        for (Id parentId : parentIdToMasterId.keySet()) {
            Id masterId = parentIdToMasterId.get(parentId);
            result.addAll(generate(masterIdToShare.get(masterId), parentId, rowCause));
        }
        return result;
    }

    private static List<ApexBaseShare> generate(List<ApexBaseShare> source, Id parentId, String rowCause) {
        List<ApexBaseShare> result = new List<ApexBaseShare>();
        for (ApexBaseShare sourceShare : source) {
            result.add(ApexBaseShare.build(sourceShare, parentId, rowCause));
        }
        return result;
    }
}