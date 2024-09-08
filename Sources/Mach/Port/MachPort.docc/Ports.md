# Ports

Ports in Mach are a bit of a strange beast. Some weird naming conventions still stick around and can cause confusion to many. I'm not even sure I understand it correctly myself but this article is my best understanding of how it works.

## `mach_port_t`

The type `mach_port_t` is defined differently in user space and kernel space. In kernel space, it refers to the actual port. However, ports themselves are not accessible directly in user space. In userspace, `mach_port_t` is aliased to an unsigned integer. But why?

## Namespaces and `mach_port_name_t`

In userspace, the `mach_port_t` type is joined by the `mach_port_name_t` type. In fact, they're both aliased to unsigned integers, and appear to be used interchangably. Why? Because, in userspace, each task has it's own namespace. Or "port namespace". Or "port right namspace". The documentation doesn't really use consistent terminiology to refer to it.

In general, though, Mach tasks can hold certain rights to underlying Mach ports. Each right is referred to by a name: an unsigned integer. This is what `mach_port_t` (and, I guess, more accurately `mach_port_name_t`) refer to in userspace. If I had to guess why there are two different definitions, it's that `mach_port_t` is used in cases where the function prototypes are linked in both kernel space and user space. As the concept of a "port name" (or, more accurately, a "port right name") doesn't exist in kernel space, the original authors of Mach may have been trying to avoid from having `mach_port_name_t` showing up in kernel code. However, the confusion of having `mach_port_name_t` in kernel space they were trying to avoid just ends up moving to user space, where it's confusing to have `mach_port_t`.

## What's in a name?

So, in userspace:

- We have a `mach_port_t` which isn't actually a port,
- so `mach_port_name_t` is more accurate (except it's more of a "port right name" but I guess `mach_port_right_name_t` was considered too unweildy), and
- task's have "port (right) namespaces" where each port right has a unique(*) name.

Oh, what's that asterisk you ask?

> All send and receive rights to a given port in a given port name space will have the same port name.
> Mach 3 Kernel Principles
> http://www.shakthimaan.com/downloads/hurd/kernel_principles.pdf

I mean, I guess that makes things easier. And also that particular document uses the "port name" and "port name space" term and avoids that "port right name" and "port right name space" terms. But it also refers to "*ports rights*" being named by "*port* names". Argh!

## What's a library author to do?

To simplify things, this library considers a task's namespace to contain "port names". The concept of a "port right name" doesn't really exist here (and as it seems to also be largely absent in first-party documentation on Mach, I think it's the right interpretation). The ``Mach/Port`` class represents the broad concept of a port, containing the `name` property to refer to the port's name, as well as the computed `rights` property to refer to the rights named by the `name` property. A ``Mach/Port`` is not the port itself, as we are still in user space. However it's named as such for brevity and because it is conceptually more than just the `name` property (especially as it becomes subclassed).