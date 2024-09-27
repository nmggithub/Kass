# ``Mach/KernelObject``

The kernel provides access to certain **kernel objects** (or resources) through port names. A task can be given a send right to a specific port (with the name of that send right inserted into that task's name space). The task can then send messages to the port, using the send right's port name, to interact with the underlying object. In most cases, the task will be sending these messages to the kernel itself to perform operations on the underlying resources.

- Note: This class can be used to inspect the type of the underlying kernel object for a port. It **cannot** be used to interact with the kernel objects themselves. Please use the ports themselves for that behavior.