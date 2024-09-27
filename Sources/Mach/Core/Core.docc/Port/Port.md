# ``Mach/Port``

- Note: The class is called a "port" instead of a "port name" both for brevity and because port names are already more often referred to as "ports" by developers in user space. This is likely the case because the user space Mach API's themselves use the term "port" more often than "port name".
## Topics


### Getting Basic Info

- ``name``
- ``owningTask``

### Managing Port Rights

- ``Mach/PortRight``
- ``rights``
- ``UserRefs``
- ``userRefs(for:)``
- ``setUserRefs(for:to:)``
- ``Mach/PortDisposition``
- ``extractRight(using:)``
- ``insertRight(intoNameSpaceOf:using:)``

### Representing a Nil-Named Port

- ``Nil``

### Representing Existing Ports

- ``init(named:inNameSpaceOf:)``

### Creating Ports

- ``init(right:named:inNameSpaceOf:)``
- ``init(options:context:inNameSpaceOf:)``
- ``init(flags:limits:inNameSpaceOf:)``
- ``ConstructFlag``

### Comparing Ports

- ``==(_:_:)-kka2``
- ``!=(_:_:)-3hq0e``
- ``==(_:_:)-725gz``
- ``==(_:_:)-20pfq``

### Logging Ports

- ``description``
- ``debugDescription``

### Working with Kernel Objects

- ``Mach/KernelObject``
- ``kernelObject``

### Managing Context

- ``getContext()``
- ``setContext(_:)``
- ``context``

### Managing Attributes

- ``Mach/PortAttribute``
- ``getAttribute(_:as:)``
- ``setAttribute(_:to:)``
- ``assertAttribute(_:is:)``
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

### Guarding Ports

- ``guard(_:flags:)``
- ``unguard(_:)``
- ``GuardFlag``
- ``guarded``

### Using Port Sets

- ``Mach/PortSet``
- ``insert(into:)``
- ``move(to:)``

### Tearing Down Ports

- ``deallocate()``
- ``destroy()``
- ``destruct(guard:sendRightDelta:)``

### Service-Related Ports

- ``Mach/ServicePort``
- ``Mach/ConnectionPort``

### Additional Helpers

- ``hash(into:)``