//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'utente_dettaglio_output.g.dart';

/// UtenteDettaglioOutput
///
/// Properties:
/// * [id] 
/// * [ruolo] 
/// * [email] 
/// * [nome] 
/// * [cognome] 
/// * [nomeEnte] 
/// * [paese] 
/// * [nazione] 
@BuiltValue()
abstract class UtenteDettaglioOutput implements Built<UtenteDettaglioOutput, UtenteDettaglioOutputBuilder> {
  @BuiltValueField(wireName: r'id')
  int? get id;

  @BuiltValueField(wireName: r'ruolo')
  String? get ruolo;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'nome')
  String? get nome;

  @BuiltValueField(wireName: r'cognome')
  String? get cognome;

  @BuiltValueField(wireName: r'nomeEnte')
  String? get nomeEnte;

  @BuiltValueField(wireName: r'paese')
  String? get paese;

  @BuiltValueField(wireName: r'nazione')
  String? get nazione;

  UtenteDettaglioOutput._();

  factory UtenteDettaglioOutput([void updates(UtenteDettaglioOutputBuilder b)]) = _$UtenteDettaglioOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UtenteDettaglioOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UtenteDettaglioOutput> get serializer => _$UtenteDettaglioOutputSerializer();
}

class _$UtenteDettaglioOutputSerializer implements PrimitiveSerializer<UtenteDettaglioOutput> {
  @override
  final Iterable<Type> types = const [UtenteDettaglioOutput, _$UtenteDettaglioOutput];

  @override
  final String wireName = r'UtenteDettaglioOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UtenteDettaglioOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.ruolo != null) {
      yield r'ruolo';
      yield serializers.serialize(
        object.ruolo,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    UtenteDettaglioOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UtenteDettaglioOutputBuilder result,
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
        case r'ruolo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ruolo = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UtenteDettaglioOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UtenteDettaglioOutputBuilder();
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

