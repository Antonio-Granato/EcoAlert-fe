//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'stato_enum.g.dart';

class StatoEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'INSERITO')
  static const StatoEnum INSERITO = _$INSERITO;
  @BuiltValueEnumConst(wireName: r'PRESO_IN_CARICO')
  static const StatoEnum PRESO_IN_CARICO = _$PRESO_IN_CARICO;
  @BuiltValueEnumConst(wireName: r'SOSPESO')
  static const StatoEnum SOSPESO = _$SOSPESO;
  @BuiltValueEnumConst(wireName: r'CHIUSO')
  static const StatoEnum CHIUSO = _$CHIUSO;

  static Serializer<StatoEnum> get serializer => _$statoEnumSerializer;

  const StatoEnum._(String name): super(name);

  static BuiltSet<StatoEnum> get values => _$values;
  static StatoEnum valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class StatoEnumMixin = Object with _$StatoEnumMixin;

