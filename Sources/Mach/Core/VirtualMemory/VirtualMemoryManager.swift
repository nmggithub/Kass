#if os(macOS)
    import Darwin.Mach
    import Foundation
    import KassC.VMPrivate
    import KassHelpers
    import Linking

    // MARK: - Virtual Memory Manager

    extension Mach {
        /// A virtual memory manager.
        /// - Warning: In some rare cases, the functions in this structure may simulate a kernel error. Please see the source code for more information.
        public struct VirtualMemoryManager {
            /// The task this manager is managing virtual memory for.
            public let task: Mach.Task

            /// Creates a new virtual memory manager.
            public init(task: Mach.Task) {
                self.task = task
            }

            /// Converts an unsafe raw pointer to a Mach VM address.
            internal static func unsafeRawPointerToMachVMAddress(_ pointer: UnsafeRawPointer?)
                throws
                -> mach_vm_address_t
            {
                guard let address = mach_vm_address_t(exactly: UInt(bitPattern: pointer)) else {
                    throw MachError(.invalidAddress)  // We simulate a kernel error here, and "invalidAddress" makes the most sense.
                }
                return address
            }

            /// Converts a Mach VM address to an unsafe raw pointer.
            internal static func machVMAddressToUnsafeRawPointer(_ address: mach_vm_address_t)
                throws
                -> UnsafeRawPointer?
            {
                guard let outAddress = UInt(exactly: address) else {
                    throw MachError(.failure)  // We simulate a kernel error here, and "failure" makes the most sense.
                }
                return UnsafeRawPointer(bitPattern: outAddress)
            }
        }
    }

    extension Mach.Task {
        /// The virtual memory manager for this task.
        public var vm: Mach.VirtualMemoryManager {
            Mach.VirtualMemoryManager(task: self)
        }
    }

    // MARK: - Flags

    extension Mach {
        /// Flags for virtual memory.
        public struct VMFlags: OptionSet, Sendable, KassHelpers.NamedOptionEnum {
            /// Represents a raw flag with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The name of the flag, if it can be determined.
            public let name: String?

            /// All known virtual memory flags.
            public static let allCases: [Self] = [
                .fixed, .anywhere, .purgable, .fourGBChunk, .randomAddress, .noCache,
                .resilientCodesign, .resilientMedia, .permanent, .trpo, .overwrite,
            ]

            /// The raw value of the flag.
            public var rawValue: Int32

            /// - Note the ``anywhere`` flag overrides this flag.
            public static let fixed = Self(name: "fixed", rawValue: VM_FLAGS_FIXED)

            public static let anywhere = Self(name: "anywhere", rawValue: VM_FLAGS_ANYWHERE)

            /// - Note: The apparent typo is copied from the original source.
            public static let purgable = Self(name: "purgable", rawValue: VM_FLAGS_PURGABLE)

            /// - Note: Case names cannot start with a number, so the number is spelled out.
            public static let fourGBChunk = Self(name: "fourGBChunk", rawValue: VM_FLAGS_4GB_CHUNK)

            public static let randomAddress = Self(
                name: "randomAddress", rawValue: VM_FLAGS_RANDOM_ADDR
            )

            public static let noCache = Self(name: "noCache", rawValue: VM_FLAGS_NO_CACHE)

            public static let resilientCodesign = Self(
                name: "resilientCodesign", rawValue: VM_FLAGS_RESILIENT_CODESIGN
            )

            public static let resilientMedia = Self(
                name: "resilientMedia", rawValue: VM_FLAGS_RESILIENT_MEDIA
            )

            public static let permanent = Self(name: "permanent", rawValue: VM_FLAGS_PERMANENT)

            public static let trpo = Self(name: "trpo", rawValue: VM_FLAGS_TPRO)

            public static let overwrite = Self(name: "overwrite", rawValue: VM_FLAGS_OVERWRITE)

            public static let superpageMask = Self(
                name: "superpageMask", rawValue: VM_FLAGS_SUPERPAGE_MASK
            )

            public static let returnDataAddress = Self(
                name: "returnDataAddress", rawValue: VM_FLAGS_RETURN_DATA_ADDR
            )

            public static let return4kDataAddress = Self(
                name: "return4kDataAddress", rawValue: VM_FLAGS_RETURN_4K_DATA_ADDR
            )
        }
    }
    // MARK: - Tags
    extension Mach {
        /// A tag for virtual memory.
        public struct VMTag: KassHelpers.NamedOptionEnum {
            /// Represents a raw tag with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The name of the tag, if it can be determined.
            public var name: String?

            /// The raw value of the tag.
            public let rawValue: Int32

            /// All known tags.
            public static let allCases: [Self] = [
                none, osfmk, bsd, iokit, libkern, oskext, kext, ipc, stack, cpu, pmap, pte, zone,
                kalloc, compressor, compressedData, phantomCache, waitq, diag, log, file, mbuf, ubc,
                security, mlock, reason, skywalk, ltable, hv, kallocData, retired, kallocType,
                triage,
                recount, exclaves,
            ]

            public static let none = Self(name: "none", rawValue: VM_KERN_MEMORY_NONE)

            public static let osfmk = Self(name: "osfmk", rawValue: VM_KERN_MEMORY_OSFMK)

            public static let bsd = Self(name: "bsd", rawValue: VM_KERN_MEMORY_BSD)

            public static let iokit = Self(name: "iokit", rawValue: VM_KERN_MEMORY_IOKIT)

            public static let libkern = Self(name: "libkern", rawValue: VM_KERN_MEMORY_LIBKERN)

            public static let oskext = Self(name: "oskext", rawValue: VM_KERN_MEMORY_OSKEXT)

            public static let kext = Self(name: "kext", rawValue: VM_KERN_MEMORY_KEXT)

            public static let ipc = Self(name: "ipc", rawValue: VM_KERN_MEMORY_IPC)

            public static let stack = Self(name: "stack", rawValue: VM_KERN_MEMORY_STACK)

            public static let cpu = Self(name: "cpu", rawValue: VM_KERN_MEMORY_CPU)

            public static let pmap = Self(name: "pmap", rawValue: VM_KERN_MEMORY_PMAP)

            public static let pte = Self(name: "pte", rawValue: VM_KERN_MEMORY_PTE)

            public static let zone = Self(name: "zone", rawValue: VM_KERN_MEMORY_ZONE)

            public static let kalloc = Self(name: "kalloc", rawValue: VM_KERN_MEMORY_KALLOC)

            public static let compressor = Self(
                name: "compressor", rawValue: VM_KERN_MEMORY_COMPRESSOR
            )

            public static let compressedData = Self(
                name: "compressedData", rawValue: VM_KERN_MEMORY_COMPRESSED_DATA
            )

            public static let phantomCache = Self(
                name: "phantomCache", rawValue: VM_KERN_MEMORY_PHANTOM_CACHE
            )

            public static let waitq = Self(name: "waitq", rawValue: VM_KERN_MEMORY_WAITQ)

            public static let diag = Self(name: "diag", rawValue: VM_KERN_MEMORY_DIAG)

            public static let log = Self(name: "log", rawValue: VM_KERN_MEMORY_LOG)

            public static let file = Self(name: "file", rawValue: VM_KERN_MEMORY_FILE)

            public static let mbuf = Self(name: "mbuf", rawValue: VM_KERN_MEMORY_MBUF)

            public static let ubc = Self(name: "ubc", rawValue: VM_KERN_MEMORY_UBC)

            public static let security = Self(
                name: "security", rawValue: VM_KERN_MEMORY_SECURITY
            )

            public static let mlock = Self(name: "mlock", rawValue: VM_KERN_MEMORY_MLOCK)

            public static let reason = Self(name: "reason", rawValue: VM_KERN_MEMORY_REASON)

            public static let skywalk = Self(name: "skywalk", rawValue: VM_KERN_MEMORY_SKYWALK)

            public static let ltable = Self(name: "ltable", rawValue: VM_KERN_MEMORY_LTABLE)

            public static let hv = Self(name: "hv", rawValue: VM_KERN_MEMORY_HV)

            public static let kallocData = Self(
                name: "kallocData", rawValue: VM_KERN_MEMORY_KALLOC_DATA
            )

            public static let retired = Self(name: "retired", rawValue: VM_KERN_MEMORY_RETIRED)

            public static let kallocType = Self(
                name: "kallocType", rawValue: VM_KERN_MEMORY_KALLOC_TYPE
            )

            public static let triage = Self(name: "triage", rawValue: VM_KERN_MEMORY_TRIAGE)

            public static let recount = Self(name: "recount", rawValue: VM_KERN_MEMORY_RECOUNT)

            public static let exclaves = Self(
                name: "exclaves", rawValue: VM_KERN_MEMORY_EXCLAVES
            )
        }
    }

    // MARK: - Allocation / Deallocation

    extension Mach.VirtualMemoryManager {
        /// Allocates a new virtual memory region in the task's address space.
        public func allocate(
            _ pointer: inout UnsafeRawPointer?,
            size: mach_vm_size_t,
            flags: Mach.VMFlags = []
        ) throws {
            var address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(mach_vm_allocate(self.task.name, &address, size, flags.rawValue))
            pointer = try Self.machVMAddressToUnsafeRawPointer(address)
        }

        /// Deallocates a virtual memory region in the task's address space.
        public func deallocate(
            _ pointer: UnsafeRawPointer?,
            size: mach_vm_size_t
        ) throws {
            let address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(mach_vm_deallocate(self.task.name, address, size))
        }
    }

    // MARK: - Protection / Inheritance

    extension Mach {
        /// An option for inheriting virtual memory.
        public struct VMInherit: KassHelpers.NamedOptionEnum {
            /// The name of the inheritance option, if it can be determined.
            public var name: String?

            /// Represents a virtual memory inheritance option with an optional name.
            public init(name: String?, rawValue: UInt32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the inheritance option.
            public let rawValue: UInt32

            /// All known virtual memory inheritance options.
            public static let allCases: [Self] = [
                .share, .copy, .none, .donateCopy,
            ]

            public static var share: Self { Self(name: "share", rawValue: VM_INHERIT_SHARE) }

            public static var copy: Self { Self(name: "copy", rawValue: VM_INHERIT_COPY) }

            public static var none: Self { Self(name: "none", rawValue: VM_INHERIT_NONE) }

            /// - Warning: This is an invalid inheritance option, but it is included for completeness.
            public static var donateCopy: Self {
                Self(name: "don", rawValue: VM_INHERIT_DONATE_COPY)
            }
        }

        /// Protection options for virtual memory.
        public struct VMProtectionOptions: OptionSet, KassHelpers.NamedOptionEnum {
            /// The name of the protection option, if it can be determined.
            public var name: String?

            /// Represents a virtual memory protection option with an optional name.
            public init(name: String?, rawValue: vm_prot_t) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the protection option.
            public let rawValue: vm_prot_t

            /// All known virtual memory protection options.
            public static let allCases: [Self] = [.none, .read, .write, .execute]

            public static var none: Self { Self(name: "none", rawValue: VM_PROT_NONE) }

            public static var read: Self { Self(name: "read", rawValue: VM_PROT_READ) }

            public static var write: Self { Self(name: "write", rawValue: VM_PROT_WRITE) }

            public static var execute: Self { Self(name: "execute", rawValue: VM_PROT_EXECUTE) }
        }
    }

    extension Mach.VirtualMemoryManager {
        /// Sets the inheritance of a virtual memory region in the task's address space.
        public func inherit(
            _ pointer: UnsafeRawPointer?,
            size: mach_vm_size_t,
            inherit: Mach.VMInherit
        ) throws {
            let address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(mach_vm_inherit(self.task.name, address, size, inherit.rawValue))
        }

        /// Sets the protection a virtual memory region in the task's address space.
        public func protect(
            _ pointer: UnsafeRawPointer?,
            size: mach_vm_size_t,
            setMaximum: Bool,
            protection: Mach.VMProtectionOptions
        ) throws {
            let address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(
                mach_vm_protect(
                    self.task.name, address, size, setMaximum ? 1 : 0, protection.rawValue)
            )
        }
    }

    // MARK: - Reading / Writing

    extension Mach.VirtualMemoryManager {

        /// Reads the contents of a virtual memory region in the task's address space into a
        /// new (potentially-specified) address in the current task's address space.
        public func read(
            from inPointer: UnsafeRawPointer?,
            size: mach_vm_size_t,
            into outPointer: UnsafeMutableRawPointer? = nil
        ) throws -> UnsafeRawBufferPointer {
            let address = try Self.unsafeRawPointerToMachVMAddress(inPointer)
            if let actualOutPointer = outPointer {
                let outAddress = try Self.unsafeRawPointerToMachVMAddress(actualOutPointer)
                var outSize: mach_vm_size_t = 0
                try Mach.call(
                    mach_vm_read_overwrite(
                        self.task.name, address, size,
                        outAddress, &outSize
                    )
                )
                guard let actualOutSize = Int(exactly: outSize) else {
                    throw MachError(.failure)  // We simulate a kernel error here, and "failure" makes the most sense.
                }
                return UnsafeRawBufferPointer(
                    start: actualOutPointer, count: actualOutSize
                )
            } else {
                var outAddress: vm_offset_t = 0
                var outSize: mach_msg_type_number_t = 0
                try Mach.call(mach_vm_read(self.task.name, address, size, &outAddress, &outSize))
                guard let actualOutSize = Int(exactly: outSize) else {
                    throw MachError(.failure)  // We simulate a kernel error here, and "failure" makes the most sense.
                }
                return UnsafeRawBufferPointer(
                    start: UnsafeRawPointer(bitPattern: outAddress), count: actualOutSize
                )
            }
        }

        /// Writes the contents of a buffer into a virtual memory region in the task's address space.
        public func write(
            to pointer: UnsafeRawPointer?,
            from buffer: UnsafeRawBufferPointer
        ) throws {
            let address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(
                mach_vm_write(
                    self.task.name, address,
                    UInt(bitPattern: buffer.baseAddress),
                    mach_msg_type_number_t(buffer.count)
                )
            )
        }
    }

    extension Mach.VirtualMemoryManager {
        /// Reads a value from a virtual memory region in the task's address space.
        public func read<T: BitwiseCopyable>(from inPointer: UnsafePointer<T>?) throws -> T {
            return try self.read(from: inPointer, size: mach_vm_size_t(MemoryLayout<T>.size))
                .load(as: T.self)
        }

        /// Writes a value into a virtual memory region in the task's address space.
        public func write<T: BitwiseCopyable>(_ value: T, to pointer: UnsafeMutablePointer<T>?)
            throws
        where T: BitwiseCopyable {
            try withUnsafeBytes(of: value) { valueBytes in
                try self.write(to: pointer, from: valueBytes)
            }
        }
    }

    extension Mach.VirtualMemoryManager {
        /// Reads a null-terminated string from a virtual memory region in the task's address space.
        public func readNullTerminatedString(
            from pointer: UnsafePointer<Int8>, encoding: String.Encoding
        ) throws -> String? {
            var walkingPointer = pointer
            var resultData = Data()
            while true {
                let byte = try self.read(from: walkingPointer)
                if byte == Int8(0) { break }
                resultData.append(UInt8(byte))
                walkingPointer = walkingPointer.advanced(by: 1)
            }
            return String(data: resultData, encoding: encoding)
        }
    }

    // MARK: - Copying / Mapping

    extension Mach {

        /// A memory entry represented by a Mach port.
        public class MemoryEntry: Mach.Port {
            /// A nil memory entry.
            public static override var Nil: MemoryEntry {
                MemoryEntry(named: mach_port_name_t(MACH_PORT_NULL))
            }

            /// Makes a new memory entry.
            public convenience init(
                task: Mach.Task = Mach.Task.current,
                parent: Mach.MemoryEntry = Mach.MemoryEntry.Nil,
                pointer: UnsafeRawPointer?,
                size: inout vm_size_t,
                protection: Mach.VMProtectionOptions
            ) throws {
                let address = vm_address_t(bitPattern: pointer)
                var port: mach_port_t = 0
                try Mach.call(
                    mach_make_memory_entry(
                        task.name, &size, address, protection.rawValue, &port, parent.name
                    )
                )
                self.init(named: port)
            }
        }
    }

    extension Mach.VirtualMemoryManager {

        /// Copies the contents of a virtual memory region in the task's address space into a pointer in the same task's address space.
        public func copy(
            from inBuffer: UnsafeRawBufferPointer,
            into outPointer: UnsafeMutableRawPointer? = nil
        ) throws {
            let inAddress = try Self.unsafeRawPointerToMachVMAddress(inBuffer.baseAddress)
            let outAddress = try Self.unsafeRawPointerToMachVMAddress(outPointer)
            guard let inSize = mach_vm_size_t(exactly: inBuffer.count) else {
                throw MachError(.failure)  // We simulate a kernel error here, and "failure" makes the most sense.
            }
            try Mach.call(mach_vm_copy(self.task.name, inAddress, inSize, outAddress))
        }

        /// Maps a memory entry into a virtual memory region in the task's address space.
        public func map(
            into pointer: inout UnsafeRawPointer?,
            size: mach_vm_size_t,
            mask: mach_vm_offset_t = 0,
            flags: Mach.VMFlags = [],
            entry: Mach.MemoryEntry,
            offset: memory_object_offset_t = 0,
            copy: Bool = false,
            currentProtection: Mach.VMProtectionOptions,
            maxProtection: Mach.VMProtectionOptions,
            inheritance: Mach.VMInherit
        ) throws {
            var address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(
                mach_vm_map(
                    self.task.name, &address, size, mask, flags.rawValue,
                    entry.name, offset, copy ? 1 : 0,
                    currentProtection.rawValue, maxProtection.rawValue, inheritance.rawValue
                )
            )
            pointer = try Self.machVMAddressToUnsafeRawPointer(address)
        }

        /// Re-maps a virtual memory region in the task's address space.
        public func remap(
            into pointerInTargetTask: inout UnsafeRawPointer?,
            size: mach_vm_size_t,
            mask: mach_vm_offset_t = 0,
            flags: Mach.VMFlags = [],
            fromTask sourceTask: Mach.Task = Mach.Task.current,
            fromPointer pointerInSourceTask: UnsafeRawPointer?,
            copy: Bool = false,
            inheritance: Mach.VMInherit
        )
            throws -> (
                currentProtection: Mach.VMProtectionOptions,
                maxProtection: Mach.VMProtectionOptions
            )
        {
            var targetAddress = try Self.unsafeRawPointerToMachVMAddress(pointerInTargetTask)
            let sourceAddress = try Self.unsafeRawPointerToMachVMAddress(pointerInSourceTask)
            let targetTask = self.task
            var rawCurrentProtection: vm_prot_t = 0
            var rawMaxProtection: vm_prot_t = 0
            try Mach.call(
                mach_vm_remap(
                    targetTask.name, &targetAddress, size, mask, flags.rawValue,
                    sourceTask.name, sourceAddress, copy ? 1 : 0,
                    &rawCurrentProtection, &rawMaxProtection, inheritance.rawValue
                )
            )
            pointerInTargetTask = try Self.machVMAddressToUnsafeRawPointer(targetAddress)
            return (
                currentProtection: Mach.VMProtectionOptions(rawValue: rawCurrentProtection),
                maxProtection: Mach.VMProtectionOptions(rawValue: rawMaxProtection)
            )
        }
    }

    // MARK: - Synchronization

    extension Mach {
        /// Virtual memory synchronization flags.
        public struct VMSyncFlags: OptionSet, KassHelpers.NamedOptionEnum {
            /// The name of the synchronization flag, if it can be determined.
            public var name: String?

            /// Represents a virtual memory synchronization flag with an optional name.
            public init(name: String?, rawValue: UInt32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the synchronization flag.
            public let rawValue: UInt32

            /// All known virtual memory synchronization flags.
            public static let allCases: [Self] = [
                .asynchronous, .synchronous, .invalidate, .killPages, .deactivate, .contiguous,
                .reusablePages,
            ]

            public static let asynchronous = Self(
                name: "asynchronous", rawValue: VM_SYNC_ASYNCHRONOUS)

            public static let synchronous = Self(name: "synchronous", rawValue: VM_SYNC_SYNCHRONOUS)

            public static let invalidate = Self(name: "invalidate", rawValue: VM_SYNC_INVALIDATE)

            public static let killPages = Self(name: "killPages", rawValue: VM_SYNC_KILLPAGES)

            public static let deactivate = Self(name: "deactivate", rawValue: VM_SYNC_DEACTIVATE)

            public static let contiguous = Self(name: "contiguous", rawValue: VM_SYNC_CONTIGUOUS)

            public static let reusablePages = Self(
                name: "reusablePages", rawValue: VM_SYNC_REUSABLEPAGES
            )

        }
    }

    extension Mach.VirtualMemoryManager {
        /// Synchronizes a virtual memory region in the task's address space.
        public func msync(
            _ pointer: UnsafeRawPointer?,
            size: mach_vm_size_t,
            flags: Mach.VMSyncFlags
        ) throws {
            let address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(mach_vm_msync(self.task.name, address, size, flags.rawValue))
        }
    }

    // MARK: - Paging Behavior

    extension Mach {
        /// A paging behavior for virtual memory.
        public struct VMBehavior: KassHelpers.NamedOptionEnum {
            /// The name of the behavior, if it can be determined.
            public var name: String?

            /// Represents a paging behavior with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the behavior.
            public let rawValue: Int32

            /// All known paging behaviors.
            public static let allCases: [Self] = []

            public static let `default` = VMBehavior(name: "default", rawValue: VM_BEHAVIOR_DEFAULT)

            public static let random = VMBehavior(name: "random", rawValue: VM_BEHAVIOR_RANDOM)

            public static let sequential = VMBehavior(
                name: "sequential", rawValue: VM_BEHAVIOR_SEQUENTIAL)

            public static let reverseSequential = VMBehavior(
                name: "reverseSequential", rawValue: VM_BEHAVIOR_RSEQNTL
            )

            public static let willNeed = VMBehavior(
                name: "willNeed", rawValue: VM_BEHAVIOR_WILLNEED)

            public static let dontNeed = VMBehavior(
                name: "dontNeed", rawValue: VM_BEHAVIOR_DONTNEED)

            public static let free = VMBehavior(name: "free", rawValue: VM_BEHAVIOR_FREE)

            public static let zeroWiredPages = VMBehavior(
                name: "zeroWiredPages", rawValue: VM_BEHAVIOR_ZERO_WIRED_PAGES
            )

            public static let reusable = VMBehavior(
                name: "reusable", rawValue: VM_BEHAVIOR_REUSABLE)

            public static let reuse = VMBehavior(name: "reuse", rawValue: VM_BEHAVIOR_REUSE)

            public static let canReuse = VMBehavior(
                name: "canReuse", rawValue: VM_BEHAVIOR_CAN_REUSE)

            public static let pageOut = VMBehavior(name: "pageOut", rawValue: VM_BEHAVIOR_PAGEOUT)

            public static let zero = VMBehavior(name: "zero", rawValue: VM_BEHAVIOR_ZERO)
        }
    }

    extension Mach.VirtualMemoryManager {
        /// Sets the paging behavior of a virtual memory region in the task's address space.
        public func setBehavior(
            _ pointer: UnsafeRawPointer?,
            size: mach_vm_size_t,
            behavior: Mach.VMBehavior
        ) throws {
            let address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(mach_vm_behavior_set(self.task.name, address, size, behavior.rawValue))
        }
    }

    // MARK: - Region Information

    extension Mach {
        /// A flavor of virtual memory region information.
        public struct VMRegionInfoFlavor: KassHelpers.NamedOptionEnum {
            /// The name of the flavor, if it can be determined.
            public var name: String?

            /// Represents a region info flavor with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the flavor.
            public let rawValue: Int32

            /// All known region info flavors.
            public static let allCases: [Self] = []

            public static let basic = VMRegionInfoFlavor(
                // `VM_REGION_BASIC_INFO` exists, but the kernel will always convert it
                // to `VM_REGION_BASIC_INFO_64`. So we might as well just use that.
                name: "basic", rawValue: VM_REGION_BASIC_INFO_64
            )

            public static let extended = VMRegionInfoFlavor(
                name: "extended", rawValue: VM_REGION_EXTENDED_INFO
            )

            public static let top = VMRegionInfoFlavor(
                name: "top", rawValue: VM_REGION_TOP_INFO
            )
        }
    }

    extension Mach.VirtualMemoryManager {
        /// Gets information about a virtual memory region in the task's address space.
        public func region<DataType>(
            _ pointer: inout UnsafeRawPointer?,
            flavor: Mach.VMRegionInfoFlavor,
            as type: DataType.Type = DataType.self
        ) throws -> (data: DataType, size: mach_vm_size_t) where DataType: BitwiseCopyable {
            var address = try Mach.VirtualMemoryManager.unsafeRawPointerToMachVMAddress(pointer)
            var size: mach_vm_size_t = 0
            let data = try Mach.callWithCountInOut(type: type) {
                array, count in
                var port: mach_port_t = 0  // We are purposely ignoring this.
                return mach_vm_region(
                    self.task.name, &address, &size, flavor.rawValue, array, &count,
                    // This port will always be set to nil, but we have to pass it anyway.
                    &port
                )
            }
            pointer = try Mach.VirtualMemoryManager.machVMAddressToUnsafeRawPointer(address)
            return (data: data, size: size)
        }
        /// Gets the size of a virtual memory region in the task's address space.
        public func regionSize(_ pointer: inout UnsafeRawPointer?) throws -> mach_vm_size_t {
            // We have to get a flavor to get the size, so we'll just get the basic info and ignore it.
            try self.region(&pointer, flavor: .basic, as: vm_region_basic_info_64.self).size
        }

        /// Gets basic information about a virtual memory region in the task's address space.
        public func regionBasicInfo(_ pointer: inout UnsafeRawPointer?) throws
            -> vm_region_basic_info_64
        {
            try self.region(&pointer, flavor: .basic).data
        }

        /// Gets extended information about a virtual memory region in the task's address space.
        public func regionExtendedInfo(_ pointer: inout UnsafeRawPointer?) throws
            -> vm_region_extended_info
        {
            try self.region(&pointer, flavor: .extended).data
        }

        /// Gets top information about a virtual memory region in the task's address space.
        public func regionTopInfo(_ pointer: inout UnsafeRawPointer?) throws -> vm_region_top_info {
            try self.region(&pointer, flavor: .top).data
        }

        /// Gets recursive information about a virtual memory region in the task's address space.
        public func regionRecurse(
            _ pointer: inout UnsafeRawPointer?, depth: inout UInt32
        ) throws -> (data: vm_region_submap_info_64_t, size: mach_vm_size_t) {
            var address = try Mach.VirtualMemoryManager.unsafeRawPointerToMachVMAddress(pointer)
            var size: mach_vm_size_t = 0
            let data = try Mach.callWithCountInOut(type: vm_region_submap_info_64_t.self) {
                array, count in
                return mach_vm_region_recurse(
                    self.task.name, &address, &size, &depth, array, &count
                )
            }
            pointer = try Mach.VirtualMemoryManager.machVMAddressToUnsafeRawPointer(address)
            return (data: data, size: size)
        }
    }

    // MARK: - Purgeable Control

    extension Mach {
        /// An operation for controlling purgeable objects.
        public struct VMPurgeable: KassHelpers.NamedOptionEnum {
            /// The name of the operation, if it can be determined.
            public var name: String?

            /// Represents a purgeable control operation with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the operation.
            public let rawValue: Int32

            /// All known purgeable control operations.
            public static let allCases: [Self] = [.getState, .setState, .purgeAll]

            public static let getState = VMPurgeable(
                name: "getState", rawValue: VM_PURGABLE_GET_STATE)

            public static let setState = VMPurgeable(
                name: "setState", rawValue: VM_PURGABLE_SET_STATE)

            public static let purgeAll = VMPurgeable(
                name: "purgeAll", rawValue: VM_PURGABLE_PURGE_ALL)
        }

        /// Debug flags for purgeable objects.
        public struct VMPurgeableDebugFlags: OptionSet, KassHelpers.NamedOptionEnum {
            /// The name of the flag, if it can be determined.
            public var name: String?

            /// Represents a purgeable debug flag with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the flag.
            public let rawValue: Int32

            /// All known purgeable debug flags.
            public static let allCases: [Self] = [.empty, .fault]

            public static let empty = Self(name: "empty", rawValue: VM_PURGABLE_DEBUG_EMPTY)

            public static let fault = Self(name: "fault", rawValue: VM_PURGABLE_DEBUG_FAULT)
        }

        /// A behavior for a purgeable object.
        public struct VMPurgeableBehavior: KassHelpers.NamedOptionEnum {
            /// The name of the behavior, if it can be determined.
            public var name: String?

            /// Represents a purgeable behavior with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the behavior.
            public let rawValue: Int32

            /// All known purgeable behaviors.
            public static let allCases: [Self] = [.fifo, .lifo]

            public static let fifo = Self(name: "fifo", rawValue: VM_PURGABLE_BEHAVIOR_FIFO)

            public static let lifo = Self(name: "lifo", rawValue: VM_PURGABLE_BEHAVIOR_LIFO)
        }

        /// An ordering for a purgeable object.
        public struct VMPurgeableOrdering: KassHelpers.NamedOptionEnum {
            /// The name of the ordering, if it can be determined.
            public var name: String?

            /// Represents a purgeable ordering with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the ordering.
            public let rawValue: Int32

            /// All known purgeable orderings.
            public static let allCases: [Self] = [.obsolete, .normal]

            public static let obsolete = Self(
                name: "obsolete", rawValue: VM_PURGABLE_ORDERING_OBSOLETE)

            public static let normal = Self(name: "normal", rawValue: VM_PURGABLE_ORDERING_NORMAL)
        }

        /// A base state value for a purgeable object.
        public struct VMPurgeableBaseState: KassHelpers.NamedOptionEnum {
            /// The name of the state, if it can be determined.
            public var name: String?

            /// Represents a purgeable base state with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the state.
            public let rawValue: Int32

            /// All known purgeable base states.
            public static let allCases: [Self] = []

            public static let nonVolatile = Self(
                name: "nonVolatile", rawValue: VM_PURGABLE_NONVOLATILE)

            public static let volatile = Self(name: "volatile", rawValue: VM_PURGABLE_VOLATILE)

            public static let empty = Self(name: "empty", rawValue: VM_PURGABLE_EMPTY)

            public static let deny = Self(name: "deny", rawValue: VM_PURGABLE_DENY)

        }

        /// A full state value for a purgeable object.
        public struct VMPurgeableState: RawRepresentable {
            /// The raw value of the state.
            public var rawValue: Int32

            /// Represents a raw purgeable state.
            public init(rawValue: Int32) {
                self.rawValue = rawValue
            }

            /// Wether or not the purgeable object cannot age.
            public var noAging: Bool {
                self.rawValue & VM_PURGABLE_NO_AGING_MASK == VM_PURGABLE_NO_AGING
            }

            /// The debug flags of the purgeable object.
            public var debug: VMPurgeableDebugFlags {
                VMPurgeableDebugFlags(rawValue: self.rawValue & VM_PURGABLE_DEBUG_MASK)
            }

            /// The volatile group number of the purgeable object.
            public var volatileGroup: Int32 {
                // The groups are simply numbered, so we don't need any special wrapper type.
                (self.rawValue & VM_VOLATILE_GROUP_MASK) >> VM_VOLATILE_GROUP_SHIFT
            }

            /// The behavior of the purgeable object.
            public var behavior: VMPurgeableBehavior {
                VMPurgeableBehavior(rawValue: self.rawValue & VM_PURGABLE_BEHAVIOR_MASK)
            }

            /// The ordering of the purgeable object.
            public var ordering: VMPurgeableOrdering {
                VMPurgeableOrdering(rawValue: self.rawValue & VM_PURGABLE_ORDERING_MASK)
            }

            /// The base state of the purgeable object.
            public var baseState: VMPurgeableBaseState {
                VMPurgeableBaseState(rawValue: self.rawValue & VM_PURGABLE_STATE_MASK)
            }
        }
    }

    extension Mach.VirtualMemoryManager {
        /// Controls a purgeable object in the task's address space.
        public func purgeableControl(
            _ pointer: UnsafeRawPointer?,
            control: Mach.VMPurgeable,
            state: inout Mach.VMPurgeableState
        ) throws {
            let address = try Mach.VirtualMemoryManager.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(
                mach_vm_purgable_control(self.task.name, address, control.rawValue, &state.rawValue)
            )
        }

        /// Gets the purgeable state of a purgeable object in the task's address space
        public func getPurgeableState(_ pointer: UnsafeRawPointer?) throws -> Mach.VMPurgeableState
        {
            var state = Mach.VMPurgeableState(rawValue: 0)
            try self.purgeableControl(pointer, control: .getState, state: &state)
            return state
        }

        /// Sets the purgeable state of a purgeable object in the task's address space
        public func setPurgeableState(
            _ pointer: UnsafeRawPointer?, to state: consuming Mach.VMPurgeableState
        ) throws {
            try self.purgeableControl(pointer, control: .setState, state: &state)
        }

        /// Purges all purgeable objects in the task's address space
        public func purgeAllPurgeableObjects() throws {
            var state = Mach.VMPurgeableState(rawValue: 0)  // We are purposely ignoring this.
            try self.purgeableControl(nil, control: .purgeAll, state: &state)
        }
    }

    // MARK: - Page Info

    extension Mach.VirtualMemoryManager {
        /// Gets information about a virtual memory page in the task's address space.
        public func pageInfo(_ pointer: UnsafeRawPointer?) throws -> vm_page_info_basic {
            let address = try Mach.VirtualMemoryManager.unsafeRawPointerToMachVMAddress(pointer)
            return try Mach.callWithCountInOut(type: vm_page_info_basic.self) {
                array, count in
                return mach_vm_page_info(
                    // `VM_PAGE_INFO_BASIC` is the only available info flavor, so we'll just use that.
                    self.task.name, address, VM_PAGE_INFO_BASIC, array, &count
                )
            }
        }
    }

    // MARK: - Wire

    // The function is in the headers, but attempting to use it that way results in a linker
    // error. We need to dynamically load it instead.
    typealias task_wire_f = @convention(c) (vm_map_t, boolean_t) -> kern_return_t
    private let task_wire: task_wire_f = libSystem().get(symbol: "task_wire")!.cast()

    extension Mach.VirtualMemoryManager {
        /// Requires (or does not require) future allocations in the task's address space to be wired.
        @available(macOS, deprecated: 14.5)
        public func wire(mustWire: Bool) throws {
            try Mach.call(task_wire(self.task.name, mustWire ? 1 : 0))
        }
    }

    extension Mach.Task {
        /// The host port for use with the `vm_wire` kernel call.
        fileprivate var hostForWire: Mach.Host {
            get throws {
                if #available(macOS 11.3, *) {
                    // On macOS 11.3 and later, the kernel only checks if the host port is non-nil.
                    return .init(named: 1)  // Any name besides zero is considered a non-nil name.
                } else {
                    // Prior to macOS 11.3, the kernel checks if the host port is actually the expected host port.
                    return try self.getSpecialPort(.host)
                }
            }
        }
    }

    extension Mach.VirtualMemoryManager {
        /// Wires (or unwires) a virtual memory region in the task's address space.
        /// - Warning: This function may make an additional kernel call. Errors from this
        /// call are also thrown. Please see the source code for more information.
        public func wire(
            _ pointer: UnsafeRawPointer?,
            size: mach_vm_size_t,
            protection: Mach.VMProtectionOptions
        ) throws {
            let address = try Mach.VirtualMemoryManager.unsafeRawPointerToMachVMAddress(pointer)
            let host = try self.task.hostForWire
            try Mach.call(
                mach_vm_wire(host.name, self.task.name, address, size, protection.rawValue)
            )
        }
    }

    // MARK: - Exec Lockdown

    // The function is in the headers, but attempting to use it that way results in a linker
    // error. We need to dynamically load it instead.
    typealias vm_map_exec_lockdown_f = @convention(c) (vm_map_t) -> kern_return_t
    private let vm_map_exec_lockdown: vm_map_exec_lockdown_f = libSystem()
        .get(symbol: "vm_map_exec_lockdown")!.cast()

    extension Mach.VirtualMemoryManager {
        /// Disallows any new executable code in the task's address space.
        public func execLockdown() throws {
            try Mach.call(vm_map_exec_lockdown(self.task.name))
        }
    }

    // MARK: - Deferred Reclamation

    typealias mach_vm_deferred_reclamation_buffer_init_f =
        @convention(c) (
            _ target_task: task_t,
            _ address: UnsafeMutablePointer<mach_vm_address_t>, _ size: mach_vm_size_t
        ) -> kern_return_t

    let mach_vm_deferred_reclamation_buffer_init: mach_vm_deferred_reclamation_buffer_init_f =
        libSystem().get(symbol: "mach_vm_deferred_reclamation_buffer_init")!
        .cast()

    typealias mach_vm_deferred_reclamation_buffer_synchronize_f =
        @convention(c) (
            _ target_task: task_t,
            _ num_entries_to_reclaim: mach_vm_size_t
        ) -> kern_return_t

    let mach_vm_deferred_reclamation_buffer_synchronize:
        mach_vm_deferred_reclamation_buffer_synchronize_f =
            libSystem().get(symbol: "mach_vm_deferred_reclamation_buffer_synchronize")!
            .cast()

    let mach_vm_deferred_reclamation_buffer_update_reclaimable_bytes:
        mach_vm_deferred_reclamation_buffer_update_reclaimable_bytes_f =
            libSystem().get(symbol: "mach_vm_deferred_reclamation_buffer_update_reclaimable_bytes")!
            .cast()

    typealias mach_vm_deferred_reclamation_buffer_update_reclaimable_bytes_f =
        @convention(c) (
            _ target_task: task_t,
            _ reclaimable_bytes: mach_vm_size_t
        ) -> kern_return_t

    extension Mach.VirtualMemoryManager {
        /// Initializes a deferred reclamation buffer in the task's address space.
        public func deferredReclamationBufferInit(
            _ pointer: inout UnsafeRawPointer?, size: mach_vm_size_t
        ) throws {
            var address = try Self.unsafeRawPointerToMachVMAddress(pointer)
            try Mach.call(mach_vm_deferred_reclamation_buffer_init(self.task.name, &address, size))
            pointer = try Self.machVMAddressToUnsafeRawPointer(address)
        }

        /// Synchronizes the deferred reclamation buffer in the task's address space.
        public func deferredReclamationBufferSynchronize(numberOfEntriesToReclaim: mach_vm_size_t)
            throws
        {
            try Mach.call(
                mach_vm_deferred_reclamation_buffer_synchronize(
                    self.task.name, numberOfEntriesToReclaim
                )
            )
        }

        /// Updates the reclaimable bytes in the deferred reclamation buffer in the task's address space.
        public func deferredReclamationBufferUpdate(
            reclaimableBytes: mach_vm_size_t
        ) throws {
            try Mach.call(
                mach_vm_deferred_reclamation_buffer_update_reclaimable_bytes(
                    self.task.name, reclaimableBytes
                )
            )
        }
    }

    // MARK: - Range Creation

    extension Mach.VirtualMemoryManager {
        public func createRange(recipes: consuming [mach_vm_range_recipe_v1_t]) throws {
            guard
                let size = UInt32(
                    exactly: recipes.count * MemoryLayout<mach_vm_range_recipe_v1_t>.stride
                )
            else {
                // We simulate a kernel error here, and "invalidArgument" makes the most sense (as such an error
                // is usually returned before any actual work is done, which is what's happening here).
                throw MachError(.invalidArgument)
            }
            mach_vm_range_create(
                // `MACH_VM_RANGE_FLAVOR_V1` is the only available flavor, so we'll just use that.
                self.task.name, .MACH_VM_RANGE_FLAVOR_V1, &recipes, size
            )
        }
    }

    extension mach_vm_range_flags_t {
        public static let none: mach_vm_range_flags_t = []
    }

    extension mach_vm_range_tag_t {
        public static let `default` = Self.MACH_VM_RANGE_DEFAULT

        public static let data = Self.MACH_VM_RANGE_DATA

        public static let fixed = Self.MACH_VM_RANGE_FIXED
    }

    extension mach_vm_range {
        public var minimumAddress: UnsafeRawPointer? {
            get {
                try? Mach.VirtualMemoryManager.machVMAddressToUnsafeRawPointer(self.min_address)
            }
            set {
                if newValue == nil {  // If the user passes nil explicitly, we set the address to 0.
                    self.min_address = 0
                } else if let address =  // Otherwise, we try to convert the address.
                    try? Mach.VirtualMemoryManager.unsafeRawPointerToMachVMAddress(newValue)
                {
                    // If the conversion is successful, we set the address to the converted value.
                    self.min_address = address
                }
                // If the conversion fails, we do nothing, leaving the address unchanged.
            }
        }

        public var maximumAddress: UnsafeRawPointer? {
            get {
                try? Mach.VirtualMemoryManager.machVMAddressToUnsafeRawPointer(self.max_address)
            }
            set {
                if newValue == nil {  // If the user passes nil explicitly, we set the address to 0.
                    self.max_address = 0
                } else if let address =  // Otherwise, we try to convert the address.
                    try? Mach.VirtualMemoryManager.unsafeRawPointerToMachVMAddress(newValue)
                {
                    // If the conversion is successful, we set the address to the converted value.
                    self.max_address = address
                }
                // If the conversion fails, we do nothing, leaving the address unchanged.
            }
        }
    }

    extension mach_vm_range_recipe_v1_t {
        public var vmTag: Mach.VMTag {
            get { return Mach.VMTag(rawValue: Int32(self.vm_tag)) }
            set { self.vm_tag = UInt8(newValue.rawValue) }
        }
    }
#endif  // os(macOS)
