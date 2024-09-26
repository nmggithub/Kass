# ``MachBase/Mach/Task``

Every port, or rather port name, is contained in a single task.

## Topics

### Getting flavored task ports

- ``Flavor``
- ``identityToken``

### Managing a task's lifecycle

- ``suspend()``
- ``resume()``
- ``terminate()``
- ``SuspensionToken``
- ``suspend2()``
- ``resume2(_:)``

### Inspecting a port

- ``InspectInfo``
- ``inspect(_:as:)``
- ``basicCounts``

### Managing info

- ``Info``
- ``getInfo(_:as:)``
- ``setInfo(_:to:)``

### Getting dyld info

- ``dyldInfo``
- ``DyldAllImageInfos``
- ``DyldImageInfo``
- ``AotImageInfo``
- ``DyldUUIDInfo``
- ``DyldPlatform``
- ``DyldError``
- ``DyldErrorKind``
- ``DyldImageMode``

### Getting other specific info

- ``basicInfo32``
- ``basicInfo32_2``
- ``basicInfo64``
- ``eventCounts``
- ``threadTimes``
- ``absoluteTimes``
- ``kernelMemoryInfo``
- ``securityToken``
- ``auditToken``
- ``affinityTagInfo``
- ``dyldInfo``
- ``basicInfo64_2``
- ``extmodInfo``
- ``basicInfo``
- ``powerInfo``
- ``powerInfoV2``
- ``vmInfo``
- ``vmPurgeableInfo``
- ``waitTimes``
- ``flags``

### Managing policy

- ``Policy``
- ``getPolicy(_:as:)``
- ``setPolicy(_:to:)``

### Managing specific policy

- ``categoryPolicy``
- ``setCategoryPolicy(_:)``
- ``SuppressionPolicy``
- ``suppressionPolicy``
- ``setSuppressionPolicy(_:)``
- ``PolicyState``
- ``policyState``
- ``qosPolicy``
- ``setQoSPolicy(_:)``
- ``setLatencyQoSPolicy(_:)``
- ``setThroughputQoSPolicy(_:)``

### Managing the task's role

- ``Role``
- ``role``
- ``setRole(_:)``

### Stashing ports

- ``stashedPorts``
- ``setStashedPorts(_:)``

### Managing special ports

- ``SpecialPort``
- ``getSpecialPort(_:as:)``
- ``setSpecialPort(_:to:)``

### Getting specific special ports

- ``MachBase/Mach/BootstrapPort``
- ``bootstrapPort``
- ``hostPort``
- ``debugPort``
- ``controlPort``
- ``namePort``
- ``inspectPort``
- ``readPort``

### Managing vouchers

- ``voucher``
- ``setVoucher(_:)``
- ``swapVoucher(with:)``

### Managing corpses

- ``Corpse``
- ``generateCorpse()``

### Setting the footprint limit

- ``setPhysicalFootprintLimit(_:)``

### Managing kernelcache objects

- ``kernelcacheData(of:as:)``
- ``kernelcacheData(of:)``