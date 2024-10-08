# ``Mach/Port/UserRefs``


When a port name names a specific port right, it also names a specific number of user references.

## What is a user reference count?

A user reference count is a count connected with a right named by a port name (in a task's name space). The term "user reference count" comes from the Mach documentation and is likely named as such as it is, conceptually, the number of references to the right in user space (at least within the context of the given task).

While perhaps not exactly the same thing in concept, the user reference count can also be seen simply as the number of copies a task has of the given right. In many cases, using a right decrements this count by one. Once the count reaches zero, the right is deallocated in the kernel, and the task can no longer use it.

## Getting and setting the user reference count

The kernel can be called to either get the user reference count or to modify it by some delta. The count itself cannot be set atomically (although a ``Mach/Port/setUserRefs(for:to:)`` function is provided). To otherwise limit functionality to atomic kernel calls, this library uses a ``Mach/Port/UserRefs`` structure to represent the user reference count. The ``+=(_:_:)`` and ``-=(_:_:)`` operators can be used to modify the count. The ``==(_:_:)-94tgn`` and ``==(_:_:)-8x5ed`` operators can be used to compare the count to a given value (or visa versa). Finally, the ``count`` itself is also accessible.

Note that all of these operations may fail, so they all must be prefixed with the `try` keyword.

```swift
let urefs = port.userRefs(for: .send) // gets the user reference count for the send right
try urefs += 1 // increments the count by one
try urefs -= 1 // decrements the count by one
let isCountTwo = try urefs == 2 // compares the value to 2
let isCountThree = try 3 == urefs // compares the value to 3
let count = try urefs.count // gets the count
```

## Topics

### Operators

- ``+=(_:_:)``
- ``-=(_:_:)``
- ``==(_:_:)-94tgn``
- ``==(_:_:)-8x5ed``

### Instance Properties

- ``count``