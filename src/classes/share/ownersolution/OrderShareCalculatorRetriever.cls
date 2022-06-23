/**
 * Created by alena.marozava on 21.06.2022.
 */

public with sharing class OrderShareCalculatorRetriever implements MasterShareCalculatorDataRetriever {
    public Map<ID, List<ApexBaseShare>> retrieve(Datetime lastModifiedDate) {
        List<ID> modifiedIds = new List<Id>();
        for (OrderShare orderShare : [
                SELECT OrderId FROM OrderShare WHERE LastModifiedDate >= :lastModifiedDate ALL ROWS
        ]) {
            modifiedIds.add(orderShare.OrderAccessLevel);
        }

        Map<ID, List<ApexBaseShare>> orderIdToShare = new Map<ID, List<ApexBaseShare>>();
        for (OrderShare orderShare : [
                SELECT ID, OrderId, UserOrGroupId, OrderAccessLevel, RowCause, IsDeleted, LastModifiedDate
                FROM OrderShare
                WHERE OrderId IN :modifiedIds
        ]) {
            if (orderIdToShare.containsKey(orderShare.OrderId)) {
                orderIdToShare.get(orderShare.OrderId).add(convert(orderShare));
            } else {
                List<ApexBaseShare> shares = new List<ApexBaseShare>();
                shares.add(convert(orderShare));
                orderIdToShare.put(orderShare.OrderId, shares);
            }
        }
        return orderIdToShare;
    }

    private ApexBaseShare convert(OrderShare share) {
        return new ApexBaseShare(
                share.Id,
                share.OrderId,
                share.OrderAccessLevel,
                share.RowCause,
                share.UserOrGroupId,
                share.IsDeleted
        );
    }
}