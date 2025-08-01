// The macOS SDK's don't expose this to Swift, so we need to do it manually.
#include <voucher/ipc_pthread_priority_types.h>
// only on macOS
#if TARGET_OS_MAC && !TARGET_OS_IPHONE
#include <atm/atm_types.h>
#endif