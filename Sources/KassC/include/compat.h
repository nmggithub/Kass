#include <mach/port.h>
#include <mach/mach_port.h>

// These values changed from bare macros to a enum declaration in macOS 26, which made them
//  more difficult to use in Swift. We define functions here that work in all cases to help
//  bridge them back to easy usability in Swift.

uint32_t get_mpo_service_port_value(void)
{
    return (uint32_t)MPO_SERVICE_PORT;
}

uint32_t get_mpo_connection_port_value(void)
{
    return (uint32_t)MPO_CONNECTION_PORT;
}

uint32_t get_mpo_reply_port_value(void)
{
    return (uint32_t)MPO_REPLY_PORT;
}

uint32_t get_mpo_provisional_reply_port_value(void)
{
    return (uint32_t)MPO_PROVISIONAL_REPLY_PORT;
}

uint32_t get_mpo_exception_port_value(void)
{
    return (uint32_t)MPO_EXCEPTION_PORT;
}

uint32_t get_mpo_connection_port_with_port_array_value(void)
{
#ifdef MPO_CONNECTION_PORT_WITH_PORT_ARRAY
    return (uint32_t)MPO_CONNECTION_PORT_WITH_PORT_ARRAY;
#else
    return 0;
#endif
}

// macOS 26 introduced the ipc_info_object_type_t enum, but it's still just a `natural_t`.

kern_return_t mach_port_kobject_description_compat(
    ipc_space_read_t task,
    mach_port_name_t name,
    natural_t *object_type,
    mach_vm_address_t *object_addr,
    kobject_description_t description)
{
    return mach_port_kobject_description(
        task,
        name,
#if __MAC_OS_X_VERSION_MAX_ALLOWED < 260000
        object_type,
#else
        (ipc_info_object_type_t *)object_type,
#endif
        object_addr, description);
}