# ``MachBase/Mach/Task/for(pid:)``

When this function is used on the base class, it will attempt to get and return a control port. When it is used on a flavored subclass, it will attempt to get a port of that flavor and return it.

```swift
// base class
let port1 = try Mach.Task.for(pid: somePid) // gets a task control port
// flavored subclasses
let port2 = try Mach.TaskControl.for(pid: somePid) // gets a task control port
let port3 = try Mach.TaskRead.for(pid: somePid) // gets a task read port
let port4 = try Mach.TaskInspect.for(pid: somePid) // gets a task inspect port
let port5 = try Mach.TaskName.for(pid: somePid) // gets a task name port
```

- Warning: The kernel calls to get **task read ports** and **task inspect ports** for a given PID are implemented in the BSD layer of the kernel. Thus, in those cases, this function throws [`POSIXError`](https://developer.apple.com/documentation/foundation/posixerror) instead of [`MachError`](https://developer.apple.com/documentation/foundation/macherror).