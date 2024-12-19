# Kext Requests

Kext requests are a messages sent from user space to kernel space that are used to manage kernel extensions.

Kernel extensions (or **kexts**) are kernel modules in the XNU kernel. Kext requests are dictionary-based messages to the kernel (which responds in-kind with its own dictionary-based messages). Kext requests can be used to get information about loaded kexts, and can even perform actions on them (such as load, unload, start, stop, etc.). However, most actions require that the task sending the kext request has specific entitlements for the action to be successful.

The kext request messaging system itself is technically private, but is well-documented in the XNU source code. The header files from the XNU source code that include helpful constants are included in this library as well. To use those constants, import the submodules into your code like so:

```swift
import KassC.KextRequestKeys
import KassC.OSKextLibPrivate
```

Please see the source code for more information.

## Topics

### Making Requests

- ``Mach/Host/kextRequest(_:logSpec:responsePointer:logsPointer:throwOnInnerFailure:)``
- ``Mach/Host/kextRequest(_:)``
- ``Mach/Host/kextRequest(predicate:arguments:)``

### Helper Types

- ``Mach/Host/KextRequestPredicate``