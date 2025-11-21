# openapi.api.EntiApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getAllEnti**](EntiApi.md#getallenti) | **GET** /enti | Ottiene la lista di tutti gli enti


# **getAllEnti**
> BuiltList<EnteOutput> getAllEnti()

Ottiene la lista di tutti gli enti

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getEntiApi();

try {
    final response = api.getAllEnti();
    print(response);
} catch on DioException (e) {
    print('Exception when calling EntiApi->getAllEnti: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;EnteOutput&gt;**](EnteOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

