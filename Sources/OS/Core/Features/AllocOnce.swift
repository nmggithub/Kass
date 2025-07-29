import Darwin
@preconcurrency import KassC.AllocOnceImpl
import KassC.AllocOncePrivate
import KassHelpers

extension OS {
    // A unique token for once-allocated memory.
    public typealias AllocToken = os_alloc_token_t

    /// A slot for once-allocated memory.
    public typealias _AllocOnceSlot = _os_alloc_once_s

    /// Allocates memory once, optionally initializing it with a function.
    public static func _allocOnce(
        _ slot: inout _AllocOnceSlot,
        size: size_t,
        initFunction: Function? = nil
    ) -> UnsafeMutableRawPointer? {
        return _os_alloc_once(&slot, size, initFunction)
    }
}

extension OS {
    /// An allocation key for once-allocated memory.
    public struct AllocOnceKey: KassHelpers.NamedOptionEnum {
        /// The name of the key, if it can be determined.
        public var name: String?

        /// Represents a allocation key with an optional name.
        public init(name: String?, rawValue: Int32) {
            self.name = name
            self.rawValue = rawValue
        }

        /// The raw value of the key.
        public let rawValue: Int32

        /// All known allocation keys.
        public static let allCases: [Self] = [
            // Known keys
            .libsystemNotify, .libxpc, .libsystemC, .libsystemInfo, .libsystemNetwork, .libcache,
            .libCommonCrypto, .libdispatch, .libdyld, .libkeymgr, .liblaunch, .libmacho,
            .osTrace, .libsystemBlocks, .libsystemMalloc, .libsystemPlatform, .libsystemPthread,
            .libsystemStats, .libsecinit, .libsystemCoreServices, .libsystemSymptoms,
            .libsystemPlatformASL, .libsystemFeatureFlags,

            // Reserved keys
            .reserved0, .reserved1, .reserved2, .reserved3, .reserved4,
            .reserved5, .reserved6, .reserved7, .reserved8, .reserved9,

            // Maximum key
            .max,
        ]

        public static let libsystemNotify =
            Self(name: "libsystem_notify", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_NOTIFY)

        public static let libxpc =
            Self(name: "libxpc", rawValue: OS_ALLOC_ONCE_KEY_LIBXPC)

        public static let libsystemC =
            Self(name: "libsystem_c", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_C)

        public static let libsystemInfo =
            Self(name: "libsystem_info", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_INFO)

        public static let libsystemNetwork =
            Self(name: "libsystem_network", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_NETWORK)

        public static let libcache =
            Self(name: "libcache", rawValue: OS_ALLOC_ONCE_KEY_LIBCACHE)

        public static let libCommonCrypto =
            Self(name: "libCommonCrypto", rawValue: OS_ALLOC_ONCE_KEY_LIBCOMMONCRYPTO)

        public static let libdispatch =
            Self(name: "libdispatch", rawValue: OS_ALLOC_ONCE_KEY_LIBDISPATCH)

        public static let libdyld =
            Self(name: "libdyld", rawValue: OS_ALLOC_ONCE_KEY_LIBDYLD)

        public static let libkeymgr =
            Self(name: "libkeymgr", rawValue: OS_ALLOC_ONCE_KEY_LIBKEYMGR)

        public static let liblaunch =
            Self(name: "liblaunch", rawValue: OS_ALLOC_ONCE_KEY_LIBLAUNCH)

        public static let libmacho =
            Self(name: "libmacho", rawValue: OS_ALLOC_ONCE_KEY_LIBMACHO)

        public static let osTrace =
            Self(name: "os_trace", rawValue: OS_ALLOC_ONCE_KEY_OS_TRACE)

        public static let libsystemBlocks =
            Self(name: "libsystem_blocks", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_BLOCKS)

        public static let libsystemMalloc =
            Self(name: "libsystem_malloc", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_MALLOC)

        public static let libsystemPlatform =
            Self(name: "libsystem_platform", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_PLATFORM)

        public static let libsystemPthread =
            Self(name: "libsystem_pthread", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_PTHREAD)

        public static let libsystemStats =
            Self(name: "libsystem_stats", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_STATS)

        public static let libsecinit =
            Self(name: "libsecinit", rawValue: OS_ALLOC_ONCE_KEY_LIBSECINIT)

        public static let libsystemCoreServices =
            Self(name: "libsystem_coreservices", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_CORESERVICES)

        public static let libsystemSymptoms =
            Self(name: "libsystem_symptoms", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_SYMPTOMS)

        public static let libsystemPlatformASL =
            Self(name: "libsystem_platform_asl", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_PLATFORM_ASL)

        public static let libsystemFeatureFlags =
            Self(
                name: "libsystem_feature_flags", rawValue: OS_ALLOC_ONCE_KEY_LIBSYSTEM_FEATUREFLAGS)

        public static let reserved0 =
            Self(name: "reserved0", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_0)
        public static let reserved1 =
            Self(name: "reserved1", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_1)
        public static let reserved2 =
            Self(name: "reserved2", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_2)
        public static let reserved3 =
            Self(name: "reserved3", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_3)
        public static let reserved4 =
            Self(name: "reserved4", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_4)
        public static let reserved5 =
            Self(name: "reserved5", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_5)
        public static let reserved6 =
            Self(name: "reserved6", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_6)
        public static let reserved7 =
            Self(name: "reserved7", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_7)
        public static let reserved8 =
            Self(name: "reserved8", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_8)
        public static let reserved9 =
            Self(name: "reserved9", rawValue: OS_ALLOC_ONCE_KEY_RESERVED_9)

        public static let max =
            Self(name: "max", rawValue: OS_ALLOC_ONCE_KEY_MAX)
    }

    /// A table of once-allocated memory.
    public struct _AllocOnceTable {
        public static let rawTable = _os_alloc_once_table

        /// Returns the allocation slot for the given key.
        public static subscript(key: AllocOnceKey) -> _AllocOnceSlot? {
            withUnsafeBytes(of: rawTable) { ptr in
                guard
                    key.rawValue < AllocOnceKey.max.rawValue,
                    let tableAsPointer =
                        ptr.baseAddress?.assumingMemoryBound(to: _AllocOnceSlot.self)
                else { return nil }
                return tableAsPointer[Int(key.rawValue)]
            }
        }
    }
}
