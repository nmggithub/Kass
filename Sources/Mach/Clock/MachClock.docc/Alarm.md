# ``MachBase/Mach/Clock/Alarm``

An alarm is just a port which the kernel will send a message to at the specified time.

Normally, the kernel will be the only task sending a message to an alarm. However, the mechanism it uses to do so is exposed in user space. To simulate an alarm reply from the kernel, use the ``reply(returning:time:type:)`` function.