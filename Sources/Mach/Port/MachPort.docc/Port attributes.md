# Port attributes

Ports have several attributes that can be managed.

The kernel provides API's for managing attributes on a port. There are three operations supported **get**, **set**, and **assert***. However, not every attribute supports every operation.

## Attribute-operation support table

| Attribute | ``MachBase/Mach/Port/getAttribute(_:as:)`` / ``MachBase/Mach/Port/Attribute/get(as:for:)`` | ``MachBase/Mach/Port/setAttribute(_:to:)`` /  ``MachBase/Mach/Port/Attribute/set(to:for:)`` | ``MachBase/Mach/Port/assertAttribute(_:is:)``* /  ``MachBase/Mach/Port/Attribute/assert(is:for:)``* |
| --- | --- | --- | --- | 
``MachBase/Mach/Port/Attribute/limits`` | ✅ Yes (``MachBase/Mach/Port/limits``) | ✅ Yes (``MachBase/Mach/Port/setLimits(to:)``) | ❌ No |
``MachBase/Mach/Port/Attribute/status`` | ✅ Yes (``MachBase/Mach/Port/status``) | ❌ No | ❌ No |
``MachBase/Mach/Port/Attribute/requestTableCount`` | ✅ Yes (``MachBase/Mach/Port/requestTableCount``) | ✅ Yes* (``MachBase/Mach/Port/setRequestTableCount(to:)``) | ❌ No |
``MachBase/Mach/Port/Attribute/tempOwner`` | ❌ No | ✅ Yes (``MachBase/Mach/Port/setWillChangeOwner()``) | ❌ No |
``MachBase/Mach/Port/Attribute/importanceReceiver`` | ❌ No | ✅ Yes (``MachBase/Mach/Port/setIsImportanceReceiver()``) | ❌ No |
``MachBase/Mach/Port/Attribute/deNapReceiver`` | ❌ No | ✅ Yes* (``MachBase/Mach/Port/setIsDeNapReceiver()``) | ❌ No |
``MachBase/Mach/Port/Attribute/info`` | ✅ Yes (``MachBase/Mach/Port/info``) | ❌ No | ❌ No |
``MachBase/Mach/Port/Attribute/guard``* | ❌ No | ❌ No | ✅ Yes* (``MachBase/Mach/Port/assertGuard(is:)``) |
``MachBase/Mach/Port/Attribute/throttled`` | ✅ Yes* (``MachBase/Mach/ServicePort/isThrottled``) | ✅ Yes* (``MachBase/Mach/ServicePort/setIsThrottled(to:)``) | ❌ No |

### Additional notes on attribute-operation support

- As of macOS 13, setting the ``MachBase/Mach/Port/Attribute/requestTableCount`` attribute has no effect (but the kernel will not return an error).
- Additionally, the ``MachBase/Mach/Port/Attribute/throttled`` attribute is only supported on service ports.
- Also, the assert operation (and the ``MachBase/Mach/Port/Attribute/guard`` attribute) were only introduced in macOS 12.0.1.
- Finally, setting the ``MachBase/Mach/Port/Attribute/deNapReceiver`` attribute does the same thing as setting the ``MachBase/Mach/Port/Attribute/importanceReceiver`` attribute.

## Port importance

The kernel has a private importance API which allows ports to inherent a concept of importance from other ports. Setting the ``MachBase/Mach/Port/Attribute/importanceReceiver`` attribute marks the port as able to inherit importance. This appears to be one of the only parts of this importance API that is exposed to user space.

The name of the ``MachBase/Mach/Port/Attribute/deNapReceiver`` attribute seems to indicate that it is related to [the App Nap feature](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/AppNap.html) that was [introduced in OS X Mavericks](https://www.apple.com/media/us/osx/2013/docs/OSX_Mavericks_Core_Technology_Overview.pdf). However, the "App De-Nap" API currently appears to be deprecated, and is now just a synonym for the importance API (as mentioned by some comments in the kernel).
