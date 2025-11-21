//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'segnalazione_input.g.dart';

/// SegnalazioneInput
///
/// Properties:
/// * [titolo] - Titolo della segnalazione
/// * [descrizione] - Testo della segnalazione
/// * [latitudine] - Latitudine della posizione della segnalazione
/// * [longitudine] - Longitudine della posizione della segnalazione
/// * [idEnte] - ID dell'ente a cui associare la segnalazione
@BuiltValue()
abstract class SegnalazioneInput implements Built<SegnalazioneInput, SegnalazioneInputBuilder> {
  /// Titolo della segnalazione
  @BuiltValueField(wireName: r'titolo')
  String? get titolo;

  /// Testo della segnalazione
  @BuiltValueField(wireName: r'descrizione')
  String get descrizione;

  /// Latitudine della posizione della segnalazione
  @BuiltValueField(wireName: r'latitudine')
  double get latitudine;

  /// Longitudine della posizione della segnalazione
  @BuiltValueField(wireName: r'longitudine')
  double get longitudine;

  /// ID dell'ente a cui associare la segnalazione
  @BuiltValueField(wireName: r'idEnte')
  int get idEnte;

  SegnalazioneInput._();

  factory SegnalazioneInput([void updates(SegnalazioneInputBuilder b)]) = _$SegnalazioneInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SegnalazioneInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SegnalazioneInput> get serializer => _$SegnalazioneInputSerializer();
}

class _$SegnalazioneInputSerializer implements PrimitiveSerializer<SegnalazioneInput> {
  @override
  final Iterable<Type> types = const [SegnalazioneInput, _$SegnalazioneInput];

  @override
  final String wireName = r'SegnalazioneInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SegnalazioneInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.titolo != null) {
      yield r'titolo';
      yield serializers.serialize(
        object.titolo,
        specifiedType: const FullType(String),
      );
    }
    yield r'descrizione';
    yield serializers.serialize(
      object.descrizione,
      specifiedType: const FullType(String),
    );
    yield r'latitudine';
    yield serializers.serialize(
      object.latitudine,
      specifiedType: const FullType(double),
    );
    yield r'longitudine';
    yield serializers.serialize(
      object.longitudine,
      specifiedType: const FullType(double),
    );
    yield r'idEnte';
    yield serializers.serialize(
      object.idEnte,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SegnalazioneInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SegnalazioneInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'titolo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.titolo = valueDes;
          break;
        case r'descrizione':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.descrizione = valueDes;
          break;
        case r'latitudine':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.latitudine = valueDes;
          break;
        case r'longitudine':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(double),
          ) as double;
          result.longitudine = valueDes;
          break;
        case r'idEnte':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.idEnte = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SegnalazioneInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SegnalazioneInputBuilder();
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

