import Darwin.Mach

// extension Mach {
//     /// A flavor of processor set (port).
//     public enum ProcessorSetFlavor: mach_ProcessorSet_flavor_t {
//         /// A processor set control port.
//         case control = 0

//         /// A processor set name port.
//         case name = 3
//     }
//     /// A processor set (port) with a flavor.
//     public protocol ProcessorSetFlavored: Mach.ProcessorSet {
//         /// The flavor of the processor set port.
//         var flavor: Mach.ProcessorSetFlavor { get }
//     }
// }

// extension Mach {
// /// A ProcessorSet's control port.
// public class ProcessorSetControl: Mach.ProcessorSet, Mach.ProcessorSetFlavored {
//     /// The ``Mach/ProcessorSetFlavor/control`` flavor.
//     public let flavor: Mach.ProcessorSetFlavor = .control

//     /// A nil processor set control port.
//     override public class var Nil: Self {
//         Self(named: mach_port_name_t(PROCESSOR_SET_NULL))
//     }
// }

// /// A ProcessorSet's name port.
// public class ProcessorSetName: Mach.ProcessorSet, Mach.ProcessorSetFlavored {
//     /// The ``Mach/ProcessorSetFlavor/name`` flavor.
//     public let flavor: Mach.ProcessorSetFlavor = .name

//     /// A nil processor set name port.
//     override public class var Nil: Self {
//         Self(named: mach_port_name_t(PROCESSOR_SET_NULL))
//     }
// }
// }
