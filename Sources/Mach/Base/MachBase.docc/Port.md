# ``Mach/Port``

## Topics

### Working with ports
- <doc:Using-ports>
- <doc:User-references>
- ``Mach/PortSet``
- ``Mach/KernelObject``

### Service-related ports

- ``Mach/ServicePort``
- ``Mach/ConnectionPort``

### Comparing ports

- ``==(_:_:)-8tefr``
- ``==(_:_:)-3uryp``
- ``==(_:_:)-44cvw``
- ``!=(_:_:)-6tu4z``

### Getting basic information

- ``name``
- ``owningTask``
- ``Right``
- ``rights``
- ``description``
- ``debugDescription``

### Representing a nil-named port

- ``Nil``

### Representing existing ports

- ``init(named:in:)``

### Allocating new ports

- ``init(right:named:in:)``

### Constructing new ports

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

- ``Mach/PortSet``
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