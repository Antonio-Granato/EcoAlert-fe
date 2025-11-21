# openapi.api.SegnalazioniApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createSegnalazione**](SegnalazioniApi.md#createsegnalazione) | **POST** /user/{id}/segnalazione | Crea una nuova segnalazione
[**deleteSegnalazione**](SegnalazioniApi.md#deletesegnalazione) | **DELETE** /user/{id}/segnalazioni/{idSegnalazione} | Elimina una segnalazione appartenente al cittadino
[**updateSegnalazione**](SegnalazioniApi.md#updatesegnalazione) | **PUT** /user/{id}/segnalazioni/{idSegnalazione} | Modifica una segnalazione del cittadino
[**updateSegnalazioneEnte**](SegnalazioniApi.md#updatesegnalazioneente) | **PUT** /segnalazioni/{idSegnalazione}/ente | Aggiorna lo stato e/o la ditta di una segnalazione


# **createSegnalazione**
> SegnalazioneOutput createSegnalazione(id, segnalazioneInput)

Crea una nuova segnalazione

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getSegnalazioniApi();
final int id = 56; // int | 
final SegnalazioneInput segnalazioneInput = ; // SegnalazioneInput | 

try {
    final response = api.createSegnalazione(id, segnalazioneInput);
    print(response);
} catch on DioException (e) {
    print('Exception when calling SegnalazioniApi->createSegnalazione: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **segnalazioneInput** | [**SegnalazioneInput**](SegnalazioneInput.md)|  | 

### Return type

[**SegnalazioneOutput**](SegnalazioneOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteSegnalazione**
> deleteSegnalazione(id, idSegnalazione)

Elimina una segnalazione appartenente al cittadino

Un cittadino può eliminare **solo** una sua segnalazione **non in stato di inserito**. Un ente non può eliminare alcuna segnalazione. 

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getSegnalazioniApi();
final int id = 56; // int | 
final int idSegnalazione = 56; // int | 

try {
    api.deleteSegnalazione(id, idSegnalazione);
} catch on DioException (e) {
    print('Exception when calling SegnalazioniApi->deleteSegnalazione: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **idSegnalazione** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSegnalazione**
> SegnalazioneOutput updateSegnalazione(id, idSegnalazione, segnalazioneInput)

Modifica una segnalazione del cittadino

Un cittadino può modificare **solo le proprie segnalazioni non chiuse**. Solo il titolo, la descrizione, la latitudine, la longitudine e l'ente associato possono essere aggiornati. 

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getSegnalazioniApi();
final int id = 56; // int | 
final int idSegnalazione = 56; // int | 
final SegnalazioneInput segnalazioneInput = ; // SegnalazioneInput | 

try {
    final response = api.updateSegnalazione(id, idSegnalazione, segnalazioneInput);
    print(response);
} catch on DioException (e) {
    print('Exception when calling SegnalazioniApi->updateSegnalazione: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **idSegnalazione** | **int**|  | 
 **segnalazioneInput** | [**SegnalazioneInput**](SegnalazioneInput.md)|  | 

### Return type

[**SegnalazioneOutput**](SegnalazioneOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateSegnalazioneEnte**
> SegnalazioneOutput updateSegnalazioneEnte(idSegnalazione, idEnte, segnalazioneUpdateInputEnte)

Aggiorna lo stato e/o la ditta di una segnalazione

Permette a un ente di aggiornare lo stato di una segnalazione (da INSERITO a PRESO_IN_CARICO, SOSPESO o CHIUSO) e di inserire la ditta che risolve la segnalazione. 

### Example
```dart
import 'package:openapi/api.dart';

final api = Openapi().getSegnalazioniApi();
final int idSegnalazione = 56; // int | 
final int idEnte = 56; // int | 
final SegnalazioneUpdateInputEnte segnalazioneUpdateInputEnte = ; // SegnalazioneUpdateInputEnte | 

try {
    final response = api.updateSegnalazioneEnte(idSegnalazione, idEnte, segnalazioneUpdateInputEnte);
    print(response);
} catch on DioException (e) {
    print('Exception when calling SegnalazioniApi->updateSegnalazioneEnte: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **idSegnalazione** | **int**|  | 
 **idEnte** | **int**|  | 
 **segnalazioneUpdateInputEnte** | [**SegnalazioneUpdateInputEnte**](SegnalazioneUpdateInputEnte.md)|  | 

### Return type

[**SegnalazioneOutput**](SegnalazioneOutput.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

