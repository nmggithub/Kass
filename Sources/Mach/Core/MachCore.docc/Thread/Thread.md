# ``Mach/Thread``

## Topics

## Getting Info

### Getting Info

- ``Mach/ThreadInfo``
- ``getInfo(_:as:)``
- ``basicInfo``
- ``identifyingInfo``
- ``extendedInfo``
- ``timesharingInfo``
- ``roundRobinInfo``


### Creating Threads

- ``init(in:)``

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

### Switching Threads

- ``Mach/ThreadSwitchOption``
- ``switch(to:option:timeout:)``
- ``abortDepression()``

### Managing Memory

- ``wire(in:)``
- ``unwire(in:)``

### Getting State

- ``Mach/ThreadState``
- ``getState(_:as:)``
- ``setState(_:to:)``

### Managing Policy

- ``Mach/ThreadPolicy``
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