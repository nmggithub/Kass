# ``Mach/PortInitializableByServiceName``

Conformance to this protocol allows a custom port class to represent a specific service name:

```swift
class CustomPort: Mach.PortInitializableByServiceName {
    convenience init() throws {
        self.init(serviceName: "some.service.name")
    }
}
```

The protocols ``Mach/ClientInitializableByServiceName`` and ``Mach/ServerInitializableByServiceName`` include default implementations to respectively look-up and register ports with the bootstrap port.

- Warning: This functionality documented above is dependant on the default implementations of ``init(serviceName:)``. To avoid unexpected behavior, it is not recommended to override the default implementations.