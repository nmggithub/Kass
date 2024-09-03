import Darwin.Mach

/// A Mach Interface Generator (MIG) request message.
open class MIGRequest<Payload: MIGPayload>: MachMessage<Payload> {}
