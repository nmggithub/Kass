# ``Mach/Message``

## Topics

### Creating a Message

- ``init(descriptors:payloadBuffer:)``

### Sending And Receiving Messages

- ``Mach/message(_:options:sendSize:receiveSize:receivePort:timeout:notifyPort:)``
- ``sendMessage(_:to:options:timeout:)``
- ``sendMessage(_:to:receiving:ofMaxSize:on:options:timeout:)``
- ``receiveMessage(_:ofMaxSize:on:options:timeout:)``
- ``Mach/MessageOptions``


### Working With Message Headers

- ``Darwin/mach_msg_header_t``
- ``header``

### Working With Message Bodies

- ``MessageBody``
- ``body``

### Working With Message Payloads

- ``payloadBuffer``
- ``Mach/MessageWithTypedPayload``
- ``Mach/MessagePayload``

### Other Contents

- ``trailer``

### Working With Header Pointers

- ``init(headerPointer:)``
- ``serialize()``

### Working With Message Queues

- ``Mach/MessageQueue``
- ``Mach/MessageClient``
- ``Mach/MessageServer``