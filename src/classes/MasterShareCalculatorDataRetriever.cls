/**
 * Created by alena.marozava on 17.06.2022.
 */

/** Describes retrieve functionality for object which is supposed to become a Master object in sharing relationship. */
public interface MasterShareCalculatorDataRetriever {

    String getMasterType();

    /**
     * Retrieves all share records related to master type when some of them were updated before lastModifiedDate.
     * Result contains records as ApexBaseShare grouped by parent id.
     **/
    Map<Id, List<ApexBaseShare>> retrieve(Datetime lastModifiedDate);
}