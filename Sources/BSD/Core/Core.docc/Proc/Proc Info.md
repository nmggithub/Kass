# ``BSD/Proc``

This structure combines multiple helper functions into a single API.

```swift
import BSDCore

// `proc_listpids` equivalent
BSD.Proc.listPIDs([...])

// `proc_pidinfo` equivalent
BSD.Proc(pid: [...]).info([...])

// `proc_pidfdinfo` equivalent
BSD.Proc(pid: [...]).fd([...]).info([...])

// `proc_pidfileportinfo` equivalent
BSD.Proc(pid: [...]).fileport([...]).info([...])
```

It also provides direct access to the `proc_info` system call that underlies all of these functions.

## Topics

### Listing PID's
- ``listPIDs(_:)``
- ``BSD/ProcPIDListDescription``
- ``BSD/ProcPIDListType``

### Calling the System Call

- ``BSD/Proc/info(forPID:call:flavor:arg:buffer:extendedID:)``
- ``BSD/ProcInfoCall``
- ``BSD/ProcInfoExtendedID``

### Getting Information by PID

- ``init(pid:)``
- ``pid``
- ``BSD/ProcPIDInfoFlavor``
- ``info(flavor:arg:buffer:)``
- ``info(flavor:arg:bufferPointer:)``
- ``info(flavor:arg:returnAs:)``
- ``info(flavor:arg:returnAsArrayOf:count:)``

### Getting Information by PID and FD

- ``fd(_:)``
- ``BSD/ProcPIDFD``
- ``BSD/ProcPIDFDInfoFlavor``

### Getting Information by PID and Fileport

- ``BSD/Fileport``
- ``fileport(_:)``
- ``BSD/ProcPIDFileport``
- ``BSD/ProcPIDFileportInfoFlavor``

### Controlling The Current Process

- ``setControl(flavor:arg:buffer:)``
- ``BSD/ProcSetControlFlavor``
- ``setSelfControlState(_:)``
- ``BSD/ProcControlState``
- ``setSelfAsVirtualMemoryResourceOwner()``
- ``selfSetDelayIdleSleep(_:)``

### Others

- ``getKernelMessageBuffer(largeBuffer:)``