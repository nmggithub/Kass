# ``CCompat``

A module to help bridge the gap between C code and Swift code.

## Topics

### Using C Macros

C macros are often, by convention, named in `ALL_CAPS_SNAKE_CASE`. Swift does not use this convention. If you want to declare a Swift value based on a C macro or macros, you can conform the value to one of these protocols and provide a way to refer back to the macro or macros the value is based on.

- ``NameableByCMacro``
- ``NameableByCMacros``

### Integer Value Enumeration

Some C macros are used to refer to integer values, with each integer referenced by a different macro. You can define a Swift enum of these macros by conforming it to ``CBinIntMacroEnum``.

- ``CBinIntMacroEnum``

### C Option Sets

Some C macros are used in an option set pattern, where the integer values for each macro are OR'ed together to make a bitfield of options. You can define a Swift enum of these options by conforming it to ``COptionMacroEnum``, and you can define a set of these options using ``COptionMacroSet`` with your enum type as the type parameter.

- ``COptionMacroEnum``
- ``COptionMacroSet``