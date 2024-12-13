# ``BSD/CSOps``

## Topics

### Calling The System Call

- ``call(forPID:_:auditToken:dataIn:ignoreERANGE:)``
- ``BSD/CSOperation``

### Getting Blobs

- ``getCSBlob(forPID:auditToken:)``
- ``getEntitlementsBlob(forPID:auditToken:)``
- ``getDEREntitlementsBlob(forPID:auditToken:)``

### Getting Identity Information

- ``getTeamID(forPID:auditToken:)``
- ``getIdentity(forPID:auditToken:)``


### Managing Flags

- ``BSD/CSFlags``
- ``getStatus(forPID:auditToken:)``
- ``setStatus(forPID:auditToken:_:)``

### Marking Flags

- ``markInvalid(forPID:auditToken:)``
- ``markHard(forPID:auditToken:)``
- ``markKill(forPID:auditToken:)``
- ``markRestrict(forPID:auditToken:)``

### Clearing Flags

- ``clearInstallerFlags(forPID:auditToken:)``
- ``clearLibraryValidationFlags(forPID:auditToken:)``
- ``clearPlatformFlags(forPID:auditToken:)``

### Others

- ``getCDHash(forPID:auditToken:)``
- ``getPIDOffset(forPID:auditToken:)``
- ``getValidationCategory(forPID:auditToken:)``
- ``BSD/CSValidationCategory``
