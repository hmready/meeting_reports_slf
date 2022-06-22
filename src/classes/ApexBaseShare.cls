public class ApexBaseShare {

    public static final String READ_ACCESS = 'Read';
    public static final String EDIT_ACCESS = 'Edit';

    public Id id { get; set; }
    public Id parentId { get; set; }
    public String accessLevel { get; set; }
    public String rowCause { get; set; }
    public Id userOrGroupId { get; set; }
    public Boolean deleted { get; set; }

    public ApexBaseShare(Id id, Id parentId, String accessLevel, String rowCause, Id userOrGroupId, Boolean deleted) {
        this.id = id;
        this.parentId = parentId;
        this.accessLevel = accessLevel;
        this.rowCause = rowCause;
        this.userOrGroupId = userOrGroupId;
        this.deleted = deleted;
    }

    public static ApexBaseShare build(ApexBaseShare source, Id parentId, String rowCause) {
        return new ApexBaseShare(
                null,
                parentId,
                getAccessLevel(source.accessLevel),
                rowCause,
                source.userOrGroupId,
                source.deleted
        );
    }

    private static String getAccessLevel(String level) {
        switch on level {
            when 'Read' {
                return READ_ACCESS;
            }
            when else {
                return EDIT_ACCESS;
            }
        }
    }
}