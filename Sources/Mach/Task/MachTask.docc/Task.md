# ``MachBase/Mach/Task``

## Topics

### Getting flavored task ports

- ``Flavor``
- ``identityToken``

### Getting threads

- ``threads``

### Managing a tasks's lifecycle

- ``suspend()``
- ``resume()``
- ``terminate()``
- ``SuspensionToken``
- ``suspend2()``
- ``resume2(_:)``

### Managing info

- ``Info``
- ``getInfo(_:as:)``
- ``setInfo(_:to:)``

### Getting specific info

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

- ``setStashedPorts(_:)``
- ``getStashedPorts()``

### Managing special ports

- ``SpecialPort``
- ``getSpecialPort(_:as:)``
- ``setSpecialPort(_:to:)``

### Getting specific special ports

- ``MachBase/Mach/BootstrapPort``
- ``bootstrapPort``

### Managing vouchers

- ``voucher``
- ``setVoucher(_:)``
- ``swapVoucher(with:)``

### Managing corpses

- ``Corpse``
- ``generateCorpse()``

### Setting the footprint limit

- ``setPhysicalFootprintLimit(_:)``

### Managing dyld info

- ``Dyld``
- ``dyld``

### Managing kernelcache objects

- ``kernelcacheData(of:as:)``
- ``kernelcacheData(of:)``