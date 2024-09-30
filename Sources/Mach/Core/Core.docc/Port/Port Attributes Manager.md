# ``Mach/PortAttributeManager``

## Topics

### Creating an Attribute Manager

- ``init(port:)``

### General Operations

 - ``get(_:as:)``
 - ``set(_:to:)``
 - ``assert(_:is:)``

### Managing Specific Attributes

- ``Mach/PortAttributeFlavor``
- ``limits``
- ``setLimits(to:)``
- ``status``
- ``requestTableCount``
- ``setRequestTableCount(to:)``
- ``setWillChangeOwner()``
- ``setIsImportanceReceiver()``
- ``setIsDeNapReceiver()``
- ``info``
- ``assertGuard(is:)``