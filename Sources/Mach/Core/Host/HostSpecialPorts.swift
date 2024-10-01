import Darwin.Mach

extension Mach {
    /// A special port for a host.
    public struct HostSpecialPort: Mach.Port.SpecialPortType {
        /// The parent port type.
        typealias ParentPort = Mach.Host

        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// Gets a special port for the host.
        public func get<PortType: Mach.Port>(
            for host: Mach.Host = .current, as type: PortType.Type = PortType.self
        ) throws -> PortType {
            try host.getSpecialPort(self, as: type)
        }

        /// Sets a special port for the host.
        public func set(for host: Mach.Host = .current, to port: Mach.Port) throws {
            try host.setSpecialPort(self, to: port)
        }

        /// A unprivileged host port.
        public static let host = Self(rawValue: HOST_PORT)

        /// A privileged host port.
        public static let hostPriv = Self(rawValue: HOST_PRIV_PORT)

        /// A main device port.
        public static let ioMain = Self(rawValue: HOST_IO_MAIN_PORT)

        public static let dynamicPager = Self(rawValue: HOST_DYNAMIC_PAGER_PORT)  // unknown

        public static let auditControl = Self(rawValue: HOST_AUDIT_CONTROL_PORT)  // unknown

        public static let userNotification = Self(rawValue: HOST_USER_NOTIFICATION_PORT)  // `launchd`

        /// A port to `automountd`.
        public static let automountd = Self(rawValue: HOST_AUTOMOUNTD_PORT)

        public static let lockd = Self(rawValue: HOST_LOCKD_PORT)  // `launchd`

        public static let ktraceBackground = Self(rawValue: HOST_KTRACE_BACKGROUND_PORT)  // `launchd`

        /// A port to `sandboxd`.
        public static let seatbelt = Self(rawValue: HOST_SEATBELT_PORT)

        /// A port to `kextd` (now `kernelmanagerd`).
        public static let kextd = Self(rawValue: HOST_KEXTD_PORT)

        public static let launchctl = Self(rawValue: HOST_LAUNCHCTL_PORT)  // unknown

        /// Another port to `fairplayd`.
        public static let unfreed = Self(rawValue: HOST_UNFREED_PORT)

        /// A port to `amfid`.
        public static let amfid = Self(rawValue: HOST_AMFID_PORT)

        public static let gssd = Self(rawValue: HOST_GSSD_PORT)  // `launchd`

        /// A port to `UserEventAgent`.
        public static let telemetry = Self(rawValue: HOST_TELEMETRY_PORT)

        public static let atmNotification = Self(rawValue: HOST_ATM_NOTIFICATION_PORT)  // unknown

        public static let coalition = Self(rawValue: HOST_COALITION_PORT)  // unknown

        /// A port to `sysdiagnosed`.
        public static let sysdiagnosed = Self(rawValue: HOST_SYSDIAGNOSE_PORT)

        public static let xpcException = Self(rawValue: HOST_XPC_EXCEPTION_PORT)  // unknown

        public static let containerd = Self(rawValue: HOST_CONTAINERD_PORT)  // unknown

        public static let node = Self(rawValue: HOST_NODE_PORT)  // unknown

        /// A port to `symptomsd`.
        public static let resourceNotify = Self(rawValue: HOST_RESOURCE_NOTIFY_PORT)

        public static let closured = Self(rawValue: HOST_CLOSURED_PORT)  // unknown

        /// A port to `syspolicyd`.
        public static let syspolicyd = Self(rawValue: HOST_SYSPOLICYD_PORT)

        /// A port to `filecoordinationd`
        public static let filecoordinationd = Self(rawValue: HOST_FILECOORDINATIOND_PORT)

        /// A port to `fairplayd`.
        public static let fairplayd = Self(rawValue: HOST_FAIRPLAYD_PORT)

        public static let ioCompressionStats = Self(rawValue: HOST_IOCOMPRESSIONSTATS_PORT)  // unknown

        /// A port to `mmaintenanced`.
        public static let memoryError = Self(rawValue: HOST_MEMORY_ERROR_PORT)

        /// (Probably) a port to `managedappdistributiond`.
        public static let managedappdistd = Self(rawValue: HOST_MANAGEDAPPDISTD_PORT)  // unknown

        public static let doubleagentd = Self(rawValue: HOST_DOUBLEAGENTD_PORT)  // `launchd`
    }
}

extension Mach.Host: Mach.Port.WithSpecialPorts {
    /// Gets a special port for the host.
    public func getSpecialPort<PortType: Mach.Port>(
        _ specialPort: Mach.HostSpecialPort, as type: PortType.Type = PortType.self
    ) throws -> PortType {
        var portName = mach_port_name_t()
        try Mach.call(
            // for historical reasons, we pass in HOST_LOCAL_NODE as the second parameter
            host_get_special_port(self.name, HOST_LOCAL_NODE, specialPort.rawValue, &portName)
        )
        return PortType(named: portName)
    }

    /// Sets a special port for the host.
    public func setSpecialPort(_ specialPort: Mach.HostSpecialPort, to port: Mach.Port) throws {
        try Mach.call(
            host_set_special_port(self.name, specialPort.rawValue, port.name)
        )
    }
}

extension Mach.Host {
    /// The unprivileged host port.
    public var hostPort: Mach.Host {
        get throws { try getSpecialPort(.host) }
    }

    /// The privileged host port.
    /// - Important: On unprivileged tasks, this will return the same as ``hostPort``.
    public var hostPortPrivileged: Mach.Host {
        get throws { try getSpecialPort(.hostPriv) }
    }
}
