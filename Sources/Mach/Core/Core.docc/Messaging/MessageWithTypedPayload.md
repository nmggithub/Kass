# ``Mach/MessageWithTypedPayload``

The built-in ``Mach/Message`` class only supports using a `UnsafeRawBufferPointer` for working with payloads, which can make working with protocols difficult. This protocol allows for custom classes with more-specifically-typed payloads to be created. These payload types must conform to the ``Mach/MessagePayload`` protocol.

A minimal example for creating a custom message class with a typed message is as follows:
```swift
class CustomMessage: Mach.Message, Mach.MessageWithTypedPayload {
    typealias PayloadType = [CustomPayloadType]
}
```

This library extends the `Data` type to conform to ``Mach/MessagePayload``, so it can be used as a payload type like so:

```swift
class DataMessage: Mach.Message, Mach.MessageWithTypedPayload {
    typealias PayloadType = Data
}
```

To see a full list of payload types available in this library, visit the ``Mach/MessagePayload`` documentation page.

## Topics

### Creating A Message With A Payload

- ``init(descriptors:payload:)``

### The Payload

- ``PayloadType``
- ``typedPayload``