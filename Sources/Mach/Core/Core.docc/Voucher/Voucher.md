# ``Mach/Voucher``

## Overview

A voucher is a kernel object that can be attached to a message using the ``Darwin/mach_msg_header_t/voucherPort`` property in the message header. A voucher is created from an array of command **recipes**. The commands are executed in sequence on an empty voucher to result in the desired voucher. Other subsequent commands can then be executed on the voucher.

## Attributes

Vouchers contain **attributes** that are each managed in the kernel by an **attribute manager**. These attributes managers provide the functionality for initial recipe commands, as well as any subsequent commands executed on the voucher.

There are six attributes managers that are "well-known" to the kernel:

| Attribute Manager | Recipe Commands | Subsequent Commands |
| --- | --- | --- |
| ``Mach/VoucherAttributeKey/atm`` | ``Mach/VoucherATMAttributeRecipeCommand`` | ``Mach/VoucherATMAction`` |
| ``Mach/VoucherAttributeKey/importance`` | ``Mach/VoucherImportanceAttributeRecipeCommand`` | ``Mach/VoucherImportanceAction`` |
| ``Mach/VoucherAttributeKey/bank`` | ``Mach/VoucherBankAttributeRecipeCommand`` | ``Mach/VoucherBankAction`` |
| ``Mach/VoucherAttributeKey/pthreadPriority`` | ``Mach/VoucherPthreadPriorityAttributeRecipeCommand`` | Not Supported |
| ``Mach/VoucherAttributeKey/userData`` | ``Mach/VoucherUserDataAttributeRecipeCommand`` | Not Supported |
| ``Mach/VoucherAttributeKey/test`` | Same as ``Mach/VoucherAttributeKey/userData`` | Same as ``Mach/VoucherAttributeKey/userData`` |

## Topics

### Creating Vouchers

- ``init(recipes:)``

### Representing No Voucher

- ``Nil``

### Getting The Recipes In A Voucher

- ``recipes``
- ``recipe(forKey:)``

### Operating On A Voucher

- ``executeCommand(key:command:input:)``