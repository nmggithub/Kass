# ``MachPort``

A collection of classes for interacting with an manipulating Mach ports.

The XNU kernel provides many different concepts to userspace in the form of Mach ports. A Mach port is a reference to a set of rights in a given Mach task's namespace. It could be more-correctly referred to as a "port name", but the "port" term is used here because it is simpler and more widely used. This module provides a helper class, ``MachPort``, that wraps a raw port (`mach_port_t`). Additional subclasses are provided for different kinds of ports.

The term "special port" applies to extant ports that are intended for specific purposes and can be received from the kernel. Given these, these ports cannot be allocated or constructed. This module provides a specific class for these kinds of ports. A ``MachSpecialPort`` is the same as a ``MachPort``, but with the ``MachPort/allocate(right:name:in:)`` and ``MachPort/construct(queueLimit:flags:context:name:in:)`` class functions marked as unavailable.

## Topics

### Mach ports


- ``MachPort``  

### Special ports
- ``MachSpecialPort``
- ``BootstrapPort``

### Port sets

Mach ports can be grouped into port sets. Each port set is referenced, itself, by a port. Ports that reference port sets contain the ``MachPort/Right/portSet`` right.

- ``MachPortSet``

### Kernel object

Each Mach port is underlain by a kernel object of a specific type (or no type).

- ``KernelObject``
- ``KernelObjectType``

### Mach tasks

Each Mach task has multiple representations, or "flavors". Each of these flavors have an associated kernel object type, and have varying levels of control over the task itself. The ``MachTaskFlavor/control`` flavor is the most powerful, and is often used to represent the task itself. The other flavors are used to represent limited scopes of control over the task.

- ``MachTask``
- ``MachTaskRead``
- ``MachTaskInspect``
- ``MachTaskName``
- ``MachTaskFlavor``