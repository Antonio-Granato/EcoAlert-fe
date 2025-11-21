//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'login_output.g.dart';

/// LoginOutput
///
/// Properties:
/// * [userId] 
/// * [token] 
/// * [ruolo] 
@BuiltValue()
abstract class LoginOutput implements Built<LoginOutput, LoginOutputBuilder> {
  @BuiltValueField(wireName: r'userId')
  int? get userId;

  @BuiltValueField(wireName: r'token')
  String? get token;

  @BuiltValueField(wireName: r'ruolo')
  String? get ruolo;

  LoginOutput._();

  factory LoginOutput([void updates(LoginOutputBuilder b)]) = _$LoginOutput;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LoginOutputBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LoginOutput> get serializer => _$LoginOutputSerializer();
}

class _$LoginOutputSerializer implements PrimitiveSerializer<LoginOutput> {
  @override
  final Iterable<Type> types = const [LoginOutput, _$LoginOutput];

  @override
  final String wireName = r'LoginOutput';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LoginOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.userId != null) {
      yield r'userId';
      yield serializers.serialize(
        object.userId,
        specifiedType: const FullType(int),
      );
    }
    if (object.token != null) {
      yield r'token';
      yield serializers.serialize(
        object.token,
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
    LoginOutput object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LoginOutputBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.userId = valueDes;
          break;
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
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
  LoginOutput deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LoginOutputBuilder();
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

