# Kass
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnmggithub%2FKass%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/nmggithub/Kass)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnmggithub%2FKass%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/nmggithub/Kass)

Kass is a collection of modules for reverse-engineering and security research on macOS, written in Swift. It is currently focused on interacting with the XNU kernel which underlies macOS, but may be expanded in the future to support other XNU-based operating systems such as iOS.

Note that while it may compile on older versions of macOS, this library is only thoroughly tested on the latest version of macOS. In some cases, older deprecated (or even obsoleted) API's are included, but they should be assumed to be untested as it stands today. This may change in the future.

## A Message From The Developer

Hi! This is [nmggithub](https://github.com/nmggithub), the sole developer of this project. I tend to avoid using pronouns in general when it comes to documentation, but I realized I couldn't really avoid it here, so this section is going to be a lot more personal than any of the other documentation. Perhaps I may change my style in the future, but for now this is going to stand out, so I thought I'd address it.

Kass 3.0.0 was a major upgrade from Kass 2.0.0, hence the major version change. But even now, it's still a library in transition. Hopefully not in the architecture department, but Kass 3.0.0 was still missing several features I wish I could have included.

Going forward, I want to try and stick with [Semantic Versioning](https://semver.org/), but I don't think I can commit to that fully (especially with how often my mind changes). I honestly don't know how many (if anyone) is using this project, but I wanted 3.0 onward to be at least somewhat stable.

I consider the `MachCore` module to be mostly stable, so there will likely be little changes to it going forward (save for the addition of virtual memory API's). `BSDCore` is in its early stages, so a lot can change there. Finally, `Linking` will likely be folded into `BSDCore` at some point.

I hope this library is of some use to you, and I look forward to more stable releases in the future. If you have any issues with it, feel free to [file an issue.](https://github.com/nmggithub/Kass/issues) If you'd like to contribute, go ahead and [open a PR.](https://github.com/nmggithub/Kass/pulls) I appreciate all the feedback and support.

### Kass 4.0.0 update

As of writing, Kass 4.0.0 has been released. Everything I have said above still stands. I will try to stick with SemVer, but I can't promise anything. There's still some API's I'd love to add more stability to, and more I'd like to add. The XNU kernel is a big project, and and I keep finding more and more interesting corners of it. Anyway, onward I go!

## On Licenses

Most of this code is MIT-licensed. However, there are some cases where substance is copied from header files licensed under [Apple's Public Source License](https://opensource.apple.com/apsl/) and other licenses. Where deemed appropriate, copyright notices for the relevant licenses are included. Please see the source code for more information.

## Modules

### [`Kass`](https://swiftpackageindex.com/nmggithub/Kass/main/documentation/kass/)

This is merely a namespace "module". It can be used to access the the `MachCore` and `BSDCore` modules, but is not strictly necessary.

### [`MachCore`](https://swiftpackageindex.com/nmggithub/Kass/main/documentation/machcore/)

This module provides facilities for interacting with the Mach portion of the XNU kernel. Most Mach API's are provided, although some are intentionally left in specific cases. Virtual memory API's are largely left out but are planned for a later release. This module should be considered the most stable, as it has had the most work put into it.

### [`BSDCore`](https://swiftpackageindex.com/nmggithub/Kass/main/documentation/bsdcore/)

This module provides facilities for interacting with the Mach portion of the XNU kernel. It is very much a work-in-progress and should not be considered very stable as it may be subject to change.

### [`Linking`](https://swiftpackageindex.com/nmggithub/Kass/main/documentation/linking/)

This module provides a simple API to access symbols that uses the `dlopen`/`dlsym` functions internally. It will likely be folded into `BSDCore` at some point.

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

If any module names collides with existing modules in your package, simply use the [`moduleAliases:`](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0339-module-aliasing-for-disambiguation.md) option when defining the dependency. Please see the documentation for any additional information on naming collisions.
