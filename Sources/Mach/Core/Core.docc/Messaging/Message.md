# ``Mach/Message``

## Overview

Messages are blocks of data that can be sent to a port by any task that holds a send right to that port, and can be received from a port by any task that holds a receive right to that port. However, the kernel is designed to only allow one task to hold a receive right to a port. The makes the message system **multiple-sender** but **single-receiver**.

Due to this, receiving tasks are often called **servers**, and sending tasks are often called **clients**.

## The Message Structure

A message contains, in order:

1. a ``header``,
2. an optional ``body`` of descriptors,
3. an optional arbitrary ``payload``, and
4. a kernel-appended ``trailer``.

- Note: The order of the components listed above is not particularly important to know for the purposes of this library, as each component of a message is accessible and mutable through its own property without needing to know where in memory it will eventually reside in relation to the others. However, the information is still generally useful to know about how messages work, so it is included here.

## Sending and Receiving

The kernel provides for three main message operations:

- sending (``send(_:to:withDisposition:options:timeout:)``),
- receiving (``receive(_:ofMaxSize:from:options:timeout:)``), and
- a combined send and receive (``send(_:to:withDisposition:receiving:ofMaxSize:from:withDisposition:options:timeout:)``).

For more advanced operation, the underlying `mach_msg` kernel call is available in an error-safe format through ``message(_:options:sendSize:receiveSize:receivePort:timeout:notifyPort:)``.

## Topics

### Creating a Message

- ``init(descriptors:payloadBytes:)``

### Communication

- ``message(_:options:sendSize:receiveSize:receivePort:timeout:notifyPort:)``
- ``send(_:to:withDisposition:options:timeout:)``
- ``send(_:to:withDisposition:receiving:ofMaxSize:from:withDisposition:options:timeout:)``
- ``receive(_:ofMaxSize:from:options:timeout:)``
- ``MessageOptions``


### Message Headers

- ``Darwin/mach_msg_header_t``
- ``header``

### Message Bodies

- ``MessageBody``
- ``body``

### Message Payloads

- ``payload``
- ``Mach/MessageWithTypedPayload``
- ``Mach/MessagePayload``

### Other Contents

- ``trailer``

### Header Pointers

- ``init(headerPointer:)``
- ``serialize()``

### Message Queues

- ``Mach/MessageQueue``
- ``Mach/MessageClient``
- ``Mach/MessageServer``

### Others

- <doc:The-Mach-Interface-Generator>
