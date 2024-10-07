# ``BSD``

> Important: In some cases, such as if the `Foundation` module is imported, there will be a constant named `BSD` in the global scope that conflicts with this structure. In those cases, `BSDCore.BSD` may be used like so:
> 
>```swift
> import BSDCore
>
> // Will compile, but editors may provide incorrect syntax highting / code completion.
> BSD.[...]
> // Fully qualifies the access. Better editor support.
> BSDCore.BSD.[...]
>```
>
> Use of `BSDCore.BSD` is not required, but it is recommended.