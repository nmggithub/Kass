# Exceptions

Exceptions are raised in the Mach kernel by sending messages to exception ports.

- Note: While many parts of the exception API involve the usage of flags and the like that indicate specific behavior, the ultimate behavior of any exception handler most often comes down to whatever the task with the receive right to the exception ports does with the messages it receives. That task may choose to ignore the flags and other indicators supplied to it and instead implement its own behavior. Do not take any part of this API as a guarantee of behavior.

## Topics

### Exception Ports

- ``Mach/ExceptionPort``

### Managing Exception Ports

- ``Mach/PortWithExceptionPorts``

### Exception Utilities

- ``Mach/ExceptionBehavior``
- ``Mach/ExceptionType``
- ``Mach/ExceptionMask``

### Exception Messages

- ``Mach/DefaultExceptionMessage``