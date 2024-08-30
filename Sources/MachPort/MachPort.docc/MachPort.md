# ``MachPort``

A collection of classes for interacting with an manipulating Mach ports.

## Overview

The XNU kernel provides many different concepts to userspace in the form of Mach ports. These ports are often interacted with through the use of C-style API's. This module provides a helper class, ``MachPort``, that wraps a raw port reference (`mach_port_t`). Additional subclasses are provided for different kinds of ports.

## Topics

### Mach ports

A Mach port is a reference to a set of rights in a given Mach task's namespace. It could be more-correctly referred to as a "port name", but the "port" term is used here because it is simpler and more widely used.

- ``MachPort``

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