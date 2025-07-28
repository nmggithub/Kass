/*
 * Copyright (c) 2008-2013 Apple Inc. All rights reserved.
 * Original:
 * https://github.com/apple-oss-distributions/Libplatform/blob/libplatform-161/private/os/once_private.h
 * No modifications have been made from the original source code except for
 * these lines, the preceding ones, the removal of some unsupported syntax.
 *
 * @APPLE_APACHE_LICENSE_HEADER_START@
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @APPLE_APACHE_LICENSE_HEADER_END@
 */

#ifndef __OS_ONCE_PRIVATE__
#define __OS_ONCE_PRIVATE__

#include <Availability.h>
#include <os/base.h>

OS_ASSUME_NONNULL_BEGIN

__BEGIN_DECLS

#define OS_ONCE_SPI_VERSION 20130313

typedef long os_once_t;

__OSX_AVAILABLE_STARTING(__MAC_10_9, __IPHONE_7_0)
OS_EXPORT OS_NONNULL1 OS_NONNULL3 OS_NOTHROW void
_os_once(os_once_t *predicate, void *_Nullable context, os_function_t function);

/* This SPI is *strictly* for the use of pthread_once only. This is not
 * safe in general use of os_once.
 */
__OSX_AVAILABLE_STARTING(__MAC_10_9, __IPHONE_7_0)
void __os_once_reset(os_once_t *val);

__END_DECLS

OS_ASSUME_NONNULL_END

#endif // __OS_ONCE_PRIVATE__
