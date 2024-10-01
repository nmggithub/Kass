# ``Mach/MessageHeaderBits``

## Overview

The configuration bits in a message header contain configuration options for the message: 

- The configuration bits contain dispositions (types of processing) to be done to the ports named in the header. The dispositions will be used to extract rights from the names ports and include them in the message.
- Any other configuration bits are used for other purposes. Currently, the only use for these additional bits is indicating if the message is complex (i.e. if it contains descriptors).

## Topics

## Working With Raw Configuration Bits

- ``init(rawValue:)``
- ``rawValue``

### Port Dispositions

- ``localPortDisposition``
- ``remotePortDisposition``
- ``voucherPortDisposition``

### Other Configuration

- ``isMessageComplex``
- ``otherBits``