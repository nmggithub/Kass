// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// A module in the package.
protocol Module {
    var targetName: String { get }
    var dependencies: [String] { get }
    var path: String { get }
}

struct BasicModule: Module {
    let targetName: String
    let dependencies: [String]
    let path: String
    init(targetName: String, path: String? = nil, dependencies: [String]) {
        self.targetName = targetName
        self.dependencies = dependencies
        self.path = path ?? "Sources/\(targetName)"
    }
}

struct MachSubModule: Module {
    let targetName: String
    let dependencies: [String]
    let path: String
    internal init(subModuleName: String, folderName: String? = nil, dependencies: [String]) {
        let prefixedTargetName = "Mach\(subModuleName)"
        self.targetName = prefixedTargetName
        self.path = "Sources/Mach/\(folderName ?? subModuleName)"
        self.dependencies = ["MachCore"] + dependencies
    }
}

struct BSDSubModule: Module {
    let targetName: String
    let dependencies: [String]
    let path: String
    internal init(subModuleName: String, folderName: String? = nil, dependencies: [String]) {
        let prefixedTargetName = "BSD\(subModuleName)"
        self.targetName = prefixedTargetName
        self.path = "Sources/BSD/\(folderName ?? subModuleName)"
        self.dependencies = ["BSDBase"] + dependencies
    }
}

/// The modules that are part of the package, in build order.
let modules: [Module] = [
    BasicModule.init(targetName: "KassHelpers", dependencies: []),
    BasicModule.init(targetName: "CCompat", dependencies: []),
    BasicModule.init(targetName: "Linking", dependencies: []),
    BasicModule.init(
        targetName: "BSDBase", path: "Sources/BSD/Base", dependencies: ["CCompat", "Linking"]
    ),
    BSDSubModule.init(subModuleName: "FS", dependencies: ["CCompat", "Linking"]),
    BasicModule.init(targetName: "MachC", path: "Sources/MachC", dependencies: []),
    BasicModule.init(
        targetName: "MachCore", path: "Sources/Mach/Core",
        dependencies: ["KassHelpers", "MachC", "BSDBase", "CCompat", "Linking"]
    ),
    BasicModule.init(targetName: "Kass", dependencies: ["KassHelpers", "MachCore"]),

]

/// The name of the package.
let name = "Kass"

/// The targets for the modules.
let moduleTargets = modules.map {
    Target.target(
        name: $0.targetName,
        dependencies: $0.dependencies.map { Target.Dependency.target(name: $0) },
        path: $0.path
    )
}

/// The products for the modules.
let moduleProducts = modules.map {
    Product.library(
        name: $0.targetName,
        targets: [$0.targetName] + $0.dependencies
    )
}

let package = Package(
    name: name,
    platforms: [
        .macOS(.v10_13)
    ],
    products: moduleProducts,
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.3")
    ],
    targets: moduleTargets
)
