# ``Mach/KernelObjectType``

- Note: In some cases, a port with an underlying kernel object can be said to represent the kernel object itself and is referred to as the kernel object type instead of as a "port". However, in many cases (particularly those around tasks, threads, and hosts), the term "port" is still used to describe a port with an underlying kernel object.

## Topics

### The Absence of a Kernel Object  

- ``none``

### An Unknown Kernel Object

- ``unknown``

### Task-Related Ports

- ``taskControl``
- ``taskRead``
- ``taskInspect``
- ``taskName``
- ``taskIdToken``
- ``taskFatal``
- ``taskResume``

### Thread-Related Ports

- ``threadControl``
- ``threadRead``
- ``threadInspect``

### Host-Related Ports

- ``host``
- ``hostPriv``
<!-- - ``hostNotify`` -->
<!-- - ``hostSecurity`` -->

### Processor-Related Ports

- ``processor``
- ``pset``
- ``psetName``

### IOKit-Related Kernel Objects

- ``iokitConnect``
- ``iokitIdent``
- ``iokitObject``
- ``mainDevice``
- ``uextObject``

### Concurrency-Related Kernel Objects

- ``workInterval``
- ``eventlink``

### Memory-Related Kernel Objects

- ``memoryEntry``
- ``memoryObject``
<!-- - ``memObjControl`` -->

### Timing-Related Kernel Objects

- ``clock``
- ``semaphore``
- ``timer``

### Exception-Related Kernel Objects

- ``uxHandler``
- ``kcdata``

### Security-Based Kernel Objects

- ``exclavesResource``
- ``arcadeRegister``

### Notification-Based Kernel Objects

- ``undReply``

### Message-Related Kernel Objects
- ``voucher``
<!-- - ``mig`` -->

### Utility Ports

- ``substituteOnce``

### Other Basic Kernel Objects

- ``auditSession``
- ``fileport``
<!-- - ``setuidCredential`` -->

### Seemingly Unused Kernel Objects

- ``hypervisor``