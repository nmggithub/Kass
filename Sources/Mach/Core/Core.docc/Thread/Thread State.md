# ``Mach/ThreadStateManager``

- Warning: Functionality listed here only reflects what was available on the machine that generated this documentation and may not reflect what is available in *your* environment. Please visit the source code for more accurate information.

## Topics

### Creating a Thread State Manager

- ``init(thread:)``

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