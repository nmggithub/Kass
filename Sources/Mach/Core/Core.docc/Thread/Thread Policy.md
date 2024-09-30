# ``Mach/ThreadPolicyManager``

## Topics

### Creating a Thread Policy Manager

- ``init(thread:)``

### General Operations

 - ``get(_:as:)``
 - ``set(_:to:)``


### Managing Policy

- ``extendedPolicy``
- ``setExtendedPolicy(to:)``
- ``timeConstraintPolicy``
- ``setTimeConstraintPolicy(to:)``
- ``precedencePolicy``
- ``setPrecedencePolicy(to:)``
- ``affinityPolicy``
- ``setAffinityPolicy(to:)``
- ``latencyQoSPolicy``
- ``setLatencyQoSPolicy(to:)``
- ``throughputQoSPolicy``
- ``setThroughputQoSPolicy(to:)``

### Managing Policy (Private API)

- ``Mach/ThreadPolicyState``
- ``policyState``
- ``Mach/ThreadQoSPolicy``
- ``qosPolicy``
- ``setQoSPolicy(to:)``
- ``Mach/ThreadTimeConstraintWithPriorityPolicy``
- ``timeConstraintWithPriorityPolicy``
- ``setTimeConstraintWithPriorityPolicy(to:)``
- ``Mach/ThreadRequestedQoSPolicy``
- ``requestedQoSPolicy``