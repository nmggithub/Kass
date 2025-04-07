#include <sys/types.h>

int __syscall(quad_t number, ...);

int syscall0(quad_t number)
{
    return __syscall(number);
}

int syscall1(quad_t number, syscall_arg_t arg1)
{
    return __syscall(number, arg1);
}

int syscall2(quad_t number, syscall_arg_t arg1, syscall_arg_t arg2)
{
    return __syscall(number, arg1, arg2);
}

int syscall3(quad_t number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3)
{
    return __syscall(number, arg1, arg2, arg3);
}

int syscall4(quad_t number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4)
{
    return __syscall(number, arg1, arg2, arg3, arg4);
}

int syscall5(quad_t number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4, syscall_arg_t arg5)
{
    return __syscall(number, arg1, arg2, arg3, arg4, arg5);
}

int syscall6(quad_t number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4, syscall_arg_t arg5, syscall_arg_t arg6)
{
    return __syscall(number, arg1, arg2, arg3, arg4, arg5, arg6);
}

int syscall7(quad_t number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4, syscall_arg_t arg5, syscall_arg_t arg6, syscall_arg_t arg7)
{
    return __syscall(number, arg1, arg2, arg3, arg4, arg5, arg6, arg7);
}

int syscall8(quad_t number, syscall_arg_t arg1, syscall_arg_t arg2, syscall_arg_t arg3, syscall_arg_t arg4, syscall_arg_t arg5, syscall_arg_t arg6, syscall_arg_t arg7, syscall_arg_t arg8)
{
    return __syscall(number, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8);
}