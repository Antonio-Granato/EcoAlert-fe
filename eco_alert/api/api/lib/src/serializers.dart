//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/commento_input.dart';
import 'package:openapi/src/model/commento_output.dart';
import 'package:openapi/src/model/ente_output.dart';
import 'package:openapi/src/model/error.dart';
import 'package:openapi/src/model/login_input.dart';
import 'package:openapi/src/model/login_output.dart';
import 'package:openapi/src/model/segnalazione_input.dart';
import 'package:openapi/src/model/segnalazione_output.dart';
import 'package:openapi/src/model/segnalazione_update_input_ente.dart';
import 'package:openapi/src/model/stato_enum.dart';
import 'package:openapi/src/model/utente_dettaglio_output.dart';
import 'package:openapi/src/model/utente_input.dart';
import 'package:openapi/src/model/utente_output.dart';

part 'serializers.g.dart';

@SerializersFor([
  CommentoInput,
  CommentoOutput,
  EnteOutput,
  Error,
  LoginInput,
  LoginOutput,
  SegnalazioneInput,
  SegnalazioneOutput,
  SegnalazioneUpdateInputEnte,
  StatoEnum,
  UtenteDettaglioOutput,
  UtenteInput,
  UtenteOutput,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(EnteOutput)]),
        () => ListBuilder<EnteOutput>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SegnalazioneOutput)]),
        () => ListBuilder<SegnalazioneOutput>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
