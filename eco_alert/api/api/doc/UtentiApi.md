# openapi.api.UtentiApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getSegnalazioneById**](UtentiApi.md#getsegnalazionebyid) | **GET** /user/{id}/segnalazioni/{idSegnalazione} | Ottiene il dettaglio di una segnalazione
[**getSegnalazioniByUserId**](UtentiApi.md#getsegnalazionibyuserid) | **GET** /user/{id}/segnalazioni | Ottiene le segnalazioni associate all’utente
[**getUserById**](UtentiApi.md#getuserbyid) | **GET** /user/{id} | Ottiene i dettagli di un utente


# **getSegnalazioneById**
> SegnalazioneOutput getSegnalazioneById(id, idSegnalazione)

Ottiene il dettaglio di una segnalazione

Restituisce una segnalazione specifica. - Un cittadino può vedere solo le proprie segnalazioni. - Un ente può vedere solo le segnalazioni associate a sé. 

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUtentiApi();
final int id = 56; // int | ID dell'utente
final int idSegnalazione = 56; // int | ID della segnalazione

try {
    final response = api.getSegnalazioneById(id, idSegnalazione);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UtentiApi->getSegnalazioneById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| ID dell'utente | 
 **idSegnalazione** | **int**| ID della segnalazione | 

### Return type

[**SegnalazioneOutput**](SegnalazioneOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getSegnalazioniByUserId**
> BuiltList<SegnalazioneOutput> getSegnalazioniByUserId(id)

Ottiene le segnalazioni associate all’utente

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUtentiApi();
final int id = 56; // int | 

try {
    final response = api.getSegnalazioniByUserId(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UtentiApi->getSegnalazioniByUserId: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**BuiltList&lt;SegnalazioneOutput&gt;**](SegnalazioneOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getUserById**
> UtenteDettaglioOutput getUserById(id)

Ottiene i dettagli di un utente

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getUtentiApi();
final int id = 56; // int | 

try {
    final response = api.getUserById(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling UtentiApi->getUserById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**UtenteDettaglioOutput**](UtenteDettaglioOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

