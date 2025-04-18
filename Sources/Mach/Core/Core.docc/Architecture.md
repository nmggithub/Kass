# ``Mach``

## A Brief Summary

In Mach, a core concept is that of the **port**. While the actual ports are held in kernel space, they are exposed to **tasks** in user space by way of **port names**. Each task has a **port name space** which contains named **port rights**. More specifically, a task may hold one or more rights to the underlying ports in the kernel. These ports are traditionally message queues, so two of the core rights are **send rights** and **receive rights**.

## Breaking it Down

1. The kernel holds **ports**.
2. These ports are traditionally message queues.
3. In user space, there are **tasks** (don't worry about what exactly those are for now).
4. Tasks may hold **port rights**, such as **send rights** or **receive rights**, to the underlying ports in the kernel.
5. Each right in a task is named by a **port name** (the wording discrepancy will make *some* sense soon).
6. Each **port name** for a task's port rights exists in that task's **port name space**.

Additionally:

7. A task can hold multiple **user references** to a given right.
8. Port names are unique to each task's name space, and cannot be used across tasks.


## On "Port Names"

In many cases, some rights to the same port will carry the same name in a task's name space. Traditionally, if a task held both a send right and a receive right to a port, both rights would have the same name. In fact, if the task held multiple references to each, they all would have the same name. This behavior of sharing names appears to still be the current behavior to this day. While there are other rights (such as the **send-once right**) which may be named differently, this name-sharing of the core rights makes the "port name" term make a bit more sense.