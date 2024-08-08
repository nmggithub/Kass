import Foundation

/// A handle.
public class Handle {
    /// A type of handle.
    public enum HandleType {
        case library
        case symbol
    }
    /// The name of the handle.
    public let name: String
    /// The raw handle.
    public let rawHandle: UnsafeMutableRawPointer
    /// The type of the handle.
    public let type: HandleType
    /// Create a new handle.
    /// - Parameters:
    ///   - name: The name of the handle.
    ///   - rawHandle: The raw handle.
    ///   - type: The type of the handle.
    public init(name: String, rawHandle: UnsafeMutableRawPointer, type: HandleType) {
        self.name = name
        self.rawHandle = rawHandle
        self.type = type
    }
}

/// A library handle.
public class Library: Handle {
    /// The path to the library.
    let pathURL: URL
    /// Create a new library handle.
    /// - Parameter path: The path to the library.
    /// - Remark: Returns `nil` if the library could not be loaded.
    public init?(withPath path: String) {
        guard
            let pathURL = URL(string: path),
            let handle = dlopen(pathURL.path, RTLD_LAZY)
        else { return nil }
        self.pathURL = pathURL
        super.init(
            name: pathURL.lastPathComponent, rawHandle: handle, type: .library)
    }
    /// Link the library.
    /// - Remark:
    ///     This is technically a no-op, as the library is linked when the class is initialized. This function is provided
    ///     as a Void-returning "escape hatch" for users who do not wish to use the return value of the initializer.
    public func link() {}
    /// Get a symbol handle from the library.
    /// - Parameter symbol: The name of the symbol.
    /// - Returns: The symbol handle, or `nil` if the symbol could not be found.
    public func get(symbol: String) -> Symbol? {
        guard let handle = dlsym(self.rawHandle, symbol) else { return nil }
        return Symbol(name: symbol, rawHandle: handle)
    }
    /// Get a symbol handle from the library at a specific address.
    /// - Parameters:
    ///   - symbol: The name of the symbol.
    ///   - atExpectedAddress: The address of the symbol.
    ///   - otherSymbol: The name of another symbol in the library to use as a reference. This symbol should be exported by the library.
    ///   - expectedOtherSymbolAddress: The exepected address of the other symbol.
    /// - Returns: The symbol handle, or `nil` if the symbol could not be found.
    /// - Remark:
    ///     Both `atExpectedAddress` and `expectedOtherSymbolAddress` should be the addresses of the symbols in memory, gathered
    ///     from other analysis tools. In some cases, the actual addresses in memory may be offset by some unknown amount. Thus,
    ///     this function will find use the other symbol to calculate the offset and find the symbol's actual address in memory.
    public func get(
        symbol: String, atExpectedAddress expectedAddress: vm_address_t, otherSymbol: String,
        expectedOtherSymbolAddress: vm_address_t
    ) -> Symbol? {
        guard
            let actualOtherSymbolAddress = dlsym(self.rawHandle, otherSymbol),
            let expectedOtherSymbolPointer = UnsafeRawPointer(
                bitPattern: expectedOtherSymbolAddress
            )
        else { return nil }
        // the addresses may be offset by some amount, so we need to calculate the offset
        // TODO: determine if there is a way to calculate the offset without using the other symbol
        let imageOffset = expectedOtherSymbolPointer.distance(to: actualOtherSymbolAddress)
        guard
            let expectedPointer = UnsafeMutableRawPointer(
                bitPattern: expectedAddress.advanced(by: imageOffset)
            )
        else { return nil }
        return Symbol(name: symbol, rawHandle: expectedPointer)
    }
    /// Get an Objective-C class from the library.
    /// - Parameter className: The name of the class.
    /// - Returns: The class, or `nil` if the class could not be found.
    public func get(objCClass className: String) -> NSObjectProtocol.Type? {
        return self.get(objCClass: className, castTo: NSObjectProtocol.Type.self)
    }
    /// Get an Objective-C class from the library.
    /// - Parameters:
    ///   - className: The name of the class.
    ///   - castTo: The type to cast the class to (should be a protocol).
    /// - Returns: The class, or `nil` if the class could not be found.
    public func get<T>(objCClass className: String, castTo: T.Type = T.self) -> T? {
        guard let symbol = self.get(symbol: "OBJC_CLASS_$_\(className)") else { return nil }
        assert(MemoryLayout<T>.size == MemoryLayout<UnsafeRawPointer>.size)  // make sure the type we're casting to is the same size as a pointer
        return symbol.cast(to: T.self)
    }
    deinit {
        dlclose(self.rawHandle)
    }
}

/// A symbol handle.
public class Symbol: Handle {
    /// Cast the symbol to a specific type.
    /// - Parameter to: The type to cast the symbol to.
    /// - Returns: The symbol cast to the specified type.
    /// - Remark: This is equivalent to `unsafeBitCast(self.rawHandle, to: T.self)`.
    public func cast<T>(to: T.Type = T.self) -> T {
        return unsafeBitCast(self.rawHandle, to: T.self)
    }
    /// Load the symbol as a specific type.
    /// - Parameter as: The type to load the symbol as.
    /// - Returns: The symbol loaded as the specified type.
    /// - Remark: This is equivalent to `self.rawHandle.load(as: T.self)`.
    public func load<T>(as: T.Type = T.self) -> T {
        return self.rawHandle.load(as: T.self)
    }
    /// Create a new symbol handle.
    /// - Parameters:
    ///   - name: The name of the symbol.
    ///   - rawHandle: The raw handle.
    public init(name: String, rawHandle: UnsafeMutableRawPointer) {
        super.init(name: name, rawHandle: rawHandle, type: .symbol)
    }
}

/// A framework handle.
public class Framework: Library {
    /// The path to the public frameworks.
    private static let publicFrameworksPath = URL(string: "/System/Library/Frameworks")!
    /// The path to the private frameworks.
    private static let privateFrameworksPath = URL(string: "/System/Library/PrivateFrameworks")!
    /// Get the path to a framework.
    /// - Parameters:
    ///   - name: The name of the framework.
    ///   - isPrivate: Whether the framework is private.
    /// - Returns: The path to the framework.
    private static func frameworkPath(for name: String, isPrivate: Bool) -> String {
        let path = isPrivate ? privateFrameworksPath : publicFrameworksPath
        return frameworkPath(for: name, inPath: path)
    }
    /// Get the path to a framework.
    /// - Parameters:
    ///   - name: The name of the framework.
    ///   - inPath: The directory containing the framework.
    /// - Returns: The path to the framework.
    private static func frameworkPath(for name: String, inPath path: URL) -> String {
        return path.appending(component: "\(name).framework/\(name)").path
    }
    /// Create a new framework handle.
    /// - Parameters:
    ///   - name: The name of the framework.
    ///   - isPrivate: Whether the framework is private.
    /// - Remark: Returns `nil` if the framework could not be loaded.
    public init?(_ name: String, isPrivate: Bool = false) {
        super.init(withPath: Self.frameworkPath(for: name, isPrivate: isPrivate))
    }
    /// Create a new framework handle.
    /// - Parameters:
    ///   - name: The name of the framework.
    ///   - inPath: The directory containing the framework.
    /// - Remark: Returns `nil` if the framework could not be loaded.
    public init?(_ name: String, inPath path: URL) {
        super.init(withPath: Self.frameworkPath(for: name, inPath: path))
    }
    /// Get a framework handle from a path (used internally for getting sub-frameworks).
    /// - Parameter path: The path to the framework.
    private override init?(withPath path: String) {
        super.init(withPath: path)
    }
    /// Get a sub-framework handle from the framework.
    /// - Parameter subFramework: The name of the sub-framework.
    /// - Returns: A handle to the sub-framework, or `nil` if the sub-framework could not be found.
    public func get(subFramework: String) -> Framework? {
        let subFrameworksPath = self.pathURL.deletingLastPathComponent()
        return Framework(
            withPath: Self.frameworkPath(for: subFramework, inPath: subFrameworksPath)
        )
    }
}
