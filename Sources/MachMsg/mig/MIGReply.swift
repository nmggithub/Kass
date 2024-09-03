import Darwin.Mach

/// A Mach Interface Generator (MIG) reply message.
open class MIGReply<Payload: MIGPayload>: TypedMachMessage<Payload> {}
