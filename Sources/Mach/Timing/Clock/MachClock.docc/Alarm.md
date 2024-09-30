# ``MachCore/Mach/Alarm``

An alarm is just a port which the kernel will send a message to at the specified time.

Normally, the kernel will be the only task sending a message to an alarm. However, the mechanism it uses to do so is exposed in user space. To simulate an alarm reply from the kernel, use the ``reply(returning:time:type:)`` function.

## Topics

### Allocating Alarm Ports

- ``allocate(name:onClock:after:)``
- ``allocate(name:onClock:at:)``
- ``Mach/TimeType``
- ``allocate(name:onClock:time:type:)``

### Simulating a Reply

- ``reply(returning:time:type:)``