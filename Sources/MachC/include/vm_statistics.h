/*
 * Portions Copyright (c) 2000-2020 Apple Inc. All rights reserved.
 *
 * Only the private constants from the original file are included here.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 *
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */
/*
 * @OSF_COPYRIGHT@
 */
/*
 * Mach Operating System
 * Copyright (c) 1991,1990,1989,1988,1987 Carnegie Mellon University
 * All Rights Reserved.
 *
 * Permission to use, copy, modify and distribute this software and its
 * documentation is hereby granted, provided that both the copyright
 * notice and this permission notice appear in all copies of the
 * software, derivative works or modified versions, and any portions
 * thereof, and that both notices appear in supporting documentation.
 *
 * CARNEGIE MELLON ALLOWS FREE USE OF THIS SOFTWARE IN ITS "AS IS"
 * CONDITION.  CARNEGIE MELLON DISCLAIMS ANY LIABILITY OF ANY KIND FOR
 * ANY DAMAGES WHATSOEVER RESULTING FROM THE USE OF THIS SOFTWARE.
 *
 * Carnegie Mellon requests users of this software to return to
 *
 *  Software Distribution Coordinator  or  Software.Distribution@CS.CMU.EDU
 *  School of Computer Science
 *  Carnegie Mellon University
 *  Pittsburgh PA 15213-3890
 *
 * any improvements or extensions that they make and grant Carnegie Mellon
 * the rights to redistribute these changes.
 */
/*
 */
/*
 *	File:	mach/vm_statistics.h
 *	Author:	Avadis Tevanian, Jr., Michael Wayne Young, David Golub
 *
 *	Virtual memory statistics structure.
 *
 */

#include <sys/cdefs.h>

#include <mach/machine/vm_types.h>
#include <mach/machine/kern_return.h>

__BEGIN_DECLS

/* kernel map tags */
/* please add new definition strings to zprint */

#define VM_KERN_MEMORY_NONE 0

#define VM_KERN_MEMORY_OSFMK 1
#define VM_KERN_MEMORY_BSD 2
#define VM_KERN_MEMORY_IOKIT 3
#define VM_KERN_MEMORY_LIBKERN 4
#define VM_KERN_MEMORY_OSKEXT 5
#define VM_KERN_MEMORY_KEXT 6
#define VM_KERN_MEMORY_IPC 7
#define VM_KERN_MEMORY_STACK 8
#define VM_KERN_MEMORY_CPU 9
#define VM_KERN_MEMORY_PMAP 10
#define VM_KERN_MEMORY_PTE 11
#define VM_KERN_MEMORY_ZONE 12
#define VM_KERN_MEMORY_KALLOC 13
#define VM_KERN_MEMORY_COMPRESSOR 14
#define VM_KERN_MEMORY_COMPRESSED_DATA 15
#define VM_KERN_MEMORY_PHANTOM_CACHE 16
#define VM_KERN_MEMORY_WAITQ 17
#define VM_KERN_MEMORY_DIAG 18
#define VM_KERN_MEMORY_LOG 19
#define VM_KERN_MEMORY_FILE 20
#define VM_KERN_MEMORY_MBUF 21
#define VM_KERN_MEMORY_UBC 22
#define VM_KERN_MEMORY_SECURITY 23
#define VM_KERN_MEMORY_MLOCK 24
#define VM_KERN_MEMORY_REASON 25
#define VM_KERN_MEMORY_SKYWALK 26
#define VM_KERN_MEMORY_LTABLE 27
#define VM_KERN_MEMORY_HV 28
#define VM_KERN_MEMORY_KALLOC_DATA 29
#define VM_KERN_MEMORY_RETIRED 30
#define VM_KERN_MEMORY_KALLOC_TYPE 31
#define VM_KERN_MEMORY_TRIAGE 32
#define VM_KERN_MEMORY_RECOUNT 33
#define VM_KERN_MEMORY_EXCLAVES 35
/* add new tags here and adjust first-dynamic value */
#define VM_KERN_MEMORY_FIRST_DYNAMIC 36

/* out of tags: */
#define VM_KERN_MEMORY_ANY 255
#define VM_KERN_MEMORY_COUNT 256

/* end kernel map tags */

// mach_memory_info.flags
#define VM_KERN_SITE_TYPE 0x000000FF
#define VM_KERN_SITE_TAG 0x00000000
#define VM_KERN_SITE_KMOD 0x00000001
#define VM_KERN_SITE_KERNEL 0x00000002
#define VM_KERN_SITE_COUNTER 0x00000003
#define VM_KERN_SITE_WIRED 0x00000100 /* add to wired count */
#define VM_KERN_SITE_HIDE 0x00000200  /* no zprint */
#define VM_KERN_SITE_NAMED 0x00000400
#define VM_KERN_SITE_ZONE 0x00000800
#define VM_KERN_SITE_ZONE_VIEW 0x00001000
#define VM_KERN_SITE_KALLOC 0x00002000 /* zone field is size class */

#define VM_KERN_COUNT_MANAGED 0
#define VM_KERN_COUNT_RESERVED 1
#define VM_KERN_COUNT_WIRED 2
#define VM_KERN_COUNT_WIRED_MANAGED 3
#define VM_KERN_COUNT_STOLEN 4
#define VM_KERN_COUNT_LOPAGE 5
#define VM_KERN_COUNT_MAP_KERNEL 6
#define VM_KERN_COUNT_MAP_ZONE 7
#define VM_KERN_COUNT_MAP_KALLOC 8

#define VM_KERN_COUNT_WIRED_BOOT 9

#define VM_KERN_COUNT_BOOT_STOLEN 10

/* The number of bytes from the kernel cache that are wired in memory */
#define VM_KERN_COUNT_WIRED_STATIC_KERNELCACHE 11

#define VM_KERN_COUNT_MAP_KALLOC_LARGE VM_KERN_COUNT_MAP_KALLOC
#define VM_KERN_COUNT_MAP_KALLOC_LARGE_DATA 12
#define VM_KERN_COUNT_MAP_KERNEL_DATA 13

#define VM_KERN_COUNTER_COUNT 14

__END_DECLS
