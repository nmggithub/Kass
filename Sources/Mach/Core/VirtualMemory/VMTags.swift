#if os(macOS)
    import Darwin.Mach
    import Foundation
    import KassC.VMPrivate
    import KassHelpers
    import Linking

    extension Mach {
        /// MARK: - Tags

        /// A tag for virtual memory.
        public struct VMTag: KassHelpers.NamedOptionEnum {
            // C-level helper functions.
            private struct C: KassHelpers.Namespace {
                @available(macOS, introduced: 26.0)
                static let mach_vm_tag_describe:
                    @convention(c) (_ tag: UInt32) -> UnsafePointer<CChar> =
                        libSystem.get(symbol: "mach_vm_tag_describe")!.cast()
            }
            /// Represents a raw user memory tag with an optional name.
            public init(name: String?, rawValue: Int32) {
                self.rawValue = rawValue
                self.name = name  // Computed properties must be assigned after stored properties.
            }

            private var _name: String? = nil

            /// The name of the tag, if it can be determined.
            public var name: String? {
                get {
                    if #available(macOS 26.0, *) {
                        return String(cString: C.mach_vm_tag_describe(UInt32(self.rawValue)))
                    } else {
                        return _name
                    }
                }
                set { _name = newValue }
            }

            /// The raw value of the tag.
            public let rawValue: Int32

            /// All known tags.
            public static let allCases: [Self] = [
                untagged, malloc, mallocSmall, mallocLarge, mallocHuge, sbrk, realloc,
                mallocTiny, mallocLargeReusable, mallocLargeReused, analysisTool, mallocNano,
                mallocMedium, mallocProbGuard, machMessage, ioKit, stack, `guard`, sharedPMap,
                dylib, objcDispatchers, unsharedPMap, libchannel, appKit, foundation,
                coreGraphics, coreServices, carbon, java, coreData, coreDataObjectIDs, ats,
                layerKit, cgImage, tcMalloc, coreGraphicsData, coreGraphicsShared,
                coreGraphicsFrameBuffers, coreGraphicsBackingStores, coreGraphicsXalloc,
                coreGraphicsMisc, dyld, dyldMalloc, sqlite, javascriptCore, webAssembly,
                javascriptJITExecutableAllocator, javascriptJITRegisterFile, glsl, openCL,
                coreImage, webCorePurgeableBuffers, imageIO, coreProfile, assetsD,
                osAllocOnce, libDispatch, accelerate, coreUI, coreUIFile, genealogy,
                rawCamera, corpseInfo, asl, swiftRuntime, swiftMetadata, dhmm, dfr,
                sceneKit, skywalk, ioSurface, libNetwork, audio, videoBitstream,
                cmXPC, cmRPC, cmMemoryPool, cmReadCache, cmCrabs,
                quickLookThumbnails, accounts, sanitizer, ioAccelerator,
                cmRegwarp, earDecoder, coreUICachedImageData, colorSync, btInfo,
                cmHLS, compositorServices, rosetta, rosettaThreadContext,
                rosettaIndirectBranchMap, rosettaReturnStack,
                rosettaExecutableHeap, rosettaUserLDT, rosettaArena,
                rosetta10,
                applicationSpecific1, applicationSpecific2, applicationSpecific3,
                applicationSpecific4, applicationSpecific5, applicationSpecific6,
                applicationSpecific7, applicationSpecific8,
                applicationSpecific9, applicationSpecific10,
                applicationSpecific11, applicationSpecific12,
                applicationSpecific13, applicationSpecific14,
                applicationSpecific15, applicationSpecific16,
            ]

            public static let untagged =
                Self(name: "untagged", rawValue: 0)

            public static let malloc =
                Self(name: "malloc", rawValue: VM_MEMORY_MALLOC)

            public static let mallocSmall =
                Self(name: "mallocSmall", rawValue: VM_MEMORY_MALLOC_SMALL)

            public static let mallocLarge =
                Self(name: "mallocLarge", rawValue: VM_MEMORY_MALLOC_LARGE)

            public static let mallocHuge =
                Self(name: "mallocHuge", rawValue: VM_MEMORY_MALLOC_HUGE)

            public static let sbrk =
                Self(name: "sbrk", rawValue: VM_MEMORY_SBRK)

            public static let realloc =
                Self(name: "realloc", rawValue: VM_MEMORY_REALLOC)

            public static let mallocTiny =
                Self(name: "mallocTiny", rawValue: VM_MEMORY_MALLOC_TINY)

            public static let mallocLargeReusable =
                Self(name: "mallocLargeReusable", rawValue: VM_MEMORY_MALLOC_LARGE_REUSABLE)

            public static let mallocLargeReused =
                Self(name: "mallocLargeReused", rawValue: VM_MEMORY_MALLOC_LARGE_REUSED)

            public static let analysisTool =
                Self(name: "analysisTool", rawValue: VM_MEMORY_ANALYSIS_TOOL)

            public static let mallocNano =
                Self(name: "mallocNano", rawValue: VM_MEMORY_MALLOC_NANO)

            public static let mallocMedium =
                Self(name: "mallocMedium", rawValue: VM_MEMORY_MALLOC_MEDIUM)

            public static let mallocProbGuard =
                Self(name: "mallocProbGuard", rawValue: VM_MEMORY_MALLOC_PROB_GUARD)

            public static let machMessage =
                Self(name: "machMessage", rawValue: VM_MEMORY_MACH_MSG)

            public static let ioKit =
                Self(name: "ioKit", rawValue: VM_MEMORY_IOKIT)

            public static let stack =
                Self(name: "stack", rawValue: VM_MEMORY_STACK)

            public static let `guard` =
                Self(name: "guard", rawValue: VM_MEMORY_GUARD)

            public static let sharedPMap =
                Self(name: "sharedPMap", rawValue: VM_MEMORY_SHARED_PMAP)

            public static let dylib =
                Self(name: "dylib", rawValue: VM_MEMORY_DYLIB)

            public static let objcDispatchers =
                Self(name: "objcDispatchers", rawValue: VM_MEMORY_OBJC_DISPATCHERS)

            public static let unsharedPMap =
                Self(name: "unsharedPMap", rawValue: VM_MEMORY_UNSHARED_PMAP)

            public static let libchannel =
                Self(name: "libchannel", rawValue: VM_MEMORY_LIBCHANNEL)

            public static let appKit =
                Self(name: "appKit", rawValue: VM_MEMORY_APPKIT)

            public static let foundation =
                Self(name: "foundation", rawValue: VM_MEMORY_FOUNDATION)

            public static let coreGraphics =
                Self(name: "coreGraphics", rawValue: VM_MEMORY_COREGRAPHICS)

            public static let coreServices =
                Self(name: "coreServices", rawValue: VM_MEMORY_CORESERVICES)

            public static let carbon =
                Self(name: "carbon", rawValue: VM_MEMORY_CARBON)

            public static let java =
                Self(name: "java", rawValue: VM_MEMORY_JAVA)

            public static let coreData =
                Self(name: "coreData", rawValue: VM_MEMORY_COREDATA)

            public static let coreDataObjectIDs =
                Self(name: "coreDataObjectIDs", rawValue: VM_MEMORY_COREDATA_OBJECTIDS)

            public static let ats =
                Self(name: "ats", rawValue: VM_MEMORY_ATS)

            public static let layerKit =
                Self(name: "layerKit", rawValue: VM_MEMORY_LAYERKIT)

            public static let cgImage =
                Self(name: "cgImage", rawValue: VM_MEMORY_CGIMAGE)

            public static let tcMalloc =
                Self(name: "tcMalloc", rawValue: VM_MEMORY_TCMALLOC)

            public static let coreGraphicsData =
                Self(name: "coreGraphicsData", rawValue: VM_MEMORY_COREGRAPHICS_DATA)

            public static let coreGraphicsShared =
                Self(name: "coreGraphicsShared", rawValue: VM_MEMORY_COREGRAPHICS_SHARED)

            public static let coreGraphicsFrameBuffers =
                Self(
                    name: "coreGraphicsFrameBuffers", rawValue: VM_MEMORY_COREGRAPHICS_FRAMEBUFFERS)

            public static let coreGraphicsBackingStores =
                Self(
                    name: "coreGraphicsBackingStores",
                    rawValue: VM_MEMORY_COREGRAPHICS_BACKINGSTORES)

            public static let coreGraphicsXalloc =
                Self(name: "coreGraphicsXalloc", rawValue: VM_MEMORY_COREGRAPHICS_XALLOC)

            public static let coreGraphicsMisc =
                Self(name: "coreGraphicsMisc", rawValue: VM_MEMORY_COREGRAPHICS_MISC)

            public static let dyld =
                Self(name: "dyld", rawValue: VM_MEMORY_DYLD)

            public static let dyldMalloc =
                Self(name: "dyldMalloc", rawValue: VM_MEMORY_DYLD_MALLOC)

            public static let sqlite =
                Self(name: "sqlite", rawValue: VM_MEMORY_SQLITE)

            public static let javascriptCore =
                Self(name: "javascriptCore", rawValue: VM_MEMORY_JAVASCRIPT_CORE)

            public static let webAssembly =
                Self(name: "webAssembly", rawValue: VM_MEMORY_WEBASSEMBLY)

            public static let javascriptJITExecutableAllocator =
                Self(
                    name: "javascriptJITExecutableAllocator",
                    rawValue: VM_MEMORY_JAVASCRIPT_JIT_EXECUTABLE_ALLOCATOR)

            public static let javascriptJITRegisterFile =
                Self(
                    name: "javascriptJITRegisterFile",
                    rawValue: VM_MEMORY_JAVASCRIPT_JIT_REGISTER_FILE)

            public static let glsl =
                Self(name: "glsl", rawValue: VM_MEMORY_GLSL)

            public static let openCL =
                Self(name: "openCL", rawValue: VM_MEMORY_OPENCL)

            public static let coreImage =
                Self(name: "coreImage", rawValue: VM_MEMORY_COREIMAGE)

            public static let webCorePurgeableBuffers =
                Self(name: "webCorePurgeableBuffers", rawValue: VM_MEMORY_WEBCORE_PURGEABLE_BUFFERS)

            public static let imageIO =
                Self(name: "imageIO", rawValue: VM_MEMORY_IMAGEIO)

            public static let coreProfile =
                Self(name: "coreProfile", rawValue: VM_MEMORY_COREPROFILE)

            public static let assetsD =
                Self(name: "assetsD", rawValue: VM_MEMORY_ASSETSD)

            public static let osAllocOnce =
                Self(name: "osAllocOnce", rawValue: VM_MEMORY_OS_ALLOC_ONCE)

            public static let libDispatch =
                Self(name: "libDispatch", rawValue: VM_MEMORY_LIBDISPATCH)

            public static let accelerate =
                Self(name: "accelerate", rawValue: VM_MEMORY_ACCELERATE)

            public static let coreUI =
                Self(name: "coreUI", rawValue: VM_MEMORY_COREUI)

            public static let coreUIFile =
                Self(name: "coreUIFile", rawValue: VM_MEMORY_COREUIFILE)

            public static let genealogy =
                Self(name: "genealogy", rawValue: VM_MEMORY_GENEALOGY)

            public static let rawCamera =
                Self(name: "rawCamera", rawValue: VM_MEMORY_RAWCAMERA)

            public static let corpseInfo =
                Self(name: "corpseInfo", rawValue: VM_MEMORY_CORPSEINFO)

            public static let asl =
                Self(name: "asl", rawValue: VM_MEMORY_ASL)

            public static let swiftRuntime =
                Self(name: "swiftRuntime", rawValue: VM_MEMORY_SWIFT_RUNTIME)

            public static let swiftMetadata =
                Self(name: "swiftMetadata", rawValue: VM_MEMORY_SWIFT_METADATA)

            public static let dhmm =
                Self(name: "dhmm", rawValue: VM_MEMORY_DHMM)

            public static let dfr =
                Self(name: "dfr", rawValue: VM_MEMORY_DFR)

            public static let sceneKit =
                Self(name: "sceneKit", rawValue: VM_MEMORY_SCENEKIT)

            public static let skywalk =
                Self(name: "skywalk", rawValue: VM_MEMORY_SKYWALK)

            public static let ioSurface =
                Self(name: "ioSurface", rawValue: VM_MEMORY_IOSURFACE)

            public static let libNetwork =
                Self(name: "libNetwork", rawValue: VM_MEMORY_LIBNETWORK)

            public static let audio =
                Self(name: "audio", rawValue: VM_MEMORY_AUDIO)

            public static let videoBitstream =
                Self(name: "videoBitstream", rawValue: VM_MEMORY_VIDEOBITSTREAM)

            public static let cmXPC =
                Self(name: "cmXPC", rawValue: VM_MEMORY_CM_XPC)

            public static let cmRPC =
                Self(name: "cmRPC", rawValue: VM_MEMORY_CM_RPC)

            public static let cmMemoryPool =
                Self(name: "cmMemoryPool", rawValue: VM_MEMORY_CM_MEMORYPOOL)

            public static let cmReadCache =
                Self(name: "cmReadCache", rawValue: VM_MEMORY_CM_READCACHE)

            public static let cmCrabs =
                Self(name: "cmCrabs", rawValue: VM_MEMORY_CM_CRABS)

            public static let quickLookThumbnails =
                Self(name: "quickLookThumbnails", rawValue: VM_MEMORY_QUICKLOOK_THUMBNAILS)

            public static let accounts =
                Self(name: "accounts", rawValue: VM_MEMORY_ACCOUNTS)

            public static let sanitizer =
                Self(name: "sanitizer", rawValue: VM_MEMORY_SANITIZER)

            public static let ioAccelerator =
                Self(name: "ioAccelerator", rawValue: VM_MEMORY_IOACCELERATOR)

            public static let cmRegwarp =
                Self(name: "cmRegwarp", rawValue: VM_MEMORY_CM_REGWARP)

            public static let earDecoder =
                Self(name: "earDecoder", rawValue: VM_MEMORY_EAR_DECODER)

            public static let coreUICachedImageData =
                Self(name: "coreUICachedImageData", rawValue: VM_MEMORY_COREUI_CACHED_IMAGE_DATA)

            public static let colorSync =
                Self(name: "colorSync", rawValue: VM_MEMORY_COLORSYNC)

            public static let btInfo =
                Self(name: "btInfo", rawValue: VM_MEMORY_BTINFO)

            public static let cmHLS =
                Self(name: "cmHLS", rawValue: VM_MEMORY_CM_HLS)

            public static let compositorServices =
                Self(name: "compositorServices", rawValue: VM_MEMORY_COMPOSITOR_SERVICES)

            public static let rosetta =
                Self(name: "rosetta", rawValue: VM_MEMORY_ROSETTA)

            public static let rosettaThreadContext =
                Self(name: "rosettaThreadContext", rawValue: VM_MEMORY_ROSETTA_THREAD_CONTEXT)

            public static let rosettaIndirectBranchMap =
                Self(
                    name: "rosettaIndirectBranchMap",
                    rawValue: VM_MEMORY_ROSETTA_INDIRECT_BRANCH_MAP)

            public static let rosettaReturnStack =
                Self(name: "rosettaReturnStack", rawValue: VM_MEMORY_ROSETTA_RETURN_STACK)

            public static let rosettaExecutableHeap =
                Self(name: "rosettaExecutableHeap", rawValue: VM_MEMORY_ROSETTA_EXECUTABLE_HEAP)

            public static let rosettaUserLDT =
                Self(name: "rosettaUserLDT", rawValue: VM_MEMORY_ROSETTA_USER_LDT)

            public static let rosettaArena =
                Self(name: "rosettaArena", rawValue: VM_MEMORY_ROSETTA_ARENA)

            public static let rosetta10 =
                Self(name: "rosetta10", rawValue: VM_MEMORY_ROSETTA_10)

            public static let applicationSpecific1 =
                Self(name: "applicationSpecific1", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_1)

            public static let applicationSpecific2 =
                Self(name: "applicationSpecific2", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_2)

            public static let applicationSpecific3 =
                Self(name: "applicationSpecific3", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_3)

            public static let applicationSpecific4 =
                Self(name: "applicationSpecific4", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_4)

            public static let applicationSpecific5 =
                Self(name: "applicationSpecific5", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_5)

            public static let applicationSpecific6 =
                Self(name: "applicationSpecific6", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_6)

            public static let applicationSpecific7 =
                Self(name: "applicationSpecific7", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_7)

            public static let applicationSpecific8 =
                Self(name: "applicationSpecific8", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_8)

            public static let applicationSpecific9 =
                Self(name: "applicationSpecific9", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_9)

            public static let applicationSpecific10 =
                Self(name: "applicationSpecific10", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_10)

            public static let applicationSpecific11 =
                Self(name: "applicationSpecific11", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_11)

            public static let applicationSpecific12 =
                Self(name: "applicationSpecific12", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_12)

            public static let applicationSpecific13 =
                Self(name: "applicationSpecific13", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_13)

            public static let applicationSpecific14 =
                Self(name: "applicationSpecific14", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_14)

            public static let applicationSpecific15 =
                Self(name: "applicationSpecific15", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_15)

            public static let applicationSpecific16 =
                Self(name: "applicationSpecific16", rawValue: VM_MEMORY_APPLICATION_SPECIFIC_16)
        }
    }

    // MARK: - Flags With Tag

    extension Mach.VMFlags {
        /// Represents a set of virtual memory flags combined with a tag.
        init(_ flags: Self, withTag tag: Mach.VMTag) {
            self.init(
                name: flags.name,
                rawValue: flags.rawValue | (tag.rawValue << 24)
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
