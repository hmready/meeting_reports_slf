/**
 * Created by alena.marozava on 17.06.2022.
 */

public class OpportunityShareCalculatorRetriever implements MasterShareCalculatorDataRetriever {

    public Map<ID, List<ApexBaseShare>> retrieve(Datetime lastModifiedDate) {
        List<ID> modifiedIds = new List<Id>();
        for (OpportunityShare oppShare : [
                SELECT OpportunityId FROM OpportunityShare WHERE LastModifiedDate >= :lastModifiedDate ALL ROWS
        ]) {
            modifiedIds.add(oppShare.OpportunityId);
        }

        Map<ID, List<ApexBaseShare>> opportunityIdToShare = new Map<ID, List<ApexBaseShare>>();
        for (OpportunityShare oppShare : [
                SELECT ID, OpportunityId, UserOrGroupId, OpportunityAccessLevel, RowCause, IsDeleted, LastModifiedDate
                FROM OpportunityShare
                WHERE OpportunityId IN :modifiedIds
        ]) {
            if (opportunityIdToShare.containsKey(oppShare.OpportunityId)) {
                opportunityIdToShare.get(oppShare.OpportunityId).add(convert(oppShare));
            } else {
                List<ApexBaseShare> shares = new List<ApexBaseShare>();
                shares.add(convert(oppShare));
                opportunityIdToShare.put(oppShare.OpportunityId, shares);
            }
        }
        return opportunityIdToShare;
    }

    private ApexBaseShare convert(OpportunityShare share) {
        return new ApexBaseShare(
                share.Id,
                share.OpportunityId,
                share.OpportunityAccessLevel,
                share.RowCause,
                share.UserOrGroupId,
                share.IsDeleted
        );
    }
}