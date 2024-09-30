# ``Mach/PortAttributeFlavor``

There are three operations that can be performed on port attributes: **get**, **set**, and **assert***.

However, not every attribute supports every operation.

## Attribute-Operation Support Table

| Attribute | ``Mach/PortAttributeManager/get(_:as:)`` | ``Mach/PortAttributeManager/set(_:to:)`` | ``Mach/PortAttributeManager/assert(_:is:)``* |
| --- | --- | --- | --- | 
``limits`` | ✅ Yes (``Mach/PortAttributeManager/limits``) | ✅ Yes (``Mach/PortAttributeManager/setLimits(to:)``) | ❌ No |
``status`` | ✅ Yes (``Mach/PortAttributeManager/status``) | ❌ No | ❌ No |
``requestTableCount`` | ✅ Yes (``Mach/PortAttributeManager/requestTableCount``) | ✅ Yes* (``Mach/PortAttributeManager/setRequestTableCount(to:)``) | ❌ No |
``tempOwner`` | ❌ No | ✅ Yes (``Mach/PortAttributeManager/setWillChangeOwner()``) | ❌ No |
``importanceReceiver`` | ❌ No | ✅ Yes (``Mach/PortAttributeManager/setIsImportanceReceiver()``) | ❌ No |
``deNapReceiver`` | ❌ No | ✅ Yes* (``Mach/PortAttributeManager/setIsDeNapReceiver()``) | ❌ No |
``info`` | ✅ Yes (``Mach/PortAttributeManager/info``) | ❌ No | ❌ No |
``guardInfo``* | ❌ No | ❌ No | ✅ Yes* (``Mach/PortAttributeManager/assertGuard(is:)``) |
``throttled``* | ✅ Yes* (``Mach/ServicePort/isThrottled``) | ✅ Yes* (``Mach/ServicePort/setIsThrottled(to:)``) | ❌ No |

- As of macOS 13, setting the ``requestTableCount`` attribute has no effect (but the kernel will not return an error).
- Additionally, the ``throttled`` attribute is only supported on service ports.
- Also, the assert operation (and the ``guardInfo`` attribute) were only introduced in macOS 12.0.1.
- Finally, setting the ``deNapReceiver`` attribute does the same thing as setting the ``importanceReceiver`` attribute.

## Port Importance

The kernel has a private importance API which allows ports to inherent a concept of importance from other ports. Setting the ``importanceReceiver`` attribute marks the port as able to inherit importance. This appears to be one of the only parts of this importance API that is exposed to user space.

The name of the ``deNapReceiver`` attribute seems to indicate that it is related to [the App Nap feature](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html) that was [introduced in OS X Mavericks](https://www.apple.com/media/us/osx/2013/docs/OSX_Mavericks_Core_Technology_Overview.pdf). However, the "App De-Nap" API currently appears to be deprecated, and is now just a synonym for the importance API (as mentioned by some comments in the kernel).


## Topics

### Using Raw Flavor Values
- ``rawValue``
- ``init(rawValue:)``

### Attributes

- ``info``
- ``limits``
- ``status``
- ``requestTableCount``
- ``tempOwner``
- ``importanceReceiver``
- ``deNapReceiver``
- ``throttled``
- ``guardInfo``
