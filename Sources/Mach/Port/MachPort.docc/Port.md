# ``MachBase/Mach/Port``

## Topics

### About ports

- <doc:Architecture>

### Comparing ports

- ``==(_:_:)-rt23``
- ``==(_:_:)-mwka``
- ``==(_:_:)-9nkdg``
- ``!=(_:_:)-2dmw6``

### Getting basic information

- ``name``
- ``owningTask``
- ``rights``
- ``Right``
- ``description``

### Representing a nil-named port

- ``Nil``

### Representing existing ports

- <doc:Using-ports>
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

### Tearing down ports

- ``deallocate()``
- ``destroy()``
- ``destruct(guard:sendRightDelta:)``

### Additional helpers

- ``hash(into:)``
