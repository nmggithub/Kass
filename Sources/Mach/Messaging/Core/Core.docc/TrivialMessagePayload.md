# ``MachCore/Mach/TrivialMessagePayload``

## Overview

Conformance to this protocol can allow for any [`BitwiseCopyable`](https://developer.apple.com/documentation/swift/bitwisecopyable) structure to be used as a payload type like so:

```swift
struct SomePayload: Mach.MessagePayload, Mach.TrivialMessagePayload {
    // ...
}
class MessageWithCustomPayload: Mach.Message, Mach.MessageWithTypedPayload {
    typealias PayloadType = SomePayload
}
```
