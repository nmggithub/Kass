# Extending ports

The ``MachBase/Mach/Port`` class has several optional features that it can be extended with.

The base ``MachBase/Mach/Port`` class can't do very much on its own beyond critical functionality. However, there are features of ports common to ports that are provided as optional extensions to the ``MachBase/Mach/Port`` class. These each comprise of:

1. A [protocol](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols) defining the shape of the feature, and
2. a [default implementation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols#Providing-Default-Implementations) defining the behavior of the feature.

***Note that overriding these default implementations is not a supported way to use the extensions.***

Instead, you should subclass the ``MachBase/Mach/Port`` class and use multiple inheritance to select the extensions you wish to include in the subclass. For example, the below code snippet will create a class that inherits the default implementations from both ``MachBase/Mach/Port/Allocatable`` and ``MachBase/Mach/Port/Constructable``:

```swift
class CustomPort: Mach.Port, Mach.Port.Allocatable, Mach.Port.Constructable {}
```