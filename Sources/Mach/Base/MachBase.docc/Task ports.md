# Task ports

Task ports come in several "flavors", each with their own abilities.

As mentioned previously, tasks are kernel objects that are exposed in user space through the use of ports. A port that exposes a task is known as a **task port**. However, not all task ports are created equal. Some may allow control over the task, while others may only provide a read-only view into limited information.

## Flavors of task port

There are four different flavors of task port (in decreasing privilege level):

1. **task control ports** (``MachBase/Mach/TaskControl``),
2. **task read ports** (``MachBase/Mach/TaskRead``),
3. **task inspect ports** (``MachBase/Mach/TaskInspect``), and
4. **task name ports** (``MachBase/Mach/TaskName``).

Note that all of the flavored task port classes inherit from ``MachBase/Mach/Task``. All functionality is implemented on and around the ``MachBase/Mach/Task`` class, even functionality that not all flavors support. **This is done intentionally.** The main purpose of the different flavored task port classes is to differentiate ports, not to provide flavor-specific functionality.

This provides an easier experience, as there is no need to cast a base ``MachBase/Mach/Task`` instance to a flavored instance in order to use any part of this library's API. However, please note that attempting to use functionality not supported by the specific task port flavor may result in an error from the kernel.

In most cases, this library will return task ports using the flavored subclasses. However, there may be cases where an instance of the base ``MachBase/Mach/Task`` class is returned (or expected as a parameter for a function or initializer). In general, an instance of thebase ``MachBase/Mach/Task`` class implicitly represents a **control port**.

## Getting different flavors of task port

A task control port can be used to create a ``MachBase/Mach/TaskIdentityToken`` (using the ``MachBase/Mach/Task/identityToken`` property, or the ``MachBase/Mach/TaskIdentityToken/init(for:)`` initializer). This identity token can then be used to get task ports of the other flavors. Please see the documentation page for the task identity token for more information.

Alternatively, for the ``MachBase/Mach/Task/getSpecialPort(_:as:)`` API can be used. Please the documentation page for that function for more information on special ports.


## Flavor-functionality support table

| Functionality | ``MachBase/Mach/TaskControl`` | ``MachBase/Mach/TaskRead`` | ``MachBase/Mach/TaskInspect`` | ``MachBase/Mach/TaskName``|
| --- | --- | --- | --- | --- |
| Lifecycle management     |||||
|  ``MachBase/Mach/Task/suspend()`` / ``MachBase/Mach/Task/resume()`` / ``MachBase/Mach/Task/terminate()`` / ``MachBase/Mach/Task/suspend2()`` / ``MachBase/Mach/Task/resume2(_:)``  | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| Managing special ports       |||||
| ``MachBase/Mach/Task/getSpecialPort(_:as:)``* | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| ``MachBase/Mach/Task/bootstrapPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``MachBase/Mach/Task/hostPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``MachBase/Mach/Task/debugPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``MachBase/Mach/Task/controlPort`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``MachBase/Mach/Task/readPort`` | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| ``MachBase/Mach/Task/inspectPort`` | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| ``MachBase/Mach/Task/namePort`` | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| ``MachBase/Mach/Task/setSpecialPort(_:to:)`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| Managing policy      |||||
| ``MachBase/Mach/Task/getPolicy(_:as:)`` | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| ``MachBase/Mach/Task/setPolicy(_:to:)`` | ✅ Yes |  ❌ No | ❌ No | ❌ No |
| Getting info      |||||
| ``MachBase/Mach/Task/getInfo(_:as:)``* | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| ``MachBase/Mach/Task/dyldInfo`` | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| ``MachBase/Mach/Task/inspect(_:as:)`` | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No |
| Other functionality      |||||
| ``MachBase/Mach/Task/stashedPorts`` / ``MachBase/Mach/Task/setStashedPorts(_:)`` | ✅ Yes | ❌ No | ❌ No | ❌ No |
| ``MachBase/Mach/Task/identityToken`` | ✅ Yes | ❌ No | ❌ No | ❌ No |


## How do tasks relate to processes?

Tasks are essentially analogous to processes, as [processes on macOS are implemented on top of Mach tasks.](https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/Mach/Mach.html#:~:text=OS%20X%20processes%20and%20POSIX%20threads%20(pthreads)%20are%20implemented%20on%20top%20of%20Mach%20tasks%20and%20threads,%20respectively.)

It is possible to get a task port of a given flavor for a process using that process's PID using the ``MachBase/Mach/Task/for(pid:)`` function.

## Additional notes on flavored task ports

- **Task control ports** are severely restricted in more recent versions of macOS are are only retrievable under very limited circumstances (such as getting the task control port for the calling process).
- **Task name ports** are generally unrestricted as they don't indicate any level of privilege over the task itself.