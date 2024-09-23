# Using ports

This library provides the ``MachBase/Mach/Port`` class, and its many subclasses, to help with interacting with ports.

## The port class

An instance of the ``MachBase/Mach/Port`` class represents a port ``MachBase/Mach/Port/name`` in a given ``MachBase/Mach/Port/owningTask``'s name space. The class called a "port" instead of a "port name" both for brevity and because port names are already more often referred to as "ports" by developers in user space. This is likely because many user space Mach API's use the term "port" more often than "port name" and also use the type `mach_port_t` when expecting a port name (instead of the probably-more-appropriate `mach_port_name_t`). This is likely due to the original authors of Mach wanting to keep function names and prototypes relatively consistent between user space and kernel space.

## The task class

While a given task will likely only ever interact with its own, the general concept of a task is one of the resources that the kernel exposes through a send right and port name. The ``MachBase/Mach/Task`` class represents a port name that names a send right for interacting with a given task. Brevity is again the reason why the class is simply named as a "task".

## Other kernel objects

The ``MachBase/Mach/KernelObject`` class can be used to get information about the kernel object underlying a given port name. Specifically, the ``MachBase/Mach/KernelObject/init(underlying:)`` initializer will create a representation of the underlying kernel object.

## How this library uses port names

The ``MachBase/Mach/Port/init(named:in:)`` initializer can be used to represent a port for which a name is already known:

```swift
let port = Mach.Port(named: portName)
```

While this initializer is extremely helpful, it will often not be needed when using this library. This is because the library uses the choice of the "port" moniker as an opportunity to abstract out the idea of port names entirely.  The vast majority of the time, this library will call this initializer internally and only expose an instance of the ``MachBase/Mach/Port`` class (or one of its subclasses). However, the underlying ``MachBase/Mach/Port/name`` will still be available on the class instance.