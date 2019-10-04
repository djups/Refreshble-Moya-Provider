# Refreshable MoyaProvider pure in swift
Subclass of MoyaProvider, that handle 401 error and refresh token without using RxSwift. Easy way to override moya request, checking for authentication token 401 error.

Swift 4.0

How to use:
```
let provider = RefreshbleMoyaProvider<TargetType>(plugins: [Plugins.activity])
```
For token refresh - use your own endpoint and parse JSON reponse.
