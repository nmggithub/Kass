# ``BSD/KernelDebug``

The BSD kernel provides an API for debug messages and events in the kernel.

## Topics

### Timestamps

- ``usingContinuousTime``
- ``timestamp``
- ``timestampFromAbsolute(_:)``
- ``timestampFromContinuous(_:)``

### Tracing

- ``isTracingEnabled(_:)``
- ``trace(_:args:)``
- ``trace(_:stringID:string:)``

### Signposting

- ``signpost(_:name:args:)``
- ``signpostStart(_:name:args:)``
- ``signpostEnd(_:name:args:)``