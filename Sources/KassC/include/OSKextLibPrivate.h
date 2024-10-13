/*
 * Portions Copyright (c) 1998-2000 Apple Inc. All rights reserved.
 *
 * Original: https://github.com/apple-oss-distributions/xnu/blob/xnu-11215.1.10/libkern/libkern/OSKextLibPrivate.h
 * Only the log-related constants from the original file are included here.
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

#ifndef _LIBKERN_OSKEXTLIBPRIVATE_H
#define _LIBKERN_OSKEXTLIBPRIVATE_H


#include <sys/cdefs.h>

__BEGIN_DECLS

#include <libkern/OSTypes.h>
#include <mach/kmod.h>

#ifdef KERNEL
#include <mach/vm_types.h>
#endif /* KERNEL */

__END_DECLS

#include <libkern/OSReturn.h>

__BEGIN_DECLS

#if PRAGMA_MARK
#pragma mark -
/********************************************************************/
#pragma mark Kext Log Specification
/********************************************************************/
#endif
/*!
 * @group Kext Log Specification
 * Logging levels & flags for kernel extensions.
 * See <code>@link //apple_ref/c/tdef/OSKextLogSpec OSKextLogSpec@/link</code>
 * for an overview.
 */

/*!
 * @typedef  OSKextLogSpec
 * @abstract Describes what a log message applies to,
 *           or a filter that determines which log messages are displayed.
 *
 * @discussion
 * A kext log specification is a 32-bit value used as a desription of
 * what a given log message applies to, or as a filter
 * indicating which log messages are desired and which are not.
 * A log specification has three parts (described in detail shortly):
 * <ul>
 *   <li>A <b>level</b> from 0-7 in the lowest-order nibble (0x7).</li>
 *   <li>A flag bit in the lowest-order nibble (0x8) indicating whether
 *       log messages tied to individual kexts are always printed (1)
 *       or printed only if the kext has an
 *       @link //apple_ref/c/macro/kOSBundleEnableKextLoggingKey
 *       OSBundleEnableKextLogging@/link set to <code>true</code>.
 *   <li>A set of <b>activity flags</b> in the remaining nibbles (0xFFFFFFF0),
 *       which describe areas of activity related to kernel extensions.</li>
 * </ul>
 *
 * You can specify a log spec to most of the kext tools with the -v option
 * and a hex number (rather than the escalating decimal levels 0-6).
 * You can also specify a log spec to the kernel with the "kextlog" boot arg
 * or "debug.kextlog" sysctl.
 *
 * <b>Log Levels</b>
 *
 * The log level spans a range from silent (no log messages)
 * to debuging information:
 *
 * <ol start="0">
 * <li>Silent - Not applicable to messages; as a filter, do not print any log messages.</li>
 * <li>Errors - Log message is an error.
 * <li>Warnings - Log message is a warning.
 * <li>Basic information - Log message is basic success/failure.</li>
 * <li>Progress - Provides high-level information about stages in processing.</li>
 * <li>Step - Provides low-level information about complex operations,
 *          typically about individual kexts.</li>
 * <li>Detail - Provides very low-level information about parts of kexts,
 *          including individual Libkern classes and operations on bundle files.</li>
 * <li>Debug - Very verbose logging about internal activities.</li>
 * </ol>
 *
 * Log messages at
 * <code>@link kOSKextLogErrorLevel kOSKextLogErrorLevel@/link</code> or
 * <code>@link kOSKextLogWarningLevel kOSKextLogWarningLevel@/link</code>
 * ignore activity flags and the
 * @link //apple_ref/c/macro/kOSBundleEnableKextLoggingKey
 * OSBundleEnableKextLogging@/link property;
 * that is, only the filter level is checked for messages at these levels.
 * Log messages at levels above
 * <code>@link kOSKextLogWarningLevel kOSKextLogWarningLevel@/link</code>
 * are filtered according both to the activity flags in the current filter
 * and to whether the log message is associated with a kext or not.
 * Normally log messages associated with kexts are not printed
 * unless the kext has a
 * @link //apple_ref/c/macro/kOSBundleEnableKextLoggingKey
 * OSBundleEnableKextLogging@/link property set to <code>true</code>.
 * If you set the high-order bit of the log level (that is, add 8 to the level),
 * then all kext-specific log messages matching the activity flags are printed.
 * This can be very verbose.
 *
 * <b>Activity Flags</b>
 *
 * Each flag governs a category of activity,
 * such as loading, IPC, or archives; by combining them with bitwise OR,
 * you can choose which messages you wish to see (or when logging messages,
 * which bit flags select your message).
 *
 * <b>Byte 1:</b> <code>0xF0</code> - Basic activities
 * (<code>@link kOSKextLogGeneralFlag kOSKextLogGeneralFlag@/link</code>,
 * <code>@link kOSKextLogLoadFlag kOSKextLogLoadFlag@/link</code>, and
 * <code>@link kOSKextLogArchiveFlag kOSKextLogArchiveFlag@/link</code>).
 *
 * <b>Byte 2:</b> <code>0xF00</code> - Reserved.
 *
 * <b>Byte 4:</b> <code>0xF000</code> - Kext diagnostics
 * (<code>@link kOSKextLogValidationFlag kOSKextLogValidationFlag@/link</code>,
 * <code>@link kOSKextLogAuthenticationFlag kOSKextLogAuthenticationFlag@/link</code>, and
 * <code>@link kOSKextLogDependenciesFlag kOSKextLogDependenciesFlag@/link</code>).
 *
 * <b>Byte 5:</b> <code>0xF00000</code> - Kext access & bookkeeping
 * (<code>@link kOSKextLogDirectoryScanFlag kOSKextLogDirectoryScanFlag@/link</code>,
 * <code>@link kOSKextLogFileAccessFlag kOSKextLogFileAccessFlag@/link</code>,
 * <code>@link kOSKextLogKextBookkeepingFlag kOSKextLogKextBookkeepingFlag@/link </code>).
 *
 * <b>Byte 6:</b> <code>0xF000000</code> - Linking & patching
 * (<code>@link kOSKextLogLinkFlag kOSKextLogLinkFlag@/link</code> and
 * <code>@link kOSKextLogPatchFlag kOSKextLogPatchFlag@/link</code>).
 *
 * <b>Byte 7:</b> <code>0xF0000000</code> - Reserved.
 */
typedef uint32_t OSKextLogSpec;

#if PRAGMA_MARK
/********************************************************************/
#pragma mark Masks
/********************************************************************/
#endif
/*!
 * @define   kOSKextLogLevelMask
 * @abstract Masks the bottom 3 bits of an
 *           <code>@link OSKextLogSpec OSKextLogSpec@/link</code> to extract
 *           the raw level.
 */
#define kOSKextLogLevelMask              ((OSKextLogSpec) 0x00000007)

/*!
 * @define   kOSKextLogKextOrGlobalMask
 * @abstract Determines whether per-kext log messages are output.
 *
 * @discussion
 * In filter specifications, if unset (the usual default),
 * then log messages associated with a kext are only output
 * if the kext has an
 * @link //apple_ref/c/macro/kOSBundleEnableKextLoggingKey
 * OSBundleEnableKextLogging@/link
 * property set to <code>true</code>.
 * If set, then all log messages associated with kexts
 * are output.
 *
 * In message specifications, if set it indicates that the message is either
 * not associated with a kext, or is associated with a kext that has an
 * @link //apple_ref/c/macro/kOSBundleEnableKextLoggingKey
 * OSBundleEnableKextLogging@/link
 * property set to <code>true</code>.
 */
#define kOSKextLogKextOrGlobalMask       ((OSKextLogSpec) 0x00000008)


/*!
 * @define   kOSKextLogFlagsMask
 * @abstract Masks the flag bits of an
 *           <code>@link OSKextLogSpec OSKextLogSpec@/link</code>.
 */
#define kOSKextLogFlagsMask              ((OSKextLogSpec) 0x0ffffff0)

/*!
 * @define   kOSKextLogFlagsMask
 * @abstract Masks the flag bits of an
 *           <code>@link OSKextLogSpec OSKextLogSpec@/link</code>
 *           to which command-line <code>-v</code> levels apply.
 */
#define kOSKextLogVerboseFlagsMask       ((OSKextLogSpec) 0x00000ff0)

/*!
 * @define   kOSKextLogConfigMask
 * @abstract Masks the config bits of an
 *           <code>@link OSKextLogSpec OSKextLogSpec@/link</code>.
 */
#define kOSKextLogConfigMask             ((OSKextLogSpec) 0xf0000000)

#if PRAGMA_MARK
/********************************************************************/
#pragma mark 0xF - Log Level
/********************************************************************/
#endif

/*!
 * @define   kOSKextLogExplicitLevel
 * @abstract Used when logging a message to overrides the current log filter,
 *           even if it's set to silent for log messages.
 *           This is essentially a pass-through for
 *           unconditional print messages to go
 *           through the logging engine.
 */
#define kOSKextLogExplicitLevel          ((OSKextLogSpec)        0x0)

/*!
 * @define   kOSKextLogErrorLevel
 * @abstract Log messages concerning error conditions in any category.
 */
#define kOSKextLogErrorLevel            ((OSKextLogSpec)        0x1)


/*!
 * @define   kOSKextLogWarningLevel
 * @abstract Log messages concerning warning conditions in any category,
 *           which indicate potential error conditions,
 *           and notices, which may explain unexpected but correct behavior.
 */
#define kOSKextLogWarningLevel          ((OSKextLogSpec)        0x2)


/*!
 * @define   kOSKextLogBasicLevel
 * @abstract Log messages concerning top-level outcome in any category
 *           (kext load/unload, kext cache creation/extration w/# kexts).
 */
#define kOSKextLogBasicLevel           ((OSKextLogSpec)        0x3)


/*!
 * @define   kOSKextLogProgressLevel
 * @abstract Log messages concerning high-level progress in any category,
 *           such as sending a load request to the kernel,
 *           allocation/link/map/start (load operation),
 *           stop/unmap (unload operation), kext added/extracted (archive).
 */
#define kOSKextLogProgressLevel          ((OSKextLogSpec)        0x4)


/*!
 * @define   kOSKextLogStepLevel
 * @abstract Log messages concerning major steps in any category,
 *           such as sending personalities to the IOCatalogue when loading,
 *           detailed IPC with the kernel, or filtering of kexts for an archive.
 */
#define kOSKextLogStepLevel             ((OSKextLogSpec)        0x5)


/*!
 * @define   kOSKextLogDetailLevel
 * @abstract Log messages concerning specific details in any category,
 *           such as classes being registered/unregistered or
 *           operations on indivdual files in a kext.
 */
#define kOSKextLogDetailLevel           ((OSKextLogSpec)        0x6)


/*!
 * @define   kOSKextLogDebugLevel
 * @abstract Log messages concerning very low-level actions that are
 *           useful mainly for debugging the kext system itself.
 */
#define kOSKextLogDebugLevel             ((OSKextLogSpec)        0x7)


#if PRAGMA_MARK
/********************************************************************/
#pragma mark 0xF0 - General Activity, Load, Kernel IPC, Personalities
/********************************************************************/
#endif

/*!
 * @define   kOSKextLogGeneralFlag
 * @abstract Log messages about general activity in the kext system.
 */
#define kOSKextLogGeneralFlag            ((OSKextLogSpec)       0x10)

/*!
 * @define   kOSKextLogLoadFlag
 * @abstract Log messages regarding kernel extension load, start/stop, or unload activity
 *           in the kernel.
 */
#define kOSKextLogLoadFlag               ((OSKextLogSpec)       0x20)

/*!
 * @define   kOSKextLogIPCFlag
 * @abstract Log messages about any interaction between kernel and user space
 *           regarding kernel extensions.
 */
#define kOSKextLogIPCFlag                ((OSKextLogSpec)       0x40)

/*!
 * @define   kOSKextLogArchiveFlag
 * @abstract Log messages about creating or processing a kext startup cache file
 *           (mkext or prelinked kernel).
 */
#define kOSKextLogArchiveFlag           ((OSKextLogSpec)       0x80)


#if PRAGMA_MARK
/********************************************************************/
#pragma mark 0xF00 - Reserved Verbose Area
/********************************************************************/
#endif
// reserved slot for group               ((OSKextLogSpec)      0x100)
// reserved slot for group               ((OSKextLogSpec)      0x200)
// reserved slot for group               ((OSKextLogSpec)      0x400)
// reserved slot for group               ((OSKextLogSpec)      0x800)

#if PRAGMA_MARK
/********************************************************************/
#pragma mark 0xF000 - Kext diagnostic activity
/********************************************************************/
#endif

/*!
 * @define   kOSKextLogValidationFlag
 * @abstract Log messages when validating kernel extensions.
 */
#define kOSKextLogValidationFlag         ((OSKextLogSpec)     0x1000)

/*!
 * @define   kOSKextLogAuthenticationFlag
 * @abstract Log messages when autnenticating kernel extension files.
 *           Irrelevant in the kernel.
 */
#define kOSKextLogAuthenticationFlag     ((OSKextLogSpec)     0x2000)

/*!
 * @define   kOSKextLogDependenciesFlag
 * @abstract Log messages when resolving dependencies for a kernel extension.
 */
#define kOSKextLogDependenciesFlag       ((OSKextLogSpec)     0x4000)

// reserved slot for group               ((OSKextLogSpec)     0x8000)

#if PRAGMA_MARK
/********************************************************************/
#pragma mark 0xF0000 - Archives, caches, directory scan, file access
/********************************************************************/
#endif

/*!
 * @define   kOSKextLogDirectoryScanFlag
 * @abstract Log messages when scanning directories for kernel extensions.
 *           In the kernel logs every booter kext entry processed.
 */
#define kOSKextLogDirectoryScanFlag      ((OSKextLogSpec)    0x10000)

/*!
 * @define   kOSKextLogFileAccessFlag
 * @abstract Log messages when performing any filesystem access (very verbose).
 *           Irrelevant in the kernel.
 */
#define kOSKextLogFileAccessFlag         ((OSKextLogSpec)    0x20000)

/*!
 * @define   kOSKextLogKextBookkeepingFlag
 * @abstract Log messages about internal tracking of kexts. Can be very verbose.
 */
#define kOSKextLogKextBookkeepingFlag    ((OSKextLogSpec)    0x40000)

// reserved slot for group               ((OSKextLogSpec)    0x80000)

#if PRAGMA_MARK
/********************************************************************/
#pragma mark 0xF00000 - Linking & Patching
/********************************************************************/
#endif

/*!
 * @define   kOSKextLogLinkFlag
 * @abstract Log messages about linking.
 */
#define kOSKextLogLinkFlag               ((OSKextLogSpec)   0x100000)

/*!
 * @define   kOSKextLogPatchFlag
 * @abstract Log messages about patching.
 */
#define kOSKextLogPatchFlag              ((OSKextLogSpec)   0x200000)

// reserved slot for group               ((OSKextLogSpec)   0x400000)
// reserved slot for group               ((OSKextLogSpec)   0x800000)

#if PRAGMA_MARK
/********************************************************************/
#pragma mark 0xF000000 - Reserved
/********************************************************************/
#endif

// reserved slot for grouping            ((OSKextLogSpec)  0x1000000)
// reserved slot for grouping            ((OSKextLogSpec)  0x2000000)
// reserved slot for grouping            ((OSKextLogSpec)  0x4000000)
// reserved slot for grouping            ((OSKextLogSpec)  0x8000000)


#if PRAGMA_MARK
/********************************************************************/
#pragma mark 0xF0000000 - Config Flags
/********************************************************************/
#endif

// reserved slot for grouping            ((OSKextLogSpec) 0x10000000)
// reserved slot for grouping            ((OSKextLogSpec) 0x20000000)
// reserved slot for grouping            ((OSKextLogSpec) 0x40000000)

#if PRAGMA_MARK
/********************************************************************/
#pragma mark Predefined Specifications
/********************************************************************/
#endif

/*!
 * @define   kOSKextLogSilentFilter
 * @abstract For use in filter specs:
 *           Ignore all log messages with a log level greater than
 *           <code>@link kOSKextLogExplicitLevel kOSKextLogExplicitLevel@/link</code>.
 */
#define kOSKextLogSilentFilter           ((OSKextLogSpec)        0x0)

/*!
 * @define   kOSKextLogShowAllFilter
 * @abstract For use in filter specs:
 *           Print all log messages not associated with a kext or
 *           associated with a kext that has
 *           @link //apple_ref/c/macro/kOSBundleEnableKextLoggingKey
 *           OSBundleEnableKextLogging@/link
 *           set to <code>true</code>.
 */
#define kOSKextLogShowAllFilter          ((OSKextLogSpec) 0x0ffffff7)

/*!
 * @define   kOSKextLogShowAllKextsFilter
 * @abstract For use in filter specs:
 *           Print all log messages has
 *           @link //apple_ref/c/macro/kOSBundleEnableKextLoggingKey
 *           OSBundleEnableKextLogging@/link
 *           set to <code>true</code>.
 */
#define kOSKextLogShowAllKextsFilter     ((OSKextLogSpec) \
	                                   (kOSKextLogShowAllFilter | \
	                                    kOSKextLogKextOrGlobalMask))

__END_DECLS

#endif /* ! _LIBKERN_OSKEXTLIBPRIVATE_H */
