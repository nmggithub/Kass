# ``Mach/Port``

- Note: The class is called a "port" instead of a "port name" both for brevity and because port names are already more often referred to as "ports" by developers in user space. This is likely the case because the user space Mach API's themselves use the term "port" more often than "port name".
## Topics


### Getting Basic Info

- ``name``
- ``owningTask``

### Getting Port Rights

- ``Mach/PortRights``
- ``rights``

### Representing a Nil-Named Port

- ``Nil``

### Representing Existing Ports

- ``init(named:inNameSpaceOf:)``

### Creating Ports

- ``allocate(right:named:inNameSpaceOf:)``
- ``construct(options:context:inNameSpaceOf:)``
- ``construct(flags:limits:inNameSpaceOf:)``
- ``Mach/PortConstructFlags``

### Managing Port Rights

- ``UserRefs``
- ``userRefs(for:)``
- ``setUserRefs(for:to:)``
- ``Mach/PortDisposition``
- ``extractRight(using:intoNameSpaceOf:)``
- ``insertRight(intoNameSpaceOf:using:)``
- ``sendRightCount``
- ``setMakeSendCount(to:)``

### Managing Attributes

- ``Mach/PortAttributeManager``
- ``Mach/PortAttributeFlavor``
- ``attributes``

### Working with Kernel Objects

- ``Mach/KernelObject``
- ``kernelObject``
- ``KassC/ipc_kotype_t``

### Managing Context

- ``getContext()``
- ``setContext(to:)``
- ``context``

### Guarding Ports

- ``guard(with:flags:)``
- ``unguard(with:)``
- ``Mach/PortGuardFlags``
- ``guarded``

### Using Port Sets

- ``Mach/PortSet``
- ``insert(into:)``
- ``move(to:)``

### Tearing Down Ports

- ``deallocate()``
- ``destroy()``
- ``destruct(guard:sendRightDelta:)``


### Comparing Ports

- ``==(_:_:)-kka2``
- ``!=(_:_:)-3hq0e``
- ``==(_:_:)-725gz``
- ``==(_:_:)-20pfq``

### Logging Ports

- ``description``
- ``debugDescription``

### Additional Helpers

- ``hash(into:)``