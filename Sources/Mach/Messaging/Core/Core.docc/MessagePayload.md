# ``MachCore/Mach/MessagePayload``

A type conforming to this protocol is meant to be used with a ``MachCore/Mach/MessageWithTypedPayload`` to provide a more-specifically-typed experience when working with message payloads. A minimal example is as follows:

```swift
{extension / struct / class} SomeType: Mach.MessagePayload {
    public static func fromRawPayloadBuffer(_ buffer: UnsafeRawBufferPointer) -> Self? {
        // Convert the UnsafeRawBufferPointer to a SomeType
    }

    public func toRawPayloadBuffer() -> UnsafeRawBufferPointer {
        // Convert the SomeType to a UnsafeRawBufferPointer
    }
}
```

## Topics

### Converting To And From Buffer Pointers

- ``toRawPayloadBuffer()``
- ``fromRawPayloadBuffer(_:)``

### Payload Types

- ``Mach/TrivialMessagePayload``
- ``Foundation/Data``
- ``Swift/Never``