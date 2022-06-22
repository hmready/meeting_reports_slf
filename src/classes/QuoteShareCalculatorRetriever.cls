/**
 * Created by alena.marozava on 21.06.2022.
 */

public with sharing class QuoteShareCalculatorRetriever implements MasterShareCalculatorDataRetriever {

    public String getMasterType() {
        return Quote.class.getName();
    }

    public Map<ID, List<ApexBaseShare>> retrieve(Datetime lastModifiedDate) {
        List<ID> modifiedIds = new List<Id>();
        for (QuoteShare quoteShare : [
                SELECT ParentId FROM QuoteShare WHERE LastModifiedDate >= :lastModifiedDate ALL ROWS
        ]) {
            modifiedIds.add(quoteShare.ParentId);
        }

        Map<ID, List<ApexBaseShare>> quoteIdToShare = new Map<ID, List<ApexBaseShare>>();
        for (QuoteShare quoteShare : [
                SELECT ID, ParentId, UserOrGroupId, AccessLevel, RowCause, IsDeleted, LastModifiedDate
                FROM QuoteShare
                WHERE ParentId IN :modifiedIds
        ]) {
            if (quoteIdToShare.containsKey(quoteShare.ParentId)) {
                quoteIdToShare.get(quoteShare.ParentId).add(convert(quoteShare));
            } else {
                List<ApexBaseShare> shares = new List<ApexBaseShare>();
                shares.add(convert(quoteShare));
                quoteIdToShare.put(quoteShare.ParentId, shares);
            }
        }
        return quoteIdToShare;
    }

    private ApexBaseShare convert(QuoteShare share) {
        return new ApexBaseShare(
                share.Id,
                share.ParentId,
                share.AccessLevel,
                share.RowCause,
                share.UserOrGroupId,
                share.IsDeleted
        );
    }
}