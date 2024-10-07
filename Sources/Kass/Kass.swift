import BSDCore
import KassHelpers
import MachCore

/// The Kass library.
public struct Kass: KassHelpers.Namespace {
    /// The XNU kernel.
    public struct XNU: KassHelpers.Namespace {
        /// The Mach portion of the XNU kernel (main module: ``/MachCore``).
        public typealias Mach = MachCore.Mach

        /// The BSD portion of the XNU kernel (main module: ``/BSDCore``).
        public typealias BSD = BSDCore.BSD
    }
}
