# ``Mach/PortAttributeManager``

There are three operations that can be performed on port attributes: **get**, **set**, and **assert***.

However, not every attribute supports every operation.

## Attribute-Operation Support Table

| Attribute | ``get(_:as:)`` | ``set(_:to:)`` | ``assert(_:is:)``* |
| --- | --- | --- | --- | 
``Mach/PortAttributeFlavor/limits`` | ✅ Yes (``limits``) | ✅ Yes (``setLimits(to:)``) | ❌ No |
``Mach/PortAttributeFlavor/status`` | ✅ Yes (``status``) | ❌ No | ❌ No |
``Mach/PortAttributeFlavor/requestTableCount`` | ✅ Yes (``requestTableCount``) | ✅ Yes* (``setRequestTableCount(to:)``) | ❌ No |
``Mach/PortAttributeFlavor/tempOwner`` | ❌ No | ✅ Yes (``setWillChangeOwner()``) | ❌ No |
``Mach/PortAttributeFlavor/importanceReceiver`` | ❌ No | ✅ Yes (``setIsImportanceReceiver()``) | ❌ No |
``Mach/PortAttributeFlavor/deNapReceiver`` | ❌ No | ✅ Yes* (``setIsDeNapReceiver()``) | ❌ No |
``Mach/PortAttributeFlavor/info`` | ✅ Yes (``info``) | ❌ No | ❌ No |
``Mach/PortAttributeFlavor/guardInfo``* | ❌ No | ❌ No | ✅ Yes* (``assertGuard(is:)``) |
``Mach/PortAttributeFlavor/throttled``* | ✅ Yes* (``Mach/ServicePort/isThrottled``) | ✅ Yes* (``Mach/ServicePort/setIsThrottled(to:)``) | ❌ No |

- As of macOS 13, setting the ``Mach/PortAttributeFlavor/requestTableCount`` attribute has no effect (but the kernel will not return an error).
- Additionally, the ``Mach/PortAttributeFlavor/throttled`` attribute is only supported on service ports.
- Also, the assert operation (and the ``Mach/PortAttributeFlavor/guardInfo`` attribute) were only introduced in macOS 12.0.1.
- Finally, setting the ``Mach/PortAttributeFlavor/deNapReceiver`` attribute does the same thing as setting the ``Mach/PortAttributeFlavor/importanceReceiver`` attribute.

## Port Importance

The kernel has a private importance API which allows ports to inherent a concept of importance from other ports. Setting the ``Mach/PortAttributeFlavor/importanceReceiver`` attribute marks the port as able to inherit importance. This appears to be one of the only parts of this importance API that is exposed to user space.

The name of the ``Mach/PortAttributeFlavor/deNapReceiver`` attribute seems to indicate that it is related to [the App Nap feature](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html) that was [introduced in OS X Mavericks](https://www.apple.com/media/us/osx/2013/docs/OSX_Mavericks_Core_Technology_Overview.pdf). However, the "App De-Nap" API currently appears to be deprecated, and is now just a synonym for the importance API (as mentioned by some comments in the kernel).

## Topics

### Creating a Port Attribute Manager

- ``init(port:)``
- ``port``

### General Operations

 - ``get(_:as:)``
 - ``set(_:to:)``
 - ``assert(_:is:)``

### Managing Specific Attributes

- ``Mach/PortAttributeFlavor``
- ``limits``
- ``setLimits(to:)``
- ``status``
- ``requestTableCount``
- ``setRequestTableCount(to:)``
- ``setWillChangeOwner()``
- ``setIsImportanceReceiver()``
- ``setIsDeNapReceiver()``
- ``info``
- ``assertGuard(is:)``