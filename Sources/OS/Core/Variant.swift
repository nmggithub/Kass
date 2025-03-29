import Foundation
import KassC.VariantPrivate

extension OS {
    // A helper for OS variants.
    public struct Variant {
        private let subsystem: String

        /// Initializes a helper for the current OS variant, claiming to be from the given subsystem.
        /// - Note: The subsystem string is currently unused.
        public init(subsystem: String) {
            self.subsystem = subsystem
        }

        /// Wether or not the variant has internal content.
        public var hasInternalContent: Bool {
            os_variant_has_internal_content(self.subsystem)
        }

        /// Wether or not the variant has internal UI.
        public var hasInternalUI: Bool {
            os_variant_has_internal_ui(self.subsystem)
        }

        /// Wether or not the variant allows internal security policies.
        public var allowsInternalSecurityPolicies: Bool {
            os_variant_allows_internal_security_policies(self.subsystem)
        }

        /// Wether or not the variant has factory content.
        @available(macOS 10.14.4, *)
        public var hasFactoryContent: Bool {
            os_variant_has_factory_content(self.subsystem)
        }

        /// Wether or not the variant is a darwinOS variant.
        @available(macOS 10.15, *)
        public var isDarwinOS: Bool {
            os_variant_is_darwinos(self.subsystem)
        }

        /// Wether or not the variant uses ephemeral storage.
        @available(macOS 10.15, *)
        public var usesEphemeralStorage: Bool {
            os_variant_uses_ephemeral_storage(self.subsystem)
        }

        /// Wether or not the variant allows security research.
        @available(macOS 12.0, *)
        public var allowsSecurityResearch: Bool {
            os_variant_allows_security_research(self.subsystem)
        }

        /// Wether or not the variant is the macOS BaseSystem.
        @available(macOS 11.0, *)
        public var isBaseSystem: Bool {
            os_variant_is_basesystem(self.subsystem)
        }

        /// Wether or not the variant is a recoveryOS.
        @available(macOS 10.15, *)
        public var isRecovery: Bool {
            os_variant_is_recovery(self.subsystem)
        }

        /// Checks if the system is the given variant.
        @available(macOS 10.15, *)
        func check(_ variant: String) -> Bool {
            os_variant_check(self.subsystem, variant)
        }

        /// A string representation of the variant.
        @available(macOS 11, *)
        public var description: String {
            get throws {
                guard let descriptionPointer = os_variant_copy_description(self.subsystem) else {
                    guard let posixCode = POSIXErrorCode(rawValue: errno) else {
                        throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil)
                    }
                    throw POSIXError(posixCode)
                }
                defer { free(descriptionPointer) }
                return String(cString: descriptionPointer)
            }
        }

    }
}
