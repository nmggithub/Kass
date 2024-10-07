# ``BSD``

> Important: In some cases, such as if the `Foundation` framework is imported, there will be a constant named `BSD` in the global scope that may conflict with this structure. In those cases, `BSDCore.BSD` may be used like so:
> 
>```swift
> import BSDCore
>
> // May compile, but editors may provide incorrect syntax highting / code completion.
> BSD.[...]
> // Fully qualifies the access. Better editor support.
> BSDCore.BSD.[...]
>```
>
> While use of `BSDCore.BSD` may not be required when this conflict exists, it is recommended.