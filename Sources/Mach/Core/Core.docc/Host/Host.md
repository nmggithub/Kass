# ``Mach/Host``

- Warning: The vast majority of functionality for hosts requires a privileged host port.

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

### Getting Special Ports

- ``Mach/HostSpecialPort``
- ``getSpecialPort(_:as:)``
- ``setSpecialPort(_:to:)``
- ``hostPort``
- ``hostPortPrivileged``

### Getting Lock Groups

- ``Mach/LockGroupInfo``
- ``lockGroupInfos``

### Managing Memory

- ``Mach/MemoryManager``
- ``getDefaultMemoryManager()``
- ``setDefaultMemoryManager(_:)``