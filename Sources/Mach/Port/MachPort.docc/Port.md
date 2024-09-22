# ``MachBase/Mach/Port``

## Topics

### Basic information

- ``name``
- ``owningTask``
- ``rights``
- ``Right``

### Representing existing names

- ``init(named:)``
- ``init(named:in:)``

### Allocating new ports

- ``init(right:named:in:)``

### Constructing new ports

- ``init(queueLimit:flags:context:in:)``
- ``ConstructFlag``

### User references

- <doc:User-references>
- ``userRefs(for:)``
- ``UserRefs``

### Managing context

- ``getContext()``
- ``setContext(_:)``
- ``context``

### Managing attributes

- ``Attribute``
- ``getAttribute(_:as:)``
- ``setAttribute(_:to:)``

### Guarding ports

- ``guard(_:flags:)``
- ``unguard(_:)``
- ``GuardFlag``
- ``guarded``

### Using port sets

- ``MachBase/Mach/PortSet``
- ``insert(into:)``
- ``move(to:)``

### Logging

- ``loggableName``
- ``log(_:)``
- ``loggable(_:)``

### Tearing down ports

- ``deallocate()``
- ``destroy()``
- ``destruct(guard:sendRightDelta:)``