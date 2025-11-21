//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ente_output.g.dart';

/// EnteOutput
///
/// Properties:
/// * [id] 
/// * [nomeEnte] 
/// * [paese] 
/// * [nazione] 
/// * [email] 
@BuiltValue()
abstract class EnteOutput implements Built<EnteOutput, EnteOutputBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'nomeEnte')
  String? get nomeEnte;

  @BuiltValueField(wireName: r'paese')
  String? get paese;

  @BuiltValueField(wireName: r'nazione')
  String? get nazione;

  @BuiltValueField(wireName: r'email')
  String? get email;

  EnteOutput._();

  factory EnteOutput([void updates(EnteOutputBuilder b)]) = _$EnteOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(EnteOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<EnteOutput> get serializer => _$EnteOutputSerializer();
}

class _$EnteOutputSerializer implements PrimitiveSerializer<EnteOutput> {
  @override
  final Iterable<Type> types = const [EnteOutput, _$EnteOutput];

  @override
  final String wireName = r'EnteOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    EnteOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.nomeEnte != null) {
      yield r'nomeEnte';
      yield serializers.serialize(
        object.nomeEnte,
        specifiedType: const FullType(String),
      );
    }
    if (object.paese != null) {
      yield r'paese';
      yield serializers.serialize(
        object.paese,
        specifiedType: const FullType(String),
      );
    }
    if (object.nazione != null) {
      yield r'nazione';
      yield serializers.serialize(
        object.nazione,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    EnteOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required EnteOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.id = valueDes;
          break;
        case r'nomeEnte':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nomeEnte = valueDes;
          break;
        case r'paese':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.paese = valueDes;
          break;
        case r'nazione':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nazione = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  EnteOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = EnteOutputBuilder();
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

