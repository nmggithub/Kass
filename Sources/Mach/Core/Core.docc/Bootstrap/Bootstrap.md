# The Bootstrap Server

The bootstrap server is a task for obtaining send rights to specific services.

Ports, and the rights named for them, are primarily meant for cross-task communication. In order to do so though, the task holding a receive right needs to provide other tasks with send rights so that they can communicate with it. However this is difficult on modern macOS without help from the kernel. Alternatively, there is the **bootstrap server**.

The bootstrap server can be sent messages to discover (and obtain send rights to) **services**. A send right to the bootstrap server can be obtained by any task through the ``Mach/Task/bootstrapPort`` property. They can then send messages to the bootstrap server to discover services by name and obtain send rights to them. Note that most communication with the bootstrap server uses a private API, so use the functions provided here with caution.

### Service Ports and Connection Ports

On macOS, the bootstrap server is provided by the init system. The kernel provides the functionality for two specific types of ports, **service ports** and **connections ports**, to be used and constructed by the init system. However, there are some limitations in place at the kernel level that makes it difficult for other tasks to use them.

Service ports are limited to only be constructable by the init system, and connection ports require an existing service port to be constructed. Due to this, neither are likely usable outside the init system. Regardless, functions for constructing both are provided here for more complete coverage of the kernel API's available in user space.

## Topics

### Core Concepts

- ``Mach/BootstrapPort``
- ``Mach/PortInitializableByServiceName``

### Service-Related Ports

- ``Mach/ServicePort``
- ``Mach/ConnectionPort``