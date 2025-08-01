#if canImport(Foundation.NSXMLElement)
    import Foundation
    import KassC.KextRequestKeys
    import KassC.OSKextLibPrivate
    import KassHelpers

    /// A property list parser, used to parse the response of a kext request.
    /// - Note: Some kext request responses make use of references, which are not supported by the
    /// built-in `PropertyListSerialization` class. This class is used to parse such responses.
    private class PListParser {
        /// The references used in the property list.
        private var references: [String: XMLElement] = [:]

        /// Parses a property list element.
        fileprivate func parsePlistElement(_ element: XMLElement?) -> Any? {
            guard let element = element else { return nil }
            if let referenceID = element.attributes?.first(where: { $0.name == "ID" })?.stringValue
            {
                self.references[referenceID] = element
            }
            switch element.name {
            case "reference":
                guard
                    let referenceID = element.attributes?
                        .first(where: { $0.name == "IDREF" })?.stringValue
                else { return nil }
                return parsePlistElement(self.references[referenceID])
            case "data":
                return Data(base64Encoded: element.stringValue ?? "")
            case "dict":
                var dict: [String: Any] = [:]
                for child in element.children ?? [] {
                    guard let keyElement = child as? XMLElement, keyElement.name == "key" else {
                        continue
                    }
                    guard let key = keyElement.stringValue else {
                        continue
                    }
                    guard let valueElement = keyElement.nextSibling as? XMLElement else {
                        continue
                    }
                    let value = parsePlistElement(valueElement)
                    dict[key] = value
                }
                return dict
            case "date":
                return ISO8601DateFormatter().date(from: element.stringValue ?? "")
            case "array":
                return element.children?.compactMap { parsePlistElement($0 as? XMLElement) } ?? []
            case "string":
                return element.stringValue
            case "integer":
                return Int(element.stringValue ?? "")
            case "real":
                return Double(element.stringValue ?? "")
            case "true":
                return true
            case "false":
                return false
            default:
                return nil
            }
        }
    }

    extension Mach.Host {
        /// Performs a kext request.
        /// - Warning: This function is a very low-level around the `kext_request` function, and should only
        /// be used if specific functionality is required. Otherwise, use the higher-level wrappers.
        public func kextRequest(
            _ request: UnsafeRawBufferPointer,
            logSpec: OSKextLogSpec = 0,
            responsePointer: UnsafeMutablePointer<UnsafeRawBufferPointer?>? = nil,
            logsPointer: UnsafeMutablePointer<UnsafeRawBufferPointer?>? = nil,
            throwOnInnerFailure: Bool = true
        ) throws {
            var responseAddress = vm_offset_t()
            var responseCount = mach_msg_type_number_t()
            var actualReturn = kern_return_t()
            var logDataPointer = vm_offset_t()
            var logDataCount = mach_msg_type_number_t()
            try Mach.call(
                kext_request(
                    self.name,
                    logSpec,
                    vm_offset_t(bitPattern: request.baseAddress),
                    mach_msg_type_number_t(request.count),
                    &responseAddress, &responseCount,
                    &logDataPointer, &logDataCount, &actualReturn
                )
            )

            if throwOnInnerFailure { try Mach.call(actualReturn) }

            responsePointer?.pointee = UnsafeRawBufferPointer(
                start: UnsafeRawPointer(bitPattern: responseAddress),
                count: Int(responseCount)
            )
            logsPointer?.pointee = UnsafeRawBufferPointer(
                start: UnsafeRawPointer(bitPattern: logDataPointer),
                count: Int(logDataCount)
            )
        }

        /// Performs a kext request.
        public func kextRequest(_ request: [String: Any]) throws -> [String: Any]? {
            let requestXML =
                // A property list XML representation is not exactly the same as a regular XML
                // representation, but it works for our purposes here.
                try PropertyListSerialization.data(
                    fromPropertyList: request, format: .xml, options: 0
                )
                // The request XML must be null-terminated.
                + Data([0])
            var response: UnsafeRawBufferPointer?
            try requestXML.withUnsafeBytes { requestBuffer in
                try self.kextRequest(requestBuffer, responsePointer: &response)
            }
            guard
                let actualResponse = response,
                let baseAddress = actualResponse.baseAddress
            else { return nil }
            let responseData = Data(
                bytes: baseAddress, count: actualResponse.count - 1  // Exclude the null terminator.
            )
            guard
                let xmlDocument = try? XMLDocument(data: responseData),
                let rootElement = xmlDocument.rootElement()
            else { return nil }
            return PListParser().parsePlistElement(rootElement) as? [String: Any]
        }

        /// A kext request predicate.
        public struct KextRequestPredicate: KassHelpers.NamedOptionEnum {
            /// The name of the predicate, if it can be determined.
            public var name: String?

            /// Represents a kextRequest predicate with an optional name.
            public init(name: String?, rawValue: String) {
                self.name = name
                self.rawValue = rawValue
            }

            /// The raw value of the predicate.
            public let rawValue: String

            /// All known kextRequest predicates.
            public static let allCases: [Self] = []

            // Non-privileged requests.

            public static let getLoaded = Self(
                name: "getLoaded", rawValue: kKextRequestPredicateGetLoaded
            )

            public static let getLoadedByUUID = Self(
                name: "getLoadedByUUID", rawValue: kKextRequestPredicateGetLoadedByUUID
            )

            public static let getUUIDByAddress = Self(
                name: "getUUIDByAddress", rawValue: kKextRequestPredicateGetUUIDByAddress
            )

            public static let getKextsInCollection = Self(
                name: "getKextsInCollection", rawValue: kKextRequestPredicateGetKextsInCollection
            )

            public static let getDexts = Self(
                name: "getDexts", rawValue: kKextRequestPredicateGetDexts
            )

            // Privileged requests.

            public static let getKernelRequests = Self(
                name: "getKernelRequests", rawValue: kKextRequestPredicateGetKernelRequests
            )

            public static let load = Self(
                name: "load", rawValue: kKextRequestPredicateLoad
            )

            public static let loadFromKC = Self(
                name: "loadFromKC", rawValue: kKextRequestPredicateLoadFromKC
            )

            public static let loadCodeless = Self(
                name: "loadCodeless", rawValue: kKextRequestPredicateLoadCodeless
            )

            public static let start = Self(
                name: "start", rawValue: kKextRequestPredicateStart
            )

            public static let stop = Self(
                name: "stop", rawValue: kKextRequestPredicateStop
            )

            public static let unload = Self(
                name: "unload", rawValue: kKextRequestPredicateUnload
            )

            public static let loadFileSetKC = Self(
                name: "loadFileSetKC", rawValue: kKextRequestPredicateLoadFileSetKC
            )

            public static let missingAuxKCBundles = Self(
                name: "missingAuxKCBundles", rawValue: kKextRequestPredicateMissingAuxKCBundles
            )

            public static let auxKCBundleAvailable = Self(
                name: "auxKCBundleAvailable", rawValue: kKextRequestPredicateAuxKCBundleAvailable
            )

            public static let daemonReady = Self(
                name: "daemonReady", rawValue: kKextRequestPredicateDaemonReady
            )
        }

        /// Performs a kext request.
        public func kextRequest(
            predicate: Mach.Host.KextRequestPredicate,
            arguments: [String: Any] = [:]
        ) throws -> [String: Any]? {
            try self.kextRequest([
                kKextRequestPredicateKey: predicate.rawValue,
                kKextRequestArgumentsKey: arguments,
            ]
            )
        }
    }
#endif  // canImport(Foundation.NSXMLElement)
