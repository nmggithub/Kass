# The Mach Interface Generator (MIG)

The Mach Interface Generator (MIG) allows for messages to be used in a more functional way.

## Overview

MIG consists of a compiler and a custom interface definition language (IDL) for defining **routines**. The compiler takes in a file of routine definitions written in that IDL and converts them to a functional interface, based on the routines, written in two C files: one to be one on the receiving server task, and one to be run on sending client tasks.

Sending tasks can then call functions for the routines defined in the original IDL file instead of manually allocating and constructing messages, as all of the code for the allocation and construction of messages was written by the compiler inside those functions. Similarly, receiving tasks can receive messages through similarly-named functions. This essentially abstracts away the entire messaging process from both the clients and the server.

- Note: In MIG, messages from clients are often called **requests** and messages from servers are often called **replies**.

## Subsystems

When there are multiple routines in an IDL file, the compiler will often compile them all into a **subsystem**. Each routine in a subsystem will have a unique number, starting at an arbitrary number and incrementing by one in definition order. The compiler will also generate code that will place the unique number for each routine in the ID field for each message intended for that routine. This makes it possible to simulate compiler code, as long as the rest of the structure of the message is also known. Finding that structure is left as an exercise for the reader.

## Topics

### Message Types

- ``Mach/MIGRequest``
- ``Mach/MIGReply``

### Port Types

- ``Mach/MIGClient``
- ``Mach/MIGReplyPort``

### Error Types

- ``Mach/MIGError``
- ``Mach/MIGErrorReply``
- ``Mach/MIGErrorCode``

### Payload Types

- ``Mach/MIGPayload``
- ``Mach/MIGPayloadWithNDR``
- ``Mach/MIGPayloadWithOnlyNDR``