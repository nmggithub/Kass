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
- ``reboot(options:)``

### Getting Info

- ``Mach/HostInfoFlavor``
- ``getInfo(_:as:)``

### Getting Statistics

- ``Mach/HostStatisticsFlavor``
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

- ``Darwin/lockgroup_info``
- ``lockGroupInfos``

### Managing Memory

- ``Mach/MemoryManager``
- ``getDefaultMemoryManager()``
- ``setDefaultMemoryManager(to:)``