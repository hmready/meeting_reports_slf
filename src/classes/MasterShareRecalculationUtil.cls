/**
 * Created by alena.marozava on 21.06.2022.
 */

public with sharing class MasterShareRecalculationUtil {

    public static final String DEFAULT_PARENT_ID_FIELD = 'ParentId';
    public static final String DEFAULT_ACCESS_LEVEL_FIELD = 'AccessLevel';
    public static final String ROW_CAUSE_FIELD = 'RowCause';
    public static final String USER_OR_GROUP_ID_FIELD = 'UserOrGroupId';
    public static final String IS_DELETED_FIELD = 'IsDeleted';

    private static final Map<String, Master_Share_Recalculation__mdt> typeToMetadata =
            new Map<String, Master_Share_Recalculation__mdt>();

    static {
        initMetadata();
    }

    public static Master_Share_Recalculation__mdt getMetadataByType(String type) {
        return typeToMetadata.get(type);
    }

    public static Id getParentId(SObject share, Master_Share_Recalculation__mdt metadata) {
        return (Id) share.get(getParentFieldName(metadata));
    }

    public static String getParentFieldName(Master_Share_Recalculation__mdt metadata) {
        return String.isNotBlank(metadata.ParentIdFieldName__c)
                ? metadata.ParentIdFieldName__c
                : MasterShareRecalculationUtil.DEFAULT_PARENT_ID_FIELD;
    }

    public static String getAccessLevel(SObject share, Master_Share_Recalculation__mdt metadata) {
        return (String) share.get(getAccessLevelFieldName(metadata));
    }

    public static String getAccessLevelFieldName(Master_Share_Recalculation__mdt metadata) {
        return String.isNotBlank(metadata.AccessLevelFieldName__c)
                ? metadata.AccessLevelFieldName__c
                : MasterShareRecalculationUtil.DEFAULT_ACCESS_LEVEL_FIELD;
    }

    private static void initMetadata() {
        for (Master_Share_Recalculation__mdt metadata : retrieveMetadata()) {
            typeToMetadata.put(metadata.DeveloperName, metadata);
        }
    }

    private static List<Master_Share_Recalculation__mdt> retrieveMetadata() {
        return [
                SELECT Id, DeveloperName, AccessLevelFieldName__c, ParentIdFieldName__c, ShareTableName__c
                FROM Master_Share_Recalculation__mdt
        ];
    }
}