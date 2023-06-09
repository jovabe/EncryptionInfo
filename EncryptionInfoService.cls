public with sharing class EncryptionInfoService {
    public Boolean includeObjectsWithAssociatedEntities;
    public Boolean includeEncryptionScheme;

    @TestVisible
    private Map<String, FieldInfo> fieldInfosMap;

    public EncryptionInfoService() {
        includeObjectsWithAssociatedEntities = false; // Exclude system level objects by default
        includeEncryptionScheme = false; // Excluded by default because of increased limit usage
        clearFields();
    }

    // Get all encrypted fields

    public void retrieveAllFields() {
        for (Schema.SObjectType object_i : Schema.getGlobalDescribe().values()) {
            if (!includeObjectsWithAssociatedEntities && String.isNotBlank(object_i.getDescribe().getAssociateEntityType())) {
                continue; // Skip objects with associated entities
            }

            for (Schema.SObjectField field_i : object_i.getDescribe().fields.getMap().values()) {
                if (field_i.getDescribe().isEncrypted()) {
                    addField(object_i.getDescribe().getName(), field_i.getDescribe().getName(), true);
                }
            }

            if (Test.isRunningTest()) {
                return; // Stop early to improve unit test performance
            }
        }

        if (includeEncryptionScheme) {
            retrieveFieldsEncryptionScheme();
        }
    }

    public void retrieveObjectFields(String objectName) {
        Map<String, Schema.SObjectType> globalDescribes = Schema.getGlobalDescribe();

        if (!globalDescribes.containsKey(objectName)) {
            return; // Stop if object not found
        }

        for (Schema.SObjectField field_i : globalDescribes.get(objectName).getDescribe().fields.getMap().values()) {
            if (field_i.getDescribe().isEncrypted()) {
                addField(objectName, field_i.getDescribe().getName(), true);
            }
        }

        if (includeEncryptionScheme) {
            retrieveFieldsEncryptionScheme();
        }
    }

    // Retrieve EncryptionScheme from Metadata API
    // Note: requires the MetadataService from FinancialForce (modified to include encryptionScheme)

    @TestVisible
    private void retrieveFieldsEncryptionScheme() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        service.CallOptions = new MetadataService.CallOptions_element();
        service.timeout_x = 120000;

        List<String> batch = new List<String>();
        List<MetadataService.CustomField> mdInfo = new List<MetadataService.CustomField>();

        for (FieldInfo fieldInfo : fieldInfosMap.values()) {
            batch.add(fieldInfo.fullName);

            if (batch.size() == 10) {
                // Max batch size as documented here:
                // https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_readMetadata.htm
                mdInfo.addAll((List<MetadataService.CustomField>) service.readMetadata('CustomField', batch).getRecords());
                batch.clear();
            }
        }

        if (batch.size() > 0) {
            mdInfo.addAll((List<MetadataService.CustomField>) service.readMetadata('CustomField', batch).getRecords());
        }

        for (MetadataService.CustomField field_i : mdInfo) {
            updateFieldEncryptionScheme(field_i.fullName, field_i.encryptionScheme);
        }
    }

    // Output information

    @SuppressWarnings('PMD.ApexDangerousMethods') // Obviously this is sensitive information
    public void outputToDebugLog() {
        if (this.includeEncryptionScheme) {
            outputToDebugLog_EncryptionScheme();
        } else {
            String output = '\nObject,Field,IsEncrypted';
            for (FieldInfo fieldInfo : fieldInfosMap.values()) {
                output += '\n' + fieldInfo.objectName + ',' + fieldInfo.fieldName + ',' + fieldInfo.isEncrypted;
            }
            system.debug(output);
        }
    }

    @SuppressWarnings('PMD.ApexDangerousMethods') // Obviously this is sensitive information
    private void outputToDebugLog_EncryptionScheme() {
        String output = '\nObject,Field,IsEncrypted,EncryptionScheme';
        for (FieldInfo fieldInfo : fieldInfosMap.values()) {
            output += '\n' + fieldInfo.objectName + ',' + fieldInfo.fieldName + ',' + fieldInfo.isEncrypted + ',' + fieldInfo.encryptionScheme;
        }
        system.debug(output);
    }

    // Manage fieldInfosMap

    public void clearFields() {
        fieldInfosMap = new Map<String, FieldInfo>();
    }

    private void addField(String objectName, String fieldName, Boolean isEncrypted) {
        fieldInfosMap.put(objectName + '.' + fieldName, new FieldInfo(objectName + '.' + fieldName, objectName, fieldName, isEncrypted));
    }

    private void updateFieldEncryptionScheme(String fullName, String encryptionScheme) {
        if (fieldInfosMap.containsKey(fullName)) {
            fieldInfosMap.get(fullName).encryptionScheme = encryptionScheme;
        }
    }

    // FieldInfo Class

    @TestVisible
    class FieldInfo {
        @TestVisible
        String fullName;
        @TestVisible
        String objectName;
        @TestVisible
        String fieldName;
        @TestVisible
        Boolean isEncrypted;
        @TestVisible
        String encryptionScheme;

        @TestVisible
        FieldInfo() {
            this.fullName = '';
            this.objectName = '';
            this.fieldName = '';
            this.isEncrypted = false;
            this.encryptionScheme = '';
        }
        @TestVisible
        FieldInfo(String fullName, String objectName, String fieldName) {
            this();
            this.fullName = fullName;
            this.objectName = objectName;
            this.fieldName = fieldName;
        }
        @TestVisible
        FieldInfo(String fullName, String objectName, String fieldName, Boolean isEncrypted) {
            this(fullName, objectName, fieldName);
            this.isEncrypted = isEncrypted;
        }
    }
}
