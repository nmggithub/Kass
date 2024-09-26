# Using ports

This library provides the ``MachBase/Mach/Port`` class, and its many subclasses, to help with interacting with ports.

## The port class

An instance of the ``MachBase/Mach/Port`` class represents a port ``MachBase/Mach/Port/name`` in a given ``MachBase/Mach/Port/owningTask``'s name space. The class is called a "port" instead of a "port name" both for brevity and because port names are already more often referred to as "ports" by developers in user space. This is likely because the user space Mach API's use the term "port" more often than "port name" and also more often use the type `mach_port_t` when expecting a port name (instead of the probably-more-appropriate `mach_port_name_t`). This is likely due to the original authors of Mach wanting to keep function names and prototypes relatively consistent between user space and kernel space.

## Kernel objects

The kernel also provides access to certain **kernel objects** (or resources) through port names. A task can be given a send right to a specific port (with the name of that send right inserted into that task's name space). The task can then send messages to the port, using the send right's port name, to interact with the underlying object. In most cases, the task will be sending these messages to the kernel itself to perform operations on the underlying resources.

### The task class

The general concept of a task is one of the resources that the kernel exposes through a send right and port name. The ``MachBase/Mach/Task`` class represents a port name that names a send right for interacting with a given task. Brevity is again the reason why the class is simply named as a "task" and not a "task port".

### Other kernel objects

The ``MachBase/Mach/KernelObject`` class can be used to get information about the kernel object underlying a given port name. Specifically, the ``MachBase/Mach/KernelObject/init(underlying:)`` initializer will create a representation of the underlying kernel object.

## Using port names

The ``MachBase/Mach/Port/init(named:in:)`` initializer can be used to represent a port for which a name is already known:

```swift
let port = Mach.Port(named: portName)
```

While this initializer is extremely helpful, it will often not be needed when using this library. This is because the library uses the choice of the "port" moniker as an opportunity to abstract out the idea of port names entirely.  The vast majority of the time, this library will call this initializer internally and only expose an instance of the ``MachBase/Mach/Port`` class (or one of its subclasses). However, the underlying ``MachBase/Mach/Port/name`` will still be available on the class instance.

## Allocating new ports

New ports can be allocated through the ``MachBase/Mach/Port/init(right:named:in:)`` initializer. This will allocate a port in the kernel and put a name for the specified port right in the given task's name space. A desired port name can also be specified. If one is not specified, the kernel will generate a name.

## Constructing new ports

Starting around OS X Mavericks, a new way of creating ports was introduced. This is referred to as "constructing" a port and can be done through the ``MachBase/Mach/Port/init(options:context:in:)`` initializer. This way of creating ports is much more advanced and mainly used internally. Nonetheless, it is still exposed in user space headers.

For some more specific examples:
- a ``MachBase/Mach/ServicePort`` can be constructed with the ``MachBase/Mach/ServicePort/init(_:domainType:context:in:limits:flags:)`` initializer, and
- a ``MachBase/Mach/ConnectionPort`` can be constructed with the ``MachBase/Mach/ConnectionPort/init(for:context:in:limits:flags:)`` initializer.

However, constructing a ``MachBase/Mach/ServicePort`` is only possible from the init system and constructing a ``MachBase/Mach/ConnectionPort`` requires a service port, so neither of these specific examples will likely be usable by most. However, they are still both included in this library for more complete coverage of the kernel API's.