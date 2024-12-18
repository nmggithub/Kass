# ``MachCore``

The core module for interacting with the Mach kernel.

@Metadata {
    @TitleHeading("Module")
}

## Licenses

> Warning: Portions of the source code for this module are covered under license. Please view the source code and the below licenses for more information.
>
> - <doc:APSL>
> - <doc:MachLicense>

> Warning: This library is _first and foremost_ a **reverse-engineering toolkit.** It is meant to provide a safer and easier way to interface with low-level API's when performing security research.
>
> Any other use, such as in user-facing apps, is **not recommended** and _**heavily discouraged.**_

> Important: When used in a file that also imports the `System` framework, the `Mach` from that framework may conflict with the `Mach` from this module. In these cases `MachCore.Mach` may be used like so:
>```swift
> import MachCore
> import System // Also includes a `Mach`
>
> // May compile, but editors may provide incorrect syntax highting / code completion.
> Mach.[...]
> // Fully qualifies the access. Better editor support.
> MachCore.Mach.[...]
>```
>
> While use of `MachCore.Mach` may not be required when `System` is also imported, it is recommended.
>
> Where the `System` framework is ***not*** imported, use of `Mach` is recommended over `MachCore.Mach`.


## Topics

### The Kernel

- ``Mach``
- <doc:Bootstrap>

### Core Concepts

- ``Mach/Task``
- ``Mach/Thread``
- ``Mach/Port``
- ``Mach/Message``


### Additional Concepts

- ``Mach/Host``
- ``Mach/Processor``
- ``Mach/ProcessorSet``

### Timing

- ``Mach/Clock``
- ``Mach/ClockControl``
- ``Mach/Alarm``
- ``Mach/Timer``
- ``Mach/Semaphore``
- ``Darwin/mach_timespec``

### Others API's

- <doc:Exceptions>
- <doc:Vouchers>

### Calling the Kernel

- ``Mach/call(_:)``

### Licenses

- <doc:APSL>
- <doc:MachLicense>