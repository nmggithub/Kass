# ``BSD``

> Important: In some cases, such as if the `Foundation` module is imported, there will be a constant named `BSD` in the global scope that conflicts with this structure. In those cases, `BSDCore.BSD` may be used like so:
> 
>```swift
> // Will compile, but editors may provide incorrect syntax highting / code completion.
> BSD.[...]
> // Fully qualifies the access. Better editor support.
> BSDCore.BSD.[...]
>```
>
> This is not required, but it is recommended.