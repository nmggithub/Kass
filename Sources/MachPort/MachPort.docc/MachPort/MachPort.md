# ``MachPort/MachPort``

## Topics

### Representing an existing port

- ``init(rawValue:)``

### Allocating a new port

- ``init(right:name:in:)``
- ``MachPortConstructFlag``
- ``init(queueLimit:flags:context:name:in:)``

### Managing the port rights
- ``rights``
- ``rights(of:in:)``
- ``MachPortRight``

### Guarding the port

- ``MachPortGuardFlag``
- ``context``
- ``guard(context:flags:)``
- ``unguard(context:)``
- ``swapGuard(old:new:)``
- ``guarded``

### Getting and setting the port attributes

- ``attributes``
- ``MachPortAttributes``
- ``MachPortAttribute``