// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commento_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommentoOutput extends CommentoOutput {
  @override
  final int? id;
  @override
  final String? descrizione;

  factory _$CommentoOutput([void Function(CommentoOutputBuilder)? updates]) =>
      (CommentoOutputBuilder()..update(updates))._build();

  _$CommentoOutput._({this.id, this.descrizione}) : super._();
  @override
  CommentoOutput rebuild(void Function(CommentoOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommentoOutputBuilder toBuilder() => CommentoOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommentoOutput &&
        id == other.id &&
        descrizione == other.descrizione;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, descrizione.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommentoOutput')
          ..add('id', id)
          ..add('descrizione', descrizione))
        .toString();
  }
}

class CommentoOutputBuilder
    implements Builder<CommentoOutput, CommentoOutputBuilder> {
  _$CommentoOutput? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _descrizione;
  String? get descrizione => _$this._descrizione;
  set descrizione(String? descrizione) => _$this._descrizione = descrizione;

  CommentoOutputBuilder() {
    CommentoOutput._defaults(this);
  }

  CommentoOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _descrizione = $v.descrizione;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommentoOutput other) {
    _$v = other as _$CommentoOutput;
  }

  @override
  void update(void Function(CommentoOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommentoOutput build() => _build();

  _$CommentoOutput _build() {
    final _$result = _$v ??
        _$CommentoOutput._(
          id: id,
          descrizione: descrizione,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
