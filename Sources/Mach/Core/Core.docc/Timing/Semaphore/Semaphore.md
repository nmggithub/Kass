# ``Mach/Semaphore``

## Topics

### Creating Semaphores

- ``init(inTask:policy:value:)``
- ``Mach/SemaphorePolicy``

### Getting Basic Info

- ``policy``
- ``semaphoreOwningTask``

### Operations

- ``signal(all:)``
- ``signal(_:)``
- ``wait(timeout:)``
- ``wait(forSemaphore:thenSignalSemaphore:timeout:)``
- ``destroy()``