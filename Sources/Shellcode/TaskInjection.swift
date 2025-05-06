// ARM DDI 0487

import Darwin.Mach
import Foundation
import KassHelpers
import MachCore

extension Mach.Task {
    /// Injects shellcode into the target task, using the given thread, or
    ///      sets up a new bare Mach thread to execute it.
    /// - Warning: A bare Mach cannot do much without an associated POSIX thread. It is up
    ///      to the caller to create and associate a POSIX thread to the Mach thread.
    /// - Warning: Injecting into a running thread may cause unexpected behavior.
    public func inject(
        shellcode: [UInt8],
        stackSize: mach_vm_size_t = 1024 * 1024,
        intoThread thread: Mach.Thread? = nil,
        withInitialState initialState: Mach.ThreadState<some BitwiseCopyable> = .none
    ) throws -> (
        shellcodePointer: UnsafeRawPointer?,
        stackPointer: UnsafeRawPointer?,
        thread: Mach.Thread?
    ) {
        if let targetThread = thread {
            // Check if the target thread belongs to the target task.
            guard try self.threads.contains(targetThread) else {
                // We simulate a kernel error here, because we don't want to implement our own error types.
                throw POSIXError(.EINVAL)
            }
        }
        // Set up shellcode info.
        var shellcodePointer: UnsafeRawPointer? = nil
        let shellcodeSize = mach_vm_size_t(shellcode.count)

        // Allocate memory for the shellcode in the target task.
        try self.vm.allocate(&shellcodePointer, size: shellcodeSize, flags: [.anywhere])

        // Set the memory protections on the shellcode region to allow writing.
        try self.vm.protect(
            shellcodePointer, size: shellcodeSize, setMaximum: false,
            protection: [.read, .write]
        )

        // Write the shellcode to the allocated memory in the target task.
        try shellcode.withUnsafeBytes { shellcodeBytes in
            try self.vm.write(to: shellcodePointer, from: shellcodeBytes)
        }

        // Set the memory protections on the shellcode region to allow execution.
        try self.vm.protect(
            shellcodePointer, size: shellcodeSize, setMaximum: false,
            protection: [.read, .execute]
        )

        // Set up stack info.
        var stackPointer: UnsafeRawPointer? = nil

        /// Allocate memory for the stack in the target task.
        try self.vm.allocate(&stackPointer, size: stackSize, flags: [.anywhere])

        // Set up the thread state for the target task.
        #if arch(arm64)
            guard
                type(of: initialState).DataType == arm_thread_state64_t.self
                    || type(of: initialState).DataType == Void.self
            else { throw POSIXError(.EINVAL) }  // We simulate a kernel error here, because we don't want to implement our own error types.
            var threadState =
                if type(of: initialState).DataType == arm_thread_state64_t.self {
                    initialState.data as! arm_thread_state64_t
                } else {
                    arm_thread_state64_t()
                }
            threadState.__pc = UInt64(UInt(bitPattern: shellcodePointer))
            threadState.__sp = UInt64(UInt(bitPattern: stackPointer) + UInt(stackSize))
            let state: Mach.ThreadState = .arm64(threadState)
        #else
            throw POSIXError(.ENOTSUP)  // We simulate a kernel error here, because we don't want to implement our own error types.
        #endif

        if let targetThread = thread {
            // Set the thread state for the target thread.
            try targetThread.setState(state)

            // Return the shellcode pointer, stack pointer, and thread.
            return (shellcodePointer, stackPointer, targetThread)
        } else {
            // Create a new thread in the target task with the specified thread state.
            let newThread = try Mach.Thread(inTask: self, runningWithState: state)

            // Set the thread state for the new thread.
            try newThread.setState(state)

            // Return the shellcode pointer, stack pointer, and thread.
            return (shellcodePointer, stackPointer, newThread)
        }
    }
}
