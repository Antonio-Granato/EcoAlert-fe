# openapi.model.SegnalazioneOutput

## Load the model package
```dart
import 'package:openapi/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **int** | ID della segnalazione | [optional] 
**idUtente** | **int** | ID del cittadino che ha creato la segnalazione | [optional] 
**idEnte** | **int** | ID dell'ente associato alla segnalazione | [optional] 
**titolo** | **String** | Titolo della segnalazione | [optional] 
**descrizione** | **String** | Testo della segnalazione | [optional] 
**latitudine** | **double** | Latitudine della segnalazione | [optional] 
**longitudine** | **double** | Longitudine della segnalazione | [optional] 
**stato** | [**StatoEnum**](StatoEnum.md) |  | [optional] 
**ditta** | **String** | Ditta della segnalazione | [optional] 
**commenti** | [**BuiltList&lt;CommentoOutput&gt;**](CommentoOutput.md) |  | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


