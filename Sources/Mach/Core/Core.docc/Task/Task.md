# ``Mach/Task``

Tasks are kernel objects that are exposed in user space through the use of ports. A port that exposes a task is known as a **task port**. However, not all task ports are created equal. Some may allow control over the task, while others may only provide a read-only view into limited information.

## Flavors

There are four different flavors of task port (in decreasing privilege level):

1. **task control ports** (``Mach/TaskControl``),
2. **task read ports** (``Mach/TaskRead``),
3. **task inspect ports** (``Mach/TaskInspect``), and
4. **task name ports** (``Mach/TaskName``).


Each of these classes inherit from ``Mach/Task``.

- Note: In most cases, this library will return task ports using one of the flavored subclasses above. However, there may be cases where the base ``Mach/Task`` class is used. In general, an instance of this base class implicitly represents a **control port**.

## Getting Flavored Task Ports

A task control port can be used to create a ``Mach/TaskIdentityToken`` (using the ``identityToken`` property, or the ``Mach/TaskIdentityToken/init(for:)`` initializer). This identity token can then be used to get task ports of the other flavors. Please see the documentation page for the task identity token for more information.

Alternatively, for the ``getSpecialPort(_:as:)`` API can be used. Please the documentation page for that function for more information on special ports.


## Flavor-Functionality Support Table
- Note: Most functionality is implemented on and around the base ``Mach/Task`` class, even functionality that not all flavors support. This is done to avoid having to implement the same behavior on multiple subclasses.

| Functionality | ``Mach/TaskControl`` | ``Mach/TaskRead`` | ``Mach/TaskInspect`` | ``Mach/TaskName`` |
| --- | --- | --- | --- | --- |
| Lifecycle Management     |||||
|  ``suspend()`` / ``resume()`` / ``terminate()`` / ``suspend2()`` / ``resume2(token:)``  | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| Thread Management      |||||
| ``threads`` | ✅ Yes | ✅ Yes  | ✅ Yes  | ❌ No |
| ``getDefaultThreadState(_:)`` | ✅ Yes | ✅ Yes  | ❌ No  | ❌ No |
| ``setDefaultThreadState(_:)`` | ✅ Yes | ❌ No  | ❌ No  | ❌ No |
| ``clearDefaultThreadState()`` | ✅ Yes | ❌ No  | ❌ No  | ❌ No |
| Managing Special Ports       |||||
| ``bootstrapPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``accessPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``hostPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``debugPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``controlPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``readPort`` | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| ``inspectPort`` | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| ``namePort`` | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| ``setSpecialPort(_:to:)`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| Managing Policy      |||||
| ``Mach/TaskPolicyManager/get(_:as:)`` | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| ``Mach/TaskPolicyManager/set(_:to:)`` | ✅ Yes |  ❌ No | ❌ No | ❌ No |
| Managing Roles      |||||
| ``role`` | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| ``setRole(to:)`` | ✅ Yes |  ❌ No | ❌ No | ❌ No |
| Getting Info      |||||
| ``info``* (see below) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| ``Mach/TaskInfoManager/dyldInfo`` | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| Other Functionality      |||||
| ``stashedPorts`` / ``stashPorts(_:)`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``inspectInfo`` | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| ``identityToken`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``ports`` | ✅ Yes | ❌ No | ❌ No | ❌ No |


## How Tasks Relate to Processes

Tasks are essentially analogous to processes, as [processes on macOS are implemented on top of Mach tasks.](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/Mach/Mach.html#:~:text=OS%20X%20processes%20and%20POSIX%20threads%20(pthreads)%20are%20implemented%20on%20top%20of%20Mach%20tasks%20and%20threads,%20respectively.)

It is possible to get a task port of a given flavor for a process with a given PID with the ``init(forPID:)`` initializer.

- Note: Retrieval of task _control_ ports are severely restricted in more recent versions of macOS and is generally only possible under very limited circumstances (such as getting the task control port for the calling process). Task read ports and task inspect ports are similarly restricted. However, task _name_ ports are generally unrestricted as they don't indicate any level of privilege over the task itself.

## Topics

### Getting Basic Info

- ``isCurrentTask``
- ``ports``
- ``pid``

### Getting Task Ports

- ``current``
- ``identityToken``
- ``Mach/TaskIdentityToken``
- ``init(forPID:)``

### Flavored Task Ports

- ``Mach/TaskFlavored``
- ``Mach/TaskFlavor``
- ``Mach/TaskControl``
- ``Mach/TaskRead``
- ``Mach/TaskInspect``
- ``Mach/TaskName``

### Lifecycle Management

- ``suspend()``
- ``resume()``
- ``terminate()``
- ``Mach/TaskSuspensionToken``
- ``suspend2()``
- ``resume2(token:)``

### Getting Info

- ``Mach/TaskInfoManager``
- ``Mach/TaskInfoFlavor``
- ``info``

### Inspecting Ports

- ``Mach/TaskInspectInfoManager``
- ``Darwin/task_inspect_flavor``
- ``inspectInfo``

### Managing Policy

- ``Mach/TaskPolicyManager``
- ``Mach/TaskPolicyFlavor``
- ``policy``

### Managing Task Roles

- ``Darwin/task_role``
- ``role``
- ``setRole(to:)``

### Stashing Ports

- ``stashedPorts``
- ``stashPorts(_:)``

### Getting Special Ports

- ``Mach/TaskSpecialPort``
- ``getSpecialPort(_:as:)``
- ``setSpecialPort(_:to:)``
- ``bootstrapPort``
- ``hostPort``
- ``debugPort``
- ``debugPort(forPID:)``
- ``controlPort``
- ``readPort``
- ``inspectPort``
- ``namePort``
- ``accessPort``

### Managing Corpses

- ``Mach/TaskCorpse``
- ``generateCorpse()``

### Thread Management

- ``threads``
- ``getDefaultThreadState(_:)``
- ``setDefaultThreadState(_:)``
- ``clearDefaultThreadState()``

### Managing Memory Limits

- ``setPhysicalFootprintLimit(_:)``

### Managing Virtual Memory

- ``vm``
- ``Mach/VirtualMemoryManager``

### Managing kernelcache Objects

- ``kernelcacheData(of:as:)``
- ``kernelcacheData(of:)``

### Managing Vouchers

- ``voucher``
- ``setVoucher(_:)``
- ``swapVoucher(with:)``

### Managing Exceptions

- ``swapExceptionPort(with:)``
- ``registerHardenedExceptionHandler(_:signedPCKey:)``