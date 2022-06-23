/**
 * Created by alena.marozava on 21.06.2022.
 */

public with sharing class MasterShareCalculatorDataRetrieverImpl implements MasterShareCalculatorDataRetriever {

    private static final String RETRIEVE_PARENT_IDS_BEFORE_DATE_QUERY =
            'SELECT {0} FROM {1} WHERE LastModifiedDate >= lastModifiedDate ALL ROWS';
    private static final String RETRIEVE_ALL_OBJECTS_PARENT_ID_IN_QUERY =
            'SELECT ID, {0}, UserOrGroupId, {1}, RowCause, IsDeleted FROM {2} WHERE {0} IN :parentIds';

    private String masterType;

    public MasterShareCalculatorDataRetrieverImpl(String masterType) {
        this.masterType = masterType;
    }

    public Map<Id, List<ApexBaseShare>> retrieve(Datetime lastModifiedDate) {
        Master_Share_Recalculation__mdt metadata = MasterShareRecalculationUtil.getMetadataByType(masterType);
        List<Id> modifiedParentIds = retrieveParentIdsOfModifiedRecords(lastModifiedDate, metadata);
        return retrieveSharesAndGroupByParentId(modifiedParentIds, metadata);
    }

    private Map<Id, List<ApexBaseShare>> retrieveSharesAndGroupByParentId(
            List<Id> modifiedParentIds,
            Master_Share_Recalculation__mdt metadata
    ) {
        Map<Id, List<ApexBaseShare>> parentIdToShare = new Map<Id, List<ApexBaseShare>>();
        for (SObject shareObject : retrieveAllParentIdIn(metadata, modifiedParentIds)) {
            Id parentId = MasterShareRecalculationUtil.getParentId(shareObject, metadata);
            if (parentIdToShare.containsKey(parentId)) {
                parentIdToShare.get(parentId).add(convert(shareObject, metadata));
            } else {
                List<ApexBaseShare> shares = new List<ApexBaseShare>();
                shares.add(convert(shareObject, metadata));
                parentIdToShare.put(parentId, shares);
            }
        }
        return parentIdToShare;
    }

    private List<Id> retrieveParentIdsOfModifiedRecords(
            Datetime lastModifiedDate,
            Master_Share_Recalculation__mdt metadata
    ) {
        List<Id> modifiedParentIds = new List<Id>();
        for (SObject shareObject : retrieveModifiedRecords(metadata, lastModifiedDate)) {
            modifiedParentIds.add(MasterShareRecalculationUtil.getParentId(shareObject, metadata));
        }
        return modifiedParentIds;
    }

    // Note: lastModifiedDate used in query
    private List<SObject> retrieveModifiedRecords(Master_Share_Recalculation__mdt metadata, Datetime lastModifiedDate) {
        return Database.query(
                String.format(
                        RETRIEVE_PARENT_IDS_BEFORE_DATE_QUERY,
                        new List<Object>{
                                MasterShareRecalculationUtil.getParentFieldName(metadata),
                                metadata.ShareTableName__c
                        }
                )
        );
    }

    // Note: parentIds used in query
    private List<SObject> retrieveAllParentIdIn(Master_Share_Recalculation__mdt metadata, List<Object> parentIds) {
        return Database.query(
                String.format(
                        RETRIEVE_ALL_OBJECTS_PARENT_ID_IN_QUERY,
                        new List<Object>{
                                MasterShareRecalculationUtil.getParentFieldName(metadata),
                                MasterShareRecalculationUtil.getAccessLevelFieldName(metadata),
                                metadata.ShareTableName__c
                        }
                )
        );
    }

    private ApexBaseShare convert(SObject share, Master_Share_Recalculation__mdt metadata) {
        return new ApexBaseShare(
                share.Id,
                MasterShareRecalculationUtil.getParentId(share, metadata),
                MasterShareRecalculationUtil.getAccessLevel(share, metadata),
                (String) share.get(MasterShareRecalculationUtil.ROW_CAUSE_FIELD),
                (Id) share.get(MasterShareRecalculationUtil.USER_OR_GROUP_ID_FIELD),
                (Boolean) share.get(MasterShareRecalculationUtil.IS_DELETED_FIELD)
        );
    }
}