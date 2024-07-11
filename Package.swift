// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// A module in the package.
struct Module {
    /// The name of the module.
    let name: String
    /// The names of the modules that this module depends on.
    let dependencies: [String]
}

/// The modules that are part of the package.
let modules: [Module] = [
    .init(name: "CCompat", dependencies: []),
    .init(name: "Linking", dependencies: []),
    .init(name: "MachMsg", dependencies: ["CCompat", "Linking"]),
]

/// The name of the package.
let name = "Kass"

/// The targets for the modules.
let moduleTargets = modules.map {
    Target.target(
        name: $0.name,
        dependencies: $0.dependencies.map { Target.Dependency.target(name: $0) },
        path: "Sources/\($0.name)",
        swiftSettings: [
            .unsafeFlags([
                "-emit-symbol-graph",
                "-emit-symbol-graph-dir",
                ".build/symbol-graphs/\($0.name)",
            ])
        ]
    )
}

/// The products for the modules.
let moduleProducts = modules.map {
    Product.library(
        name: $0.name,
        targets: [$0.name])
}

let package = Package(
    name: name,
    platforms: [
        .macOS(.v14)
    ],
    products: moduleProducts,
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
    ],
    targets: moduleTargets
)
