# ``Mach/PortInitializableByServiceName``

Conformance to this protocol allows a custom port class to represent a specific service from the bootstrap server like so:

```swift
class CustomPort: Mach.PortInitializableByServiceName {
    convenience init() throws {
        self.init(serviceName: "some.service.name")
    }
}
```

The ``init(serviceName:)`` initializer has a default implementation that uses the bootstrap server to look up the given service name and obtain a send right to it, placing the name of the send right into the ``Mach/Port/name`` property. Therefore, an instance of `CustomPort` above can be used to send messages to the service named `some.service.name`.

- Warning: This functionality documented above is dependant on the default implementation of ``init(serviceName:)``. To avoid unexpected behavior, it is not recommended to override this default implementation.