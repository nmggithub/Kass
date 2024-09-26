# ``MachCore/Mach/Clock``

A clock is a kernel service that provides the time since some specific other time. There are currently two available clocks:

- a **system** clock that serves the time since the last boot, and
- a **calendar** clock that serves the time since the UNIX epoch.

Additionally, this ``MachCore/Mach/Clock`` class conforms to [Swift's built-in `Clock` protocol](https://developer.apple.com/documentation/swift/clock). This allows it to be used across several API's in Swift's standard library. However, in some cases, the implementations forcefully call the kernel and will crash the program if the kernel returns an error. Additionally, most of the arithmetic operators include overflow checks that will also crash the program. Because of this, use of this class as a [`Clock`](https://developer.apple.com/documentation/swift/clock) with these Swift standard library API's should be considered experimental and potentially unstable. Use it as such with caution.

## Topics

### Obtaining clocks

- ``init(_:in:)``
- ``system``
- ``calendar``

### Getting the time

- ``time``

### Getting attributes

- ``Attribute``
- ``getAttribute(_:as:)``

### Sleeping

- ``sleep(for:)``
- ``sleep(until:)``