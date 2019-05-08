# Refreshble MoyaProvider
Subclass of MoyaProvider, that handle 401 error and refresh token without using RxSwift. Easy way to override moya request, checking for authentication token 401 error.


How to use:
```
let provider = RefreshbleMoyaProvider<MainView>(plugins: [Plugins.activity])
```
