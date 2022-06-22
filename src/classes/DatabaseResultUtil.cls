/**
 * Created by alena.marozava on 22.06.2022.
 */

public with sharing class DatabaseResultUtil {

    public static Map<Id, String> getErrorsGroupedById(List<Database.SaveResult> result) {
        Map<Id, String> recordIdToErrors = new Map<Id, String>();
        for (Database.SaveResult resultItem : result) {
            if (!resultItem.success) {
                recordIdToErrors.put(resultItem.id, joinErrorMessages(resultItem.errors));
            }
        }
        return recordIdToErrors;
    }

    private static String joinErrorMessages(List<Database.Error> errors) {
        String errorMsg = '';
        for (Database.Error error : errors) {
            errorMsg = errorMsg + '\n' + error.message;
        }
        return errorMsg;
    }
}