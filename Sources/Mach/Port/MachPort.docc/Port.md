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
- ``debugDescription``

### Representing a nil-named port

- ``Nil``

### Representing existing ports

- <doc:Using-ports>
- ``init(named:in:)``

### Allocating new ports

- ``init(right:named:in:)``

### Constructing new ports

- <doc:Using-ports>
- ``init(options:context:in:)``
- ``init(flags:limits:in:)``
- ``ConstructFlag``

### User references

- <doc:User-references>
- ``userRefs(for:)``
- ``UserRefs``
- ``setUserRefs(for:to:)``

### Managing context

- ``getContext()``
- ``setContext(_:)``
- ``context``

### Managing attributes

- <doc:Port-attributes>
- ``Attribute``
- ``getAttribute(_:as:)``
- ``setAttribute(_:to:)``
- ``assertAttribute(_:is:)``

### Managing specific attributes

- <doc:Port-attributes>
- ``limits``
- ``setLimits(to:)``
- ``status``
- ``requestTableCount``
- ``setRequestTableCount(to:)``
- ``setWillChangeOwner()``
- ``setIsImportanceReceiver()``
- ``setIsDeNapReceiver()``
- ``info``
- ``assertGuard(is:)``

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

### Getting related ports

- ``WithSpecialPorts``
- ``SpecialPortType``