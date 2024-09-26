# Port attributes

Ports have several attributes that can be managed.

The kernel provides API's for managing attributes on a port. There are three operations supported **get**, **set**, and **assert***. However, not every attribute supports every operation.

## Attribute-operation support table

| Attribute | ``Mach/Port/getAttribute(_:as:)`` / ``Mach/Port/Attribute/get(as:for:)`` | ``Mach/Port/setAttribute(_:to:)`` /  ``Mach/Port/Attribute/set(to:for:)`` | ``Mach/Port/assertAttribute(_:is:)``* /  ``Mach/Port/Attribute/assert(is:for:)``* |
| --- | --- | --- | --- | 
``Mach/Port/Attribute/limits`` | ✅ Yes (``Mach/Port/limits``) | ✅ Yes (``Mach/Port/setLimits(to:)``) | ❌ No |
``Mach/Port/Attribute/status`` | ✅ Yes (``Mach/Port/status``) | ❌ No | ❌ No |
``Mach/Port/Attribute/requestTableCount`` | ✅ Yes (``Mach/Port/requestTableCount``) | ✅ Yes* (``Mach/Port/setRequestTableCount(to:)``) | ❌ No |
``Mach/Port/Attribute/tempOwner`` | ❌ No | ✅ Yes (``Mach/Port/setWillChangeOwner()``) | ❌ No |
``Mach/Port/Attribute/importanceReceiver`` | ❌ No | ✅ Yes (``Mach/Port/setIsImportanceReceiver()``) | ❌ No |
``Mach/Port/Attribute/deNapReceiver`` | ❌ No | ✅ Yes* (``Mach/Port/setIsDeNapReceiver()``) | ❌ No |
``Mach/Port/Attribute/info`` | ✅ Yes (``Mach/Port/info``) | ❌ No | ❌ No |
``Mach/Port/Attribute/guard``* | ❌ No | ❌ No | ✅ Yes* (``Mach/Port/assertGuard(is:)``) |
``Mach/Port/Attribute/throttled`` | ✅ Yes* (``Mach/ServicePort/isThrottled``) | ✅ Yes* (``Mach/ServicePort/setIsThrottled(to:)``) | ❌ No |

### Additional notes on attribute-operation support

- As of macOS 13, setting the ``Mach/Port/Attribute/requestTableCount`` attribute has no effect (but the kernel will not return an error).
- Additionally, the ``Mach/Port/Attribute/throttled`` attribute is only supported on service ports.
- Also, the assert operation (and the ``Mach/Port/Attribute/guard`` attribute) were only introduced in macOS 12.0.1.
- Finally, setting the ``Mach/Port/Attribute/deNapReceiver`` attribute does the same thing as setting the ``Mach/Port/Attribute/importanceReceiver`` attribute.

## Port importance

The kernel has a private importance API which allows ports to inherent a concept of importance from other ports. Setting the ``Mach/Port/Attribute/importanceReceiver`` attribute marks the port as able to inherit importance. This appears to be one of the only parts of this importance API that is exposed to user space.

The name of the ``Mach/Port/Attribute/deNapReceiver`` attribute seems to indicate that it is related to [the App Nap feature](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html) that was [introduced in OS X Mavericks](https://www.apple.com/media/us/osx/2013/docs/OSX_Mavericks_Core_Technology_Overview.pdf). However, the "App De-Nap" API currently appears to be deprecated, and is now just a synonym for the importance API (as mentioned by some comments in the kernel).
