#include <stdint.h>
#include "./proc_reg.h"
#include <mach/vm_types.h>

static inline uint64_t platform_syscall(uint32_t code,
                                     uint64_t a0,
                                     uint64_t a1,
                                     uint64_t a2) {
  register uint64_t x0 asm("x0") = a0;
  register uint64_t x1 asm("x1") = a1;
  register uint64_t x2 asm("x2") = a2;
  register uint64_t x3 asm("x3") = (uint64_t)code;
  register uint64_t x16 asm("x16") = PLATFORM_SYSCALL_TRAP_NO;  // PLATFORM_SYSCALL_TRAP_NO

  asm volatile("svc #0x80"
               : "+r"(x0)
               : "r"(x1), "r"(x2), "r"(x3), "r"(x16)
               : "memory", "cc");

  return x0;
}

static inline void platform_set_cthread_self(vm_address_t addr) {
  (void)platform_syscall(2, addr, 0, 0);
}

static inline vm_address_t platform_get_cthread_self(void) {
  return platform_syscall(3, 0, 0, 0);
}