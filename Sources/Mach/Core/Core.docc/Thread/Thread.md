# ``Mach/Thread``

- Warning: Functionality listed here only reflects what was available on the machine that generated this documentation and may not reflect what is available in *your* environment. Please visit the source code for more accurate information.

## Topics

### Getting Info

- ``Mach/ThreadInfoManager``
- ``Mach/ThreadInfoFlavor``
- ``info``


### Creating Threads

- ``init(inTask:)``

### Getting Thread Ports

- ``current``

### Flavored Thread Ports

- ``Mach/ThreadFlavor``
- ``Mach/ThreadFlavored``
- ``Mach/ThreadControl``
- ``Mach/ThreadRead``
- ``Mach/ThreadInspect``

### Lifecycle Management

- ``suspend()``
- ``resume()``
- ``abort(safely:)``
- ``terminate()``

### Switching Threads

- ``Mach/ThreadSwitchOption``
- ``switch(to:option:timeout:)``
- ``abortDepression()``

### Managing Memory

- ``wire(in:)``
- ``unwire(in:)``

### Managing State

- ``Mach/ThreadState``
- ``get(state:)``
- ``set(state:)``
- ``Mach/Task/get(defaultThreadState:)``
- ``Mach/Task/set(defaultThreadState:)``

### Managing Policy

- ``Mach/ThreadPolicyManager``
- ``Mach/ThreadPolicyFlavor``
- ``policy``

### Getting Special Ports

- ``Mach/ThreadSpecialPort``
- ``getSpecialPort(_:as:)``
- ``setSpecialPort(_:to:)``
- ``controlPort``
- ``readPort``
- ``inspectPort``

### Managing Vouchers

- ``voucher``
- ``setVoucher(_:)``
- ``swapVoucher(with:)``

### Managing Exceptions

- ``swapExceptionPort(with:)``