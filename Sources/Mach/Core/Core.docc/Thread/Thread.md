# ``Mach/Thread``

- Warning: Functionality listed here only reflects what was available on the machine that generated this documentation and may not reflect what is available in *your* environment. Please visit the source code for more accurate information.

## Topics

## Getting Info

### Getting Info

- ``Mach/ThreadInfoFlavor``
- ``getInfo(_:as:)``
- ``basicInfo``
- ``identifyingInfo``
- ``extendedInfo``
- ``timesharingInfo``
- ``roundRobinInfo``


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

- ``Mach/ThreadStateFlavor``
- ``getState(_:as:)``
- ``setState(_:to:)``

### Managing General State

- ``generalState``
- ``setGeneralState(to:)``
- ``armState32``
- ``setARMState32(to:)``
- ``armState64``
- ``setARMState64(to:)``

### Managing Exception State

- ``exceptionState``
- ``setExceptionState(to:)``
- ``armExceptionState32``
- ``setARMExceptionState32(to:)``
- ``armExceptionState64``
- ``setARMExceptionState64(to:)``

### Managing Debug State

- ``debugState``
- ``setDebugState(to:)``
- ``armDebugState32``
- ``setARMDebugState32(to:)``
- ``armDebugState32Legacy``
- ``setARMDebugState32Legacy(to:)``
- ``armDebugState64``
- ``setARMDebugState64(to:)``

### Managing Other State

- ``armVFPState``
- ``setARMVFPState(to:)``
- ``floatState``
- ``pageInState``
- ``armPageInState``

### Getting ARM NEON State (macOS 15+, Experimental)

- ``ARMNEONState32``
- ``ARMNEONState64``
- ``armNEONState64``
- ``armNEONState32``

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