# Architecture

## Context

### A brief summary

In Mach, a core concept is that of the **port**. While the actual ports are held in kernel space, they are exposed to **tasks** in user space by way of **port names**. Each task has a **port name space** which contains named **port rights**. More specifically, a task may hold one or more right to the underlying ports in the kernel. These ports are traditionally **message queues**, so two of the core rights are **send rights** and **receive rights**.

### Breaking it down

That was a lot of terms, and I'm sure it was quite confusing, so let's break it down!

1. The kernel holds **ports**.
2. These ports are traditionally **message queues**.
3. In user space, there are **tasks**.
4. Tasks may hold **port rights**, such as **send rights** or **receive rights**, to the underlying ports in the kernel.
5. Each right in a task is named by a **port name** (the wording discrepancy will make sense soon).
6. Each **port name** for a task's port rights exists in that task's **port name space**.

Additionally:

7. A task can hold more than right of a given type to a given port.
8. Port names are unique to tasks, and cannot be used across them.


### On "port names"

In many cases, some rights to the same port will carry the same name in a task's name space. Traditionally, if a task held both a send right and a receive right to a port, both rights would have the same name. In fact, if the task held multiple of each, they all would have the same name. While there are other rights (such as the **send one right**) which may be named differently, this name-sharing of the core rights makes the "port name" term make a bit more sense.

Additionally, the kernel provides access to certain **kernel objects** (or resources) through port names. A task can be given a send right to a specific port, with the name of that send right inserted into that task's name space. The task can then send messages to the port, using the send right's port name, to interact with the underlying object. In most cases, the task will be sending these message to the kernel itself to perform these operations on the resources.

## How this library handles ports, port rights, and tasks

An instance of the ``MachBase/Mach/Port`` class represents a port name in a given tasks's name space. The class called a "port" instead of a "port name" both for brevity and because port names are already more often referred to as "ports" by developers in user space. This is likely because many user space Mach API's use the type `mach_port_t` when expecting a port name (instead of the probably-more-appropriate `mach_port_name_t`).

While a given task will likely only ever interact with its own, the general concept of a task is one of the resources that the kernel exposes through a send right and port name. The ``MachBase/Mach/Task`` class represents a port name that names a send right for interacting with a given task. Brevity is again the reason why the class is simply named as a "task". This pattern of naming a class based on the resource it represents continues often throughout this library.

The concepts of ports, port rights, and tasks are tightly connected. As expressed before, a ``MachBase/Mach/Port`` is a port ``MachBase/Mach/Port/name`` in a given ``MachBase/Mach/Port/owningTask``'s name space. The port names such a name space are accessible as ``MachBase/Mach/Task/ports`` on an instance of the ``MachBase/Mach/Task`` class. Finally, the ``MachBase/Mach/Port/rights`` named by a port name are accessible from an instance of the ``MachBase/Mach/Port`` class.