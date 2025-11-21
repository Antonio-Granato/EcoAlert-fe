// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commento_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommentoInput extends CommentoInput {
  @override
  final String? descrizione;

  factory _$CommentoInput([void Function(CommentoInputBuilder)? updates]) =>
      (CommentoInputBuilder()..update(updates))._build();

  _$CommentoInput._({this.descrizione}) : super._();
  @override
  CommentoInput rebuild(void Function(CommentoInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommentoInputBuilder toBuilder() => CommentoInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommentoInput && descrizione == other.descrizione;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, descrizione.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommentoInput')
          ..add('descrizione', descrizione))
        .toString();
  }
}

class CommentoInputBuilder
    implements Builder<CommentoInput, CommentoInputBuilder> {
  _$CommentoInput? _$v;

  String? _descrizione;
  String? get descrizione => _$this._descrizione;
  set descrizione(String? descrizione) => _$this._descrizione = descrizione;

  CommentoInputBuilder() {
    CommentoInput._defaults(this);
  }

  CommentoInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _descrizione = $v.descrizione;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommentoInput other) {
    _$v = other as _$CommentoInput;
  }

  @override
  void update(void Function(CommentoInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommentoInput build() => _build();

  _$CommentoInput _build() {
    final _$result = _$v ??
        _$CommentoInput._(
          descrizione: descrizione,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
