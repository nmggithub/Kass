# ``Mach/call(_:)``

## Basic Kernel Calls

Mach kernel calls do not (and actually cannot) throw errors, instead opting to use return codes. These kernel calls can be made error-safe through the use of the ``Mach/call(_:)`` function, which simply wraps any kernel call. 

```swift
try Mach.call(some_mach_kernel_call())
```

### Handling Errors

The ``Mach/call(_:)`` function does not handle error return codes and will instead throw them. The vast majority of the time, these codes are thrown using [`MachError`](https://developer.apple.com/documentation/foundation/macherror). Any return codes that cannot be represented as a `MachError` will be thrown as a [`NSError`](https://developer.apple.com/documentation/foundation/nserror). Both types of errors should be handled to ensure safe usage of kernel calls.

- Note: This library makes extensive use of the ``Mach/call(_:)`` function. In general, this library does **not** handle any errors, but instead surfaces these errors to the caller. It also doesn't generally throw any custom errors. Thus, any throwing functions that are part of this library should be assumed to work as above unless otherwise noted.

#### Inside Mach Kernel Calls

The vast majority of kernel calls in Mach are **not** system calls. More specifically, they do not directly interface with the CPU to enter "kernel mode". Instead, they send **Mach messages** to the kernel. When the kernel receives such a message, it will execute the requested call and return the result in a reply message.

Due to this additional factor, these kernel calls can sometimes return an error code from an extended set of messaging return codes. This can happen if something goes wrong in the messaging layer. These codes are not representable with [MachError](https://developer.apple.com/documentation/foundation/macherror), so this is a case where an [NSError](https://developer.apple.com/documentation/foundation/nserror) will be thrown instead.

## Advanced Kernel Calls

Due to their low-level nature, Mach kernel calls do not natively support arrays (at least not with a single parameter). For kernel calls that work with arrays, two parameters are required: an array pointer and a count (or a pointer to a count if the array is being output by the call). In some cases, the array is not actually an array but rather an arbitrarily-sized block of data. In any case, these two parameters are needed for these kinds of kernel calls.

### Design Patterns

This library provides helper functions for three major design patterns Mach kernel calls use for dealing with arrays:

- **count-in** (when expecting an array as input),
- **count-out** (when outputting an array), and
- **count-in-out** (when outputting an array, and expecting a desired count as input).

Each helper function expects a block as a final parameter in which the actual kernel call is made. The helper will set up the two required parameters as necessary and pass them into the block.
- Warning: Do **not** use the ``Mach/call(_:)`` function inside the blocks. The helper functions already wrap the blocks with it.

| Design Pattern | Array-Based Helper | Data-Based Helper | Block Parameter Type |
| --- | --- | --- | --- |
| Count-In | ``Mach/callWithCountIn(array:_:)`` | ``Mach/callWithCountIn(value:_:)`` | ``Mach/CountInCallBlock`` |
| Count-Out | ``Mach/callWithCountOut(element:_:)`` | ``Mach/callWithCountOut(type:_:)`` | ``Mach/CountOutCallBlock`` |
| Count-In-Out | ``Mach/callWithCountInOut(count:_:)`` | ``Mach/callWithCountInOut(type:_:)`` | ``Mach/CountInOutCallBlock`` |

### On Count-In-Out Calls

The main difference between a count-in-out call and a count-out call is that a count-in-out call may return an error based on the count passed to it. This usually happens if the passed count is less than what is required for the requested array or data, but may sometimes happen if the passed count is not *exactly* the value the kernel expects.

The data-based helper function for count-in-out calls takes this into account and will calculate the appropriate count for the passed data type by dividing its size by the size of the array element type. This type is usually inferred by usage in the block. In some cases, though, it may need to be declared explicitly in the block parameters.

### Examples

- Note: The kernel calls used below don't actually exist and are used for demonstration purposes only. For examples of real uses of these helper functions, please inspect the source code for this library.

```swift
/// Count-In Array-Based Call
try Mach.callWithCountIn(array: someArray) {
    array, count in mach_set_array(array, count)
}
/// Count-In Data-Based Call
try Mach.callWithCountIn(value: someValue) {
    array, count in mach_set_value(array, count)
}
/// Count-Out Array-Based Call
let array = try Mach.callWithCountOut(element: SomeArrayElement.self) {
    array, count in mach_get_array(array, &count)
}
/// Count-Out Data-Based Call
let data = try Mach.callWithCountOut(type: SomeType.self) {
    array, count in mach_get_value(array, &count)
}
/// Count-In-Out Array-Based Call
let otherArray = try Mach.callWithCountInOut(count: &someCount) {
    array, count in mach_get_array_2(array, &count)
}
/// Count-In-Out Data-Based Call
let otherData = try Mach.callWithCountInOut(type: SomeType.self) {
    array, count in mach_get_value_2(array, &count)
}
```



## Topics

### Advanced Kernel Calls

- ``Mach/CountInCallBlock``
- ``Mach/callWithCountIn(array:_:)``
- ``Mach/callWithCountIn(value:_:)``
- ``Mach/CountOutCallBlock``
- ``Mach/callWithCountOut(element:_:)``
- ``Mach/callWithCountOut(type:_:)``
- ``Mach/CountInOutCallBlock``
- ``Mach/callWithCountInOut(count:_:)``
- ``Mach/callWithCountInOut(type:_:)``