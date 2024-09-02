# ``MachPort``

A collection of classes for interacting with and manipulating Mach ports.

The XNU kernel provides many different concepts to userspace in the form of Mach ports. A Mach port is a reference to a set of rights in a given Mach task's namespace. Due to this, it could be more-correctly referred to as a "port name". However the "port" term is used here because it is simpler and more widely used amongst developers. This module provides a class, ``MachPort``, to represent these ports. Additional subclasses are provided for different kinds of ports.

The term "special port" applies to kernel-provided ports that are intended for specific purposes. Such ports cannot be allocated directly by the end user. This module provides the class ``MachSpecialPort`` to represent these special ports. The class is the same as a ``MachPort``, but with the allocating initializers marked as unavailable.

As a final note, most classes in this module inherit [`RawRepresentable`](https://developer.apple.com/documentation/swift/rawrepresentable) from the Swift standard library. The [associated `RawValue` type](https://developer.apple.com/documentation/swift/rawrepresentable/rawvalue-swift.associatedtype) for each class is often a type for lower-level representation of the same concept as the class itself. For example, the class ``MachPort`` has an associated `RawValue` type of [`mach_port_t`](https://developer.apple.com/documentation/driverkit/mach_port_t), which is a lower-level type provided to represent Mach ports. Due to this pattern, the adjective "raw" is regulary used throughout this documentation to refer to these lower-level types and their values.

## Topics

### Ports
- ``MachPort``

### Port rights
- ``MachPortRight``

### Special ports
- ``MachSpecialPort``

### Task special ports
- ``MachTaskSpecialPort``
- ``MachTaskSpecialPorts``
- ``MachTaskSpecialPortType``
- ``BootstrapPort``

### Port sets
Mach ports can be grouped into port sets. Each port set is referenced, itself, by a port. Ports that reference port sets contain the ``MachPortRight/portSet`` right.

- ``MachPortSet``

### Kernel objects
Each Mach port is underlain by a kernel object of a specific type (or no type).

- ``MachKernelObject``
- ``MachKernelObjectType``

### Mach tasks
Each Mach task has multiple representations, or "flavors". Each of these flavors have an associated kernel object type, and have varying levels of control over the task itself. The ``MachTaskFlavor/control`` flavor is the most powerful, and is often used to represent the task itself. The other flavors are used to represent limited scopes of control over the task.

- ``MachTask``
- ``MachTaskRead``
- ``MachTaskInspect``
- ``MachTaskName``
- ``MachTaskFlavor``