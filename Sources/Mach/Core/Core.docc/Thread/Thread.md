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

### Getting State

- ``Mach/ThreadStateFlavor``
- ``getState(_:as:)``
- ``setState(_:to:)``

### Getting General State

- ``generalState``
- ``armState32``
- ``armState64``

### Getting Exception State

- ``exceptionState``
- ``armExceptionState32``
- ``armExceptionState64``

### Getting Debug State

- ``debugState``
- ``armDebugState32``
- ``armDebugState32Legacy``
- ``armDebugState64``

### Getting Other State

- ``armPageInState``
- ``armVFPState``
- ``floatState``
- ``pageInState``

### Getting ARM NEON State (macOS 15+, Experimental)

- ``ARMNEONState32``
- ``ARMNEONState64``
- ``armNEONState64``
- ``armNEONState32``

### Managing Policy

- ``Mach/ThreadPolicyFlavor``
- ``getPolicy(_:as:)``
- ``setPolicy(_:to:)``
- ``extendedPolicy``
- ``setExtendedPolicy(_:)``
- ``timeConstraintPolicy``
- ``setTimeConstraintPolicy(_:)``
- ``precedencePolicy``
- ``setPrecedencePolicy(_:)``
- ``affinityPolicy``
- ``setAffinityPolicy(_:)``
- ``latencyQoSPolicy``
- ``setLatencyQoSPolicy(_:)``
- ``throughputQoSPolicy``
- ``setThroughputQoSPolicy(_:)``

### Managing Policy (Private API)

- ``Mach/ThreadPolicyState``
- ``policyState``
- ``Mach/ThreadQoSPolicy``
- ``qosPolicy``
- ``setQoSPolicy(_:)``
- ``Mach/ThreadTimeConstraintWithPriorityPolicy``
- ``timeConstraintWithPriorityPolicy``
- ``setTimeConstraintWithPriorityPolicy(_:)``
- ``Mach/ThreadRequestedQoSPolicy``
- ``requestedQoSPolicy``

### Getting Special Ports

- ``Mach/ThreadSpecialPort``
- ``getSpecialPort(_:as:)``
- ``setSpecialPort(_:to:)``
- ``controlPort``
- ``readPort``
- ``inspectPort``