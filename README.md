# Encryption Info Service

## Prerequisites
Requires my modified version of the FinancialForce MetadataService class:
https://github.com/jovabe/apex-mdapi/blob/master/apex-mdapi/src/classes/MetadataService.cls


## Examples how to use
```
EncryptionInfoService encryptionInfoServ = new EncryptionInfoService();
encryptionInfoServ.includeEncryptionScheme = true;
encryptionInfoServ.retrieveAllFields();
encryptionInfoServ.outputToDebugLog();
```

```
EncryptionInfoService encryptionInfoServ = new EncryptionInfoService();
encryptionInfoServ.includeEncryptionScheme = true;
encryptionInfoServ.retrieveObjectFields('Account');
encryptionInfoServ.retrieveObjectFields('Contact');
encryptionInfoServ.outputToDebugLog();
```

## Credits
Based on code snippet from: https://salesforce.stackexchange.com/questions/268078/way-to-see-all-encrypted-fields-in-salesforce
