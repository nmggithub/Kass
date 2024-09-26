# Calling the kernel

Kernel calls on Mach are often fundamentally different than those on other kernels.

Here's a fun fact: the vast majority of kernel calls in Mach are not system calls. More specifically, they do not directly interface with the CPU to enter "kernel mode" and run code before returning back to "user mode". So what do they do instead? They send **Mach messages** to the kernel.

As mentioned previously, user space on Mach is made up of tasks. The kernel actually has a task too, usually referred to as `kernel_task`. This is the tasks will be sending messages to when calling these kernel calls. Normally, though, these messages will be sent to kernel object ports, and not arbitrary message queues.

## Handling errors

In general, this library does not throw its own errors. It instead will throw any non-success codes by wrapping then in an error structure. The vast majority of the time, these codes are thrown using [MachError](https://developer.apple.com/documentation/foundation/macherror). However, due to the majority of kernel calls using the Mach messaging API, they can sometimes return an error code from the extended set of messaging return codes. These codes are not representable with [MachError](https://developer.apple.com/documentation/foundation/macherror), so they are thrown using [NSError](https://developer.apple.com/documentation/foundation/nserror) instead.

In general, any return codes that cannot be represented as a [MachError](https://developer.apple.com/documentation/foundation/macherror) will be thrown as a [NSError](https://developer.apple.com/documentation/foundation/nserror).