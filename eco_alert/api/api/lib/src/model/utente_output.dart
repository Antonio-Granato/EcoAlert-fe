//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'utente_output.g.dart';

/// UtenteOutput
///
/// Properties:
/// * [id] 
/// * [email] 
/// * [ruolo] 
@BuiltValue()
abstract class UtenteOutput implements Built<UtenteOutput, UtenteOutputBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'ruolo')
  String? get ruolo;

  UtenteOutput._();

  factory UtenteOutput([void updates(UtenteOutputBuilder b)]) = _$UtenteOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UtenteOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UtenteOutput> get serializer => _$UtenteOutputSerializer();
}

class _$UtenteOutputSerializer implements PrimitiveSerializer<UtenteOutput> {
  @override
  final Iterable<Type> types = const [UtenteOutput, _$UtenteOutput];

  @override
  final String wireName = r'UtenteOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UtenteOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.ruolo != null) {
      yield r'ruolo';
      yield serializers.serialize(
        object.ruolo,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UtenteOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UtenteOutputBuilder result,
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
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'ruolo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ruolo = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UtenteOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UtenteOutputBuilder();
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

