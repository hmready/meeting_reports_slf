/**
 * Created by alena.marozava on 17.06.2022.
 */

/**
 * Describes functionality for managing sharing records for object which is supposed to become
 * a Child in sharing relationship.
 */
public interface ChildShareCalculatorManager {

    void createNewShares(List<ApexBaseShare> shares);

    void deleteOldShares(Set<Id> parentIds);

    Map<Id, Id> retrieveAndMapParentIds(Set<Id> masterIds);

    String getRowCause();
}