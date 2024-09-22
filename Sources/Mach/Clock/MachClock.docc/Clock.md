# ``MachBase/Mach/Clock``

A clock is a kernel service that provides the time since some specific other time. There are currently two available clocks:

- a **system** clock that serves the time since the last boot, and
- a **calendar** clock that serves the time since the UNIX epoch.