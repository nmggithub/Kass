# ``Mach/PortAttributeFlavor``

There are three operations supported: **get**, **set**, and **assert***. However, not every attribute supports every operation.

## Attribute-Operation Support Table

| Attribute | ``Mach/Port/getAttribute(_:as:)`` / ``Mach/PortAttributeFlavor/get(as:for:)`` | ``Mach/Port/setAttribute(_:to:)`` /  ``Mach/PortAttributeFlavor/set(to:for:)`` | ``Mach/Port/assertAttribute(_:is:)``* /  ``Mach/PortAttributeFlavor/assert(is:for:)``* |
| --- | --- | --- | --- | 
``Mach/PortAttributeFlavor/limits`` | ✅ Yes (``Mach/Port/limits``) | ✅ Yes (``Mach/Port/setLimits(to:)``) | ❌ No |
``Mach/PortAttributeFlavor/status`` | ✅ Yes (``Mach/Port/status``) | ❌ No | ❌ No |
``Mach/PortAttributeFlavor/requestTableCount`` | ✅ Yes (``Mach/Port/requestTableCount``) | ✅ Yes* (``Mach/Port/setRequestTableCount(to:)``) | ❌ No |
``Mach/PortAttributeFlavor/tempOwner`` | ❌ No | ✅ Yes (``Mach/Port/setWillChangeOwner()``) | ❌ No |
``Mach/PortAttributeFlavor/importanceReceiver`` | ❌ No | ✅ Yes (``Mach/Port/setIsImportanceReceiver()``) | ❌ No |
``Mach/PortAttributeFlavor/deNapReceiver`` | ❌ No | ✅ Yes* (``Mach/Port/setIsDeNapReceiver()``) | ❌ No |
``Mach/PortAttributeFlavor/info`` | ✅ Yes (``Mach/Port/info``) | ❌ No | ❌ No |
``Mach/PortAttributeFlavor/guard``* | ❌ No | ❌ No | ✅ Yes* (``Mach/Port/assertGuard(is:)``) |
``Mach/PortAttributeFlavor/throttled`` | ✅ Yes* (``Mach/ServicePort/isThrottled``) | ✅ Yes* (``Mach/ServicePort/setIsThrottled(to:)``) | ❌ No |

- As of macOS 13, setting the ``Mach/PortAttributeFlavor/requestTableCount`` attribute has no effect (but the kernel will not return an error).
- Additionally, the ``Mach/PortAttributeFlavor/throttled`` attribute is only supported on service ports.
- Also, the assert operation (and the ``Mach/PortAttributeFlavor/guard`` attribute) were only introduced in macOS 12.0.1.
- Finally, setting the ``Mach/PortAttributeFlavor/deNapReceiver`` attribute does the same thing as setting the ``Mach/PortAttributeFlavor/importanceReceiver`` attribute.

## Port Importance

The kernel has a private importance API which allows ports to inherent a concept of importance from other ports. Setting the ``Mach/PortAttributeFlavor/importanceReceiver`` attribute marks the port as able to inherit importance. This appears to be one of the only parts of this importance API that is exposed to user space.

The name of the ``Mach/PortAttributeFlavor/deNapReceiver`` attribute seems to indicate that it is related to [the App Nap feature](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html) that was [introduced in OS X Mavericks](https://www.apple.com/media/us/osx/2013/docs/OSX_Mavericks_Core_Technology_Overview.pdf). However, the "App De-Nap" API currently appears to be deprecated, and is now just a synonym for the importance API (as mentioned by some comments in the kernel).


## Topics

### Attributes

- ``info``
- ``limits``
- ``status``
- ``requestTableCount``
- ``tempOwner``
- ``importanceReceiver``
- ``deNapReceiver``
- ``throttled``
- ``guard``

### Operations

- ``get(as:for:)``
- ``set(to:for:)``
- ``assert(is:for:)``