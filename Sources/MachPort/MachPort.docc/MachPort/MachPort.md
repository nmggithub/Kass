# ``MachPort/MachPort``

## Topics

### Wrapping an existing port

- ``init(rawValue:)``

### Creating a new port

- ``allocate(right:name:in:)``
- ``ConstructFlag``
- ``construct(queueLimit:flags:context:name:in:)``

### Managing the port rights
- ``rights``
- ``rights(of:in:)``
- ``Right``

### Guarding the port

- ``GuardFlag``
- ``context``
- ``guard(context:flags:)``
- ``unguard(context:)``
- ``swapGuard(old:new:)``
- ``guarded``

### Getting and setting the port attributes

- ``attributes``
- ``Attributes``
- ``Attribute``