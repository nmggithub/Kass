# Kass
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnmggithub%2FKass%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/nmggithub/Kass)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnmggithub%2FKass%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/nmggithub/Kass)

Kass is a collection of modules for reverse-engineering and security research on macOS, written in Swift.

## Modules

### [`CCompat`](https://swiftpackageindex.com/nmggithub/Kass/main/documentation/ccompat/)
This is simply a helper module to allow for option sets where each option can be represented by a C Macro. The built-in [`OptionSet`](https://developer.apple.com/documentation/swift/optionset) type was not chosen due to it not using `enum`'s. This may change in future versions.

### [`Linking`](https://swiftpackageindex.com/nmggithub/Kass/main/documentation/linking/)

This module provides a simple API to access symbols that uses the `dlopen`/`dlsym` functions internally.

### [`MachMsg`](https://swiftpackageindex.com/nmggithub/Kass/main/documentation/machmsg/)

This is the most complicated module, by far. It provides an API for interacting with, sending, and receiving Mach messages. It also provides an API for interacting with MIG servers. Currently, MIG messages must be hand-built. This may change in future versions.

## Notes

Please note that these modules are meant primarily for reverse-engineering and security research. While some of these modules can be useful in production apps, that is not their intended purpose.

## Usage

### Adding the dependency:

Modify your `Package.swift` like so:

```swift
let package = Package(
  ...
  dependencies: [
    .package(url: "https://github.com/nmggithub/Kass", exact: "{desired-version}"),
  ],
  targets: [
    /// the target you wish to use this module in
    .[target | executableTarget](
      ...
      dependencies: [
        .product(name: "{module-name}", package: "Kass")
      ]
    )
  ]
)
```

### Using the dependency in the target:

Simply put

```swift
import {module-name}
```

at the top of your Swift file.

### Naming collisions

If any module names collides with existing modules in your package, simply use the [`moduleAliases:`](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0339-module-aliasing-for-disambiguation.md) option when defining the dependency.
