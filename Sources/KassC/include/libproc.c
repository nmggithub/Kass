/*
 * Copyright (c) 2006-2018 Apple Inc. All rights reserved.
 *
 * Original: https://github.com/apple-oss-distributions/xnu/blob/xnu-11215.41.3/libsyscall/wrappers/libproc/libproc.c
 * Only the sycall wrapper definitons have been included in this file.
 *
 * @APPLE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this
 * file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_LICENSE_HEADER_END@
 */

#include <unistd.h>

int __proc_info(int callnum, int pid, int flavor, uint64_t arg, void * buffer, int buffersize);
int __proc_info_extended_id(int32_t callnum, int32_t pid, uint32_t flavor, uint32_t flags, uint64_t ext_id, uint64_t arg, user_addr_t buffer, int32_t buffersize);