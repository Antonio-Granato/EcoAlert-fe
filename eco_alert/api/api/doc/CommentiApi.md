# openapi.api.CommentiApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createCommento**](CommentiApi.md#createcommento) | **POST** /user/{id}/segnalazione/{idSegnalazione}/commenti | Aggiunge un commento a una segnalazione
[**deleteCommento**](CommentiApi.md#deletecommento) | **DELETE** /user/{id}/segnalazione/{idSegnalazione}/commenti/{idCommento} | Elimina un commento da una segnalazione


# **createCommento**
> CommentoOutput createCommento(id, idSegnalazione, commentoInput)

Aggiunge un commento a una segnalazione

Cittadini o enti possono aggiungere commenti solo alle segnalazioni associate ai loro ID.

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getCommentiApi();
final int id = 56; // int | 
final int idSegnalazione = 56; // int | 
final CommentoInput commentoInput = ; // CommentoInput | 

try {
    final response = api.createCommento(id, idSegnalazione, commentoInput);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CommentiApi->createCommento: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **idSegnalazione** | **int**|  | 
 **commentoInput** | [**CommentoInput**](CommentoInput.md)|  | 

### Return type

[**CommentoOutput**](CommentoOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteCommento**
> deleteCommento(id, idSegnalazione, idCommento)

Elimina un commento da una segnalazione

L'utente può eliminare solo i propri commenti sotto la segnalazione. 

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getCommentiApi();
final int id = 56; // int | 
final int idSegnalazione = 56; // int | 
final int idCommento = 56; // int | 

try {
    api.deleteCommento(id, idSegnalazione, idCommento);
} catch on DioException (e) {
    print('Exception when calling CommentiApi->deleteCommento: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **idSegnalazione** | **int**|  | 
 **idCommento** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

