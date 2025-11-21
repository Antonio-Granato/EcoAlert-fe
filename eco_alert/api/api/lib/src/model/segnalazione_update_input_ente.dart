//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/stato_enum.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'segnalazione_update_input_ente.g.dart';

/// SegnalazioneUpdateInputEnte
///
/// Properties:
/// * [stato] 
/// * [ditta] - Nome della ditta che gestisce la segnalazione (opzionale)
@BuiltValue()
abstract class SegnalazioneUpdateInputEnte implements Built<SegnalazioneUpdateInputEnte, SegnalazioneUpdateInputEnteBuilder> {
  @BuiltValueField(wireName: r'stato')
  StatoEnum? get stato;
  // enum statoEnum {  INSERITO,  PRESO_IN_CARICO,  SOSPESO,  CHIUSO,  };

  /// Nome della ditta che gestisce la segnalazione (opzionale)
  @BuiltValueField(wireName: r'ditta')
  String? get ditta;

  SegnalazioneUpdateInputEnte._();

  factory SegnalazioneUpdateInputEnte([void updates(SegnalazioneUpdateInputEnteBuilder b)]) = _$SegnalazioneUpdateInputEnte;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SegnalazioneUpdateInputEnteBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SegnalazioneUpdateInputEnte> get serializer => _$SegnalazioneUpdateInputEnteSerializer();
}

class _$SegnalazioneUpdateInputEnteSerializer implements PrimitiveSerializer<SegnalazioneUpdateInputEnte> {
  @override
  final Iterable<Type> types = const [SegnalazioneUpdateInputEnte, _$SegnalazioneUpdateInputEnte];

  @override
  final String wireName = r'SegnalazioneUpdateInputEnte';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SegnalazioneUpdateInputEnte object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.stato != null) {
      yield r'stato';
      yield serializers.serialize(
        object.stato,
        specifiedType: const FullType(StatoEnum),
      );
    }
    if (object.ditta != null) {
      yield r'ditta';
      yield serializers.serialize(
        object.ditta,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SegnalazioneUpdateInputEnte object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SegnalazioneUpdateInputEnteBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stato':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(StatoEnum),
          ) as StatoEnum;
          result.stato = valueDes;
          break;
        case r'ditta':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ditta = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SegnalazioneUpdateInputEnte deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SegnalazioneUpdateInputEnteBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

