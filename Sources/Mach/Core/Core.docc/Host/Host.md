# ``Mach/Host``

- Important: The vast majority of functionality for hosts requires a privileged host port.

## Topics

### Getting Hosts

- ``current``

### Getting Basic Info

- ``kernelVersion``
- ``pageSize``
- ``bootInfo``
- ``isPrivileged``

### Getting Processors

- ``processors``
- ``processorSets``

### Rebooting the Host

- ``Mach/HostRebootOption``
- ``reboot(_:)``

### Getting Info

- ``Mach/HostInfo``
- ``getInfo(_:as:)``

### Getting Statistics

- ``Mach/HostStatistics``
- ``getStatistics(_:as:)``

### Making Kext Requests

- ``kextRequest(_:)``

### Getting Lock Groups

- ``Mach/LockGroup``
- ``lockGroups``

### Managing Memory

- ``Mach/MemoryManager``
- ``getDefaultMemoryManager()``
- ``setDefaultMemoryManager(_:)``
