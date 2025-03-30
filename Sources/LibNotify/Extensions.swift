import System

extension LibNotify.NotificationName {
    /// Requests that a the file behind a given file descriptor be written to when a notification is posted.
    /// - Important: The value of the token for the name responsible for the notification will be written to the
    ///     file descriptor.
    @available(macOS 11.0, *)
    public func register(fileDescriptor fd: inout FileDescriptor, flags: LibNotify.LibNotifyFlags)
        throws
        -> LibNotify.NotificationToken
    {
        var rawFD = fd.rawValue
        let token = try self.register(fileDescriptor: &rawFD, flags: flags)
        fd = FileDescriptor(rawValue: rawFD)
        return token
    }
}
