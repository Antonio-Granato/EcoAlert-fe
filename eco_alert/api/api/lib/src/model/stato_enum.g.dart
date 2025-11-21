// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stato_enum.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const StatoEnum _$INSERITO = const StatoEnum._('INSERITO');
const StatoEnum _$PRESO_IN_CARICO = const StatoEnum._('PRESO_IN_CARICO');
const StatoEnum _$SOSPESO = const StatoEnum._('SOSPESO');
const StatoEnum _$CHIUSO = const StatoEnum._('CHIUSO');

StatoEnum _$valueOf(String name) {
  switch (name) {
    case 'INSERITO':
      return _$INSERITO;
    case 'PRESO_IN_CARICO':
      return _$PRESO_IN_CARICO;
    case 'SOSPESO':
      return _$SOSPESO;
    case 'CHIUSO':
      return _$CHIUSO;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<StatoEnum> _$values = BuiltSet<StatoEnum>(const <StatoEnum>[
  _$INSERITO,
  _$PRESO_IN_CARICO,
  _$SOSPESO,
  _$CHIUSO,
]);

class _$StatoEnumMeta {
  const _$StatoEnumMeta();
  StatoEnum get INSERITO => _$INSERITO;
  StatoEnum get PRESO_IN_CARICO => _$PRESO_IN_CARICO;
  StatoEnum get SOSPESO => _$SOSPESO;
  StatoEnum get CHIUSO => _$CHIUSO;
  StatoEnum valueOf(String name) => _$valueOf(name);
  BuiltSet<StatoEnum> get values => _$values;
}

abstract class _$StatoEnumMixin {
  // ignore: non_constant_identifier_names
  _$StatoEnumMeta get StatoEnum => const _$StatoEnumMeta();
}

Serializer<StatoEnum> _$statoEnumSerializer = _$StatoEnumSerializer();

class _$StatoEnumSerializer implements PrimitiveSerializer<StatoEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'INSERITO': 'INSERITO',
    'PRESO_IN_CARICO': 'PRESO_IN_CARICO',
    'SOSPESO': 'SOSPESO',
    'CHIUSO': 'CHIUSO',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'INSERITO': 'INSERITO',
    'PRESO_IN_CARICO': 'PRESO_IN_CARICO',
    'SOSPESO': 'SOSPESO',
    'CHIUSO': 'CHIUSO',
  };

  @override
  final Iterable<Type> types = const <Type>[StatoEnum];
  @override
  final String wireName = 'StatoEnum';

  @override
  Object serialize(Serializers serializers, StatoEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  StatoEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      StatoEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
