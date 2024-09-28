# ``Mach/Port/destroy()``

<!-- This message is copied from the deprecation message for `mach_port_destroy` and modified to refer to this library's API. -->
@DeprecationSummary {
    Inherently unsafe API: instead manage rights with
    ``destruct(guard:sendRightDelta:)``, ``deallocate()`` or ``userRefs(for:)``.
}