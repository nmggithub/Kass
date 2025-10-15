#include <sys/types.h>
#include <stdint.h>
#include "./proc_reg.h"
#include <mach/vm_types.h>

int syscall(int number, ...);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

int syscall0(int number)
{
    return syscall(number);
}

int syscall1(int number, syscall_arg_t arg1)
{
    return syscall(number, arg1);
}

int syscall2(int number, syscall_arg_t arg1, syscall_arg_t arg2)
{
    return syscall(number, arg1, arg2);
}

int syscall3(int number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3)
{
    return syscall(number, arg1, arg2, arg3);
}

int syscall4(int number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4)
{
    return syscall(number, arg1, arg2, arg3, arg4);
}

int syscall5(int number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4, syscall_arg_t arg5)
{
    return syscall(number, arg1, arg2, arg3, arg4, arg5);
}

int syscall6(int number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4, syscall_arg_t arg5, syscall_arg_t arg6)
{
    return syscall(number, arg1, arg2, arg3, arg4, arg5, arg6);
}

int syscall7(int number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4, syscall_arg_t arg5, syscall_arg_t arg6, syscall_arg_t arg7)
{
    return syscall(number, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}

int syscall8(int number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4, syscall_arg_t arg5, syscall_arg_t arg6, syscall_arg_t arg7, syscall_arg_t arg8)
{
    return syscall(number, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
}

#pragma clang diagnostic pop

