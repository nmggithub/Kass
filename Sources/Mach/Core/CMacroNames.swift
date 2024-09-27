import CCompat

extension Mach.TaskSpecialPort: NameableByCMacro {
    public var cMacroName: String {
        switch self {
        case .control: "TASK_CONTROL_PORT"
        case .host: "TASK_HOST_PORT"
        case .name: "TASK_NAME_PORT"
        case .inspect: "TASK_INSPECT_PORT"
        case .read: "TASK_READ_PORT"
        case .access: "TASK_ACCESS_PORT"
        case .debug: "TASK_DEBUG_PORT"
        case .bootstrap: "TASK_BOOTSTRAP_PORT"
        }
    }
}

extension Mach.TaskPolicy {
    public var cMacroName: String {
        switch self {
        case .category: "TASK_CATEGORY_POLICY"
        case .suppression: "TASK_SUPPRESSION_POLICY"
        case .state: "TASK_POLICY_STATE"
        case .baseQoS: "TASK_BASE_QOS_POLICY"
        case .overrideQoS: "TASK_OVERRIDE_QOS_POLICY"
        case .latencyQoS: "TASK_BASE_LATENCY_QOS_POLICY"
        case .throughputQoS: "TASK_BASE_THROUGHPUT_QOS_POLICY"
        }
    }
}

extension Mach.TaskInfo {
    public var cMacroName: String {
        switch self {
        case .basic32: "TASK_BASIC_INFO_32"
        case .basic2_32: "TASK_BASIC2_INFO_32"
        case .basic64: "TASK_BASIC_INFO_64"
        case .events: "TASK_EVENTS_INFO"
        case .threadTimes: "TASK_THREAD_TIMES_INFO"
        case .absoluteTimes: "TASK_ABSOLUTETIME_INFO"
        case .kernelMemory: "TASK_KERNELMEMORY_INFO"
        case .securityToken: "TASK_SECURITY_TOKEN"
        case .auditToken: "TASK_AUDIT_TOKEN"
        case .affinityTag: "TASK_AFFINITY_TAG_INFO"
        case .dyld: "TASK_DYLD_INFO"
        case .basic64_2: "TASK_BASIC_INFO_64"
        case .extmod: "TASK_EXTMOD_INFO"
        case .basic: "MACH_TASK_BASIC_INFO"
        case .power: "TASK_POWER_INFO"
        case .powerV2: "TASK_POWER_INFO_V2"
        case .vm: "TASK_VM_INFO"
        case .vmPurgeable: "TASK_VM_PURGEABLE_INFO"
        case .waitTimes: "TASK_WAIT_STATE_INFO"
        case .flags: "TASK_FLAGS_INFO"
        }
    }
}

extension Mach.TaskRole: NameableByCMacro {
    public var cMacroName: String {
        switch self {
        case .reniced: "TASK_RENICED"
        case .unspecified: "TASK_UNSPECIFIED"
        case .foreground: "TASK_FOREGROUND_APPLICATION"
        case .background: "TASK_BACKGROUND_APPLICATION"
        case .control: "TASK_CONTROL_APPLICATION"
        case .graphicsServer: "TASK_GRAPHICS_SERVER"
        case .throttle: "TASK_THROTTLE_APPLICATION"
        case .nonUI: "TASK_NONUI_APPLICATION"
        case .default: "TASK_DEFAULT_APPLICATION"
        case .darwinBackground: "TASK_DARWINBG_APPLICATION"
        }
    }
}
