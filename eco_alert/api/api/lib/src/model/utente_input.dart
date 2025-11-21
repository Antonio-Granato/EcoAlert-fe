//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'utente_input.g.dart';

/// UtenteInput
///
/// Properties:
/// * [nome] 
/// * [cognome] 
/// * [email] 
/// * [password] 
/// * [paese] 
/// * [nazione] 
/// * [ruolo] 
@BuiltValue()
abstract class UtenteInput implements Built<UtenteInput, UtenteInputBuilder> {
  @BuiltValueField(wireName: r'nome')
  String? get nome;

  @BuiltValueField(wireName: r'cognome')
  String? get cognome;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'password')
  String? get password;

  @BuiltValueField(wireName: r'paese')
  String? get paese;

  @BuiltValueField(wireName: r'nazione')
  String? get nazione;

  @BuiltValueField(wireName: r'ruolo')
  String? get ruolo;

  UtenteInput._();

  factory UtenteInput([void updates(UtenteInputBuilder b)]) = _$UtenteInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UtenteInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UtenteInput> get serializer => _$UtenteInputSerializer();
}

class _$UtenteInputSerializer implements PrimitiveSerializer<UtenteInput> {
  @override
  final Iterable<Type> types = const [UtenteInput, _$UtenteInput];

  @override
  final String wireName = r'UtenteInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UtenteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.nome != null) {
      yield r'nome';
      yield serializers.serialize(
        object.nome,
        specifiedType: const FullType(String),
      );
    }
    if (object.cognome != null) {
      yield r'cognome';
      yield serializers.serialize(
        object.cognome,
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
    if (object.password != null) {
      yield r'password';
      yield serializers.serialize(
        object.password,
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
    UtenteInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UtenteInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'nome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nome = valueDes;
          break;
        case r'cognome':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cognome = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
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
  UtenteInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UtenteInputBuilder();
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

