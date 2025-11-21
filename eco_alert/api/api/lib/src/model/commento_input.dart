//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'commento_input.g.dart';

/// CommentoInput
///
/// Properties:
/// * [descrizione] - Testo del commento
@BuiltValue()
abstract class CommentoInput implements Built<CommentoInput, CommentoInputBuilder> {
  /// Testo del commento
  @BuiltValueField(wireName: r'descrizione')
  String? get descrizione;

  CommentoInput._();

  factory CommentoInput([void updates(CommentoInputBuilder b)]) = _$CommentoInput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CommentoInputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CommentoInput> get serializer => _$CommentoInputSerializer();
}

class _$CommentoInputSerializer implements PrimitiveSerializer<CommentoInput> {
  @override
  final Iterable<Type> types = const [CommentoInput, _$CommentoInput];

  @override
  final String wireName = r'CommentoInput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CommentoInput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.descrizione != null) {
      yield r'descrizione';
      yield serializers.serialize(
        object.descrizione,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CommentoInput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CommentoInputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'descrizione':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.descrizione = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CommentoInput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CommentoInputBuilder();
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

