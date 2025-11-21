# openapi.api.AuthApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**login**](AuthApi.md#login) | **POST** /login | Effettua il login dell&#39;utente
[**signIn**](AuthApi.md#signin) | **POST** /sign-in | Registra un nuovo utente


# **login**
> LoginOutput login(loginInput)

Effettua il login dell'utente

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAuthApi();
final LoginInput loginInput = ; // LoginInput | 

try {
    final response = api.login(loginInput);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginInput** | [**LoginInput**](LoginInput.md)|  | 

### Return type

[**LoginOutput**](LoginOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **signIn**
> UtenteOutput signIn(utenteInput)

Registra un nuovo utente

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getAuthApi();
final UtenteInput utenteInput = ; // UtenteInput | 

try {
    final response = api.signIn(utenteInput);
    print(response);
} catch on DioException (e) {
    print('Exception when calling AuthApi->signIn: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **utenteInput** | [**UtenteInput**](UtenteInput.md)|  | 

### Return type

[**UtenteOutput**](UtenteOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

