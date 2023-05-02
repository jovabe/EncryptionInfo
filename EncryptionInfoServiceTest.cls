@IsTest
private class EncryptionInfoServiceTest {
    // Dummy Metadata API web service mock class (partially copied from MetadataServiceTest.cls)
    private class WebServiceMockImpl implements WebServiceMock {
        public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
        ) {
            MetadataService.CustomField customField = new MetadataService.CustomField();
            customField.fullName = 'Sea.Horse';
            customField.encrypted = true;
            customField.encryptionScheme = 'Aquatic';

            MetadataService.ReadCustomFieldResult readCustomFieldResult = new MetadataService.ReadCustomFieldResult();
            readCustomFieldResult.records = new List<MetadataService.CustomField>{ customField };

            MetadataService.readCustomFieldResponse_element readCustomFieldResponse = new MetadataService.readCustomFieldResponse_element();
            readCustomFieldResponse.result = readCustomFieldResult;

            response.put('response_x', readCustomFieldResponse);
        }
    }

    @IsTest
    private static void testRetrieveAllFields() {
        Test.startTest();
        EncryptionInfoService encryptionInfoServ = new EncryptionInfoService();
        encryptionInfoServ.retrieveAllFields();
        Test.stopTest();
    }

    @IsTest
    private static void testRetrieveObjectFields() {
        Test.startTest();
        EncryptionInfoService encryptionInfoServ = new EncryptionInfoService();
        encryptionInfoServ.retrieveObjectFields('Account');
        Test.stopTest();
    }

    @IsTest
    private static void testOutputToDebugLog() {
        Test.startTest();
        EncryptionInfoService encryptionInfoServ = new EncryptionInfoService();
        // Populate fieldInfosMap with dummy record
        encryptionInfoServ.fieldInfosMap.put('Sea.Horse', new EncryptionInfoService.FieldInfo('Sea.Horse', 'Sea', 'Horse', true));
        encryptionInfoServ.outputToDebugLog();
        encryptionInfoServ.includeEncryptionScheme = true;
        encryptionInfoServ.outputToDebugLog();
        Test.stopTest();
    }

    @IsTest
    private static void testRetrieveEncryptionScheme() {
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        EncryptionInfoService encryptionInfoServ = new EncryptionInfoService();
        // Populate fieldInfosMap with dummy record
        encryptionInfoServ.fieldInfosMap.put('Sea.Horse', new EncryptionInfoService.FieldInfo('Sea.Horse', 'Sea', 'Horse', true));

        encryptionInfoServ.retrieveFieldsEncryptionScheme();

        // Assert response
        system.assert(!encryptionInfoServ.fieldInfosMap.isEmpty());
        system.assertEquals('Aquatic', encryptionInfoServ.fieldInfosMap.get('Sea.Horse').encryptionScheme);
        Test.stopTest();
    }
}
