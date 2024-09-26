# ``Mach/Task/init(forPID:)``

When this function is used on the base class, it will attempt to get and return a control port. When it is used on a flavored subclass, it will attempt to get a port of that flavor and return it.

```swift
// base class
let port1 = try Mach.Task(forPID: somePid) // gets a task control port
// flavored subclasses
let port2 = try Mach.TaskControl(forPID: somePid) // gets a task control port
let port3 = try Mach.TaskRead(forPID: somePid) // gets a task read port
let port4 = try Mach.TaskInspect(forPID: somePid) // gets a task inspect port
let port5 = try Mach.TaskName(forPID: somePid) // gets a task name port
```

- Warning: The kernel calls to get task _read_ ports and task _inspect_ ports for given PIDs are implemented in the BSD layer of the kernel. Thus, in those cases, this function will throw a [`POSIXError`](https://developer.apple.com/documentation/foundation/posixerror) instead of a [`MachError`](https://developer.apple.com/documentation/foundation/macherror) when encountering an non-success return code from the kernel.