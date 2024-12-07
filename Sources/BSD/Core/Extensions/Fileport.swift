import KassC.Fileport
import MachCore
import System

// While fileports are Mach ports, they are implemented mostly in the BSD layer
// of the kernel, so they are defined here instead of in the MachCore module.
extension BSD {
    /// A Mach port representing a file descriptor.
    public class Fileport: MachCore.Mach.Port {

        // Initialize a fileport from a file descriptor.
        @available(macOS 11.0, *)
        public convenience init(fd: FileDescriptor) throws {
            try self.init(fd: Int32(fd.rawValue))
        }

        // Initialize a fileport from a file descriptor.
        public convenience init(fd: Int32) throws {
            var portName = mach_port_name_t()
            try BSD.syscall(fileport_makeport(fd, &portName))
            self.init(named: portName)
        }

        // Make a file descriptor from a fileport.
        // - Note: This function will create a new file descriptor each time it is called.
        @available(macOS 11.0, *)
        func makeFD() throws -> FileDescriptor {
            return FileDescriptor(rawValue: try BSD.syscall(fileport_makefd(self.name)))
        }

        // Make a file descriptor from a fileport.
        // - Note: This function will create a new file descriptor each time it is called.
        func makeFD() throws -> Int32 {
            return try BSD.syscall(fileport_makefd(self.name))
        }
    }
}
