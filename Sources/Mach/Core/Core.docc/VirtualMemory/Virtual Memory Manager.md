# ``Mach/VirtualMemoryManager``

## Topics

### Flags and Tags

- ``Mach/VMFlags``
- ``Mach/VMTag``

### Creating a Virtual Memory Manager

- ``init(task:)``
- ``task``

### Allocating and Deallocating Memory

- ``allocate(_:size:flags:)``
- ``deallocate(_:size:)``

### Setting Protection and Inheritance Properties of Memory

- ``Mach/VMInherit``
- ``inherit(_:size:inherit:)``
- ``Mach/VMProtectionOptions``
- ``protect(_:size:setMaximum:protection:)``

### Reading and Writing Memory

- ``read(from:size:into:)``
- ``write(to:from:)``

### Copying and Mapping Memory

- ``Mach/MemoryEntry``
- ``copy(from:into:)``
- ``map(into:size:mask:flags:entry:offset:copy:currentProtection:maxProtection:inheritance:)``
- ``remap(into:size:mask:flags:fromTask:fromPointer:copy:inheritance:)``

### Synchronizing Memory

- ``Mach/VMSyncFlags``
- ``msync(_:size:flags:)``

### Managing Paging Behavior

- ``Mach/VMBehavior``
- ``setBehavior(_:size:behavior:)``

### Getting Region Information

- ``Mach/VMRegionInfoFlavor``
- ``region(_:flavor:as:)``
- ``regionSize(_:)``
- ``regionBasicInfo(_:)``
- ``regionExtendedInfo(_:)``
- ``regionTopInfo(_:)``
- ``regionRecurse(_:depth:)``

### Managing Purgeable Objects

- ``Mach/VMPurgeable``
- ``Mach/VMPurgeableDebugFlags``
- ``Mach/VMPurgeableBehavior``
- ``Mach/VMPurgeableOrdering``
- ``Mach/VMPurgeableBaseState``
- ``Mach/VMPurgeableState``
- ``purgeableControl(_:control:state:)``
- ``getPurgeableState(_:)``
- ``setPurgeableState(_:to:)``
- ``purgeAllPurgeableObjects()``

### Getting Page Information

- ``pageInfo(_:)``

### Wiring Memory

- ``wire(mustWire:)``
- ``wire(_:size:protection:)``

### Locking Down Executable Memory

- ``execLockdown()``

### Creating Ranges

- ``createRange(recipes:)``
- ``Darwin/mach_vm_range_flags_t``
- ``Darwin/mach_vm_range_tag_t``
- ``Darwin/mach_vm_range``
- ``Darwin/mach_vm_range_recipe_v1_t``