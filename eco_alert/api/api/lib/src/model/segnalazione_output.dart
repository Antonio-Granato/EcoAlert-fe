//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/commento_output.dart';
import 'package:openapi/src/model/stato_enum.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'segnalazione_output.g.dart';

/// SegnalazioneOutput
///
/// Properties:
/// * [id] - ID della segnalazione
/// * [idUtente] - ID del cittadino che ha creato la segnalazione
/// * [idEnte] - ID dell'ente associato alla segnalazione
/// * [titolo] - Titolo della segnalazione
/// * [descrizione] - Testo della segnalazione
/// * [latitudine] - Latitudine della segnalazione
/// * [longitudine] - Longitudine della segnalazione
/// * [stato] 
/// * [ditta] - Ditta della segnalazione
/// * [commenti] 
@BuiltValue()
abstract class SegnalazioneOutput implements Built<SegnalazioneOutput, SegnalazioneOutputBuilder> {
  /// ID della segnalazione
  @BuiltValueField(wireName: r'id')
  int? get id;

  /// ID del cittadino che ha creato la segnalazione
  @BuiltValueField(wireName: r'idUtente')
  int? get idUtente;

  /// ID dell'ente associato alla segnalazione
  @BuiltValueField(wireName: r'idEnte')
  int? get idEnte;

  /// Titolo della segnalazione
  @BuiltValueField(wireName: r'titolo')
  String? get titolo;

  /// Testo della segnalazione
  @BuiltValueField(wireName: r'descrizione')
  String? get descrizione;

  /// Latitudine della segnalazione
  @BuiltValueField(wireName: r'latitudine')
  double? get latitudine;

  /// Longitudine della segnalazione
  @BuiltValueField(wireName: r'longitudine')
  double? get longitudine;

  @BuiltValueField(wireName: r'stato')
  StatoEnum? get stato;
  // enum statoEnum {  INSERITO,  PRESO_IN_CARICO,  SOSPESO,  CHIUSO,  };

  /// Ditta della segnalazione
  @BuiltValueField(wireName: r'ditta')
  String? get ditta;

  @BuiltValueField(wireName: r'commenti')
  BuiltList<CommentoOutput>? get commenti;

  SegnalazioneOutput._();

  factory SegnalazioneOutput([void updates(SegnalazioneOutputBuilder b)]) = _$SegnalazioneOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SegnalazioneOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SegnalazioneOutput> get serializer => _$SegnalazioneOutputSerializer();
}

class _$SegnalazioneOutputSerializer implements PrimitiveSerializer<SegnalazioneOutput> {
  @override
  final Iterable<Type> types = const [SegnalazioneOutput, _$SegnalazioneOutput];

  @override
  final String wireName = r'SegnalazioneOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SegnalazioneOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(int),
      );
    }
    if (object.idUtente != null) {
      yield r'idUtente';
      yield serializers.serialize(
        object.idUtente,
        specifiedType: const FullType(int),
      );
    }
    if (object.idEnte != null) {
      yield r'idEnte';
      yield serializers.serialize(
        object.idEnte,
        specifiedType: const FullType(int),
      );
    }
    if (object.titolo != null) {
      yield r'titolo';
      yield serializers.serialize(
        object.titolo,
        specifiedType: const FullType(String),
      );
    }
    if (object.descrizione != null) {
      yield r'descrizione';
      yield serializers.serialize(
        object.descrizione,
        specifiedType: const FullType(String),
      );
    }
    if (object.latitudine != null) {
      yield r'latitudine';
      yield serializers.serialize(
        object.latitudine,
        specifiedType: const FullType(double),
      );
    }
    if (object.longitudine != null) {
      yield r'longitudine';
      yield serializers.serialize(
        object.longitudine,
        specifiedType: const FullType(double),
      );
    }
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
    if (object.commenti != null) {
      yield r'commenti';
      yield serializers.serialize(
        object.commenti,
        specifiedType: const FullType(BuiltList, [FullType(CommentoOutput)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SegnalazioneOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SegnalazioneOutputBuilder result,
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
        case r'idUtente':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.idUtente = valueDes;
          break;
        case r'idEnte':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.idEnte = valueDes;
          break;
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
        case r'commenti':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(CommentoOutput)]),
          ) as BuiltList<CommentoOutput>;
          result.commenti.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SegnalazioneOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SegnalazioneOutputBuilder();
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

