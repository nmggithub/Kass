# ``MachBase/Mach/KernelObject/ObjectType``

Traditionally, Mach ports are just message queues. While this is still technically true in some sense, there may be a kernel object underlying the port which is handling these messages. These kernel objects allow for user space tasks to control certain kernel structures by sending messages to the ports that they underlie.

In some cases, these ports can be said to represent the kernel object itself and are referred to as the kernel object type instead of as a "port". However, in many cases (particularly those around tasks, threads, and hosts), the term "port" is still used to describe a port with an underlying kernel object.

## Topics

### The absence of a kernel object  

- ``none``

### An unknown kernel object

- ``unknown``

### Task-related ports

- ``taskControl``
- ``taskRead``
- ``taskInspect``
- ``taskName``
- ``taskIdToken``
- ``taskFatal``
- ``taskResume``

### Thread-related ports

- ``threadControl``
- ``threadRead``
- ``threadInspect``

### Host-related ports

- ``host``
- ``hostPriv``
- ``hostNotify``
- ``hostSecurity``

### Processor-related ports

- ``processor``
- ``pset``
- ``psetName``

### IOKit-related kernel objects

- ``iokitConnect``
- ``iokitIdent``
- ``iokitObject``
- ``mainDevice``
- ``uextObject``

### Concurrency-related kernel objects

- ``workInterval``
- ``eventlink``

### Memory-related kernel objects

- ``memoryEntry``
- ``memoryObject``
- ``memObjControl``

### Timing-related kernel objects

- ``clock``
- ``semaphore``
- ``timer``

### Exception-related kernel objects

- ``uxHandler``
- ``kcdata``

## Security-based kernel objects

- ``exclavesResource``
- ``arcadeRegister``

## Notification-based kernel objects

- ``undReply``

## Message-related kernel objects
- ``voucher``
- ``mig``

### Utility ports

- ``substituteOnce``

### Other basic kernel objects

- ``auditSession``
- ``fileport``
- ``setuidCredential``

### Seemingly unused kernel objects

- ``hypervisor``