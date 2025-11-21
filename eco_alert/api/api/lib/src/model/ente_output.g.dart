// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ente_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EnteOutput extends EnteOutput {
  @override
  final int? id;
  @override
  final String? nomeEnte;
  @override
  final String? paese;
  @override
  final String? nazione;
  @override
  final String? email;

  factory _$EnteOutput([void Function(EnteOutputBuilder)? updates]) =>
      (EnteOutputBuilder()..update(updates))._build();

  _$EnteOutput._({this.id, this.nomeEnte, this.paese, this.nazione, this.email})
      : super._();
  @override
  EnteOutput rebuild(void Function(EnteOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EnteOutputBuilder toBuilder() => EnteOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EnteOutput &&
        id == other.id &&
        nomeEnte == other.nomeEnte &&
        paese == other.paese &&
        nazione == other.nazione &&
        email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, nomeEnte.hashCode);
    _$hash = $jc(_$hash, paese.hashCode);
    _$hash = $jc(_$hash, nazione.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EnteOutput')
          ..add('id', id)
          ..add('nomeEnte', nomeEnte)
          ..add('paese', paese)
          ..add('nazione', nazione)
          ..add('email', email))
        .toString();
  }
}

class EnteOutputBuilder implements Builder<EnteOutput, EnteOutputBuilder> {
  _$EnteOutput? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _nomeEnte;
  String? get nomeEnte => _$this._nomeEnte;
  set nomeEnte(String? nomeEnte) => _$this._nomeEnte = nomeEnte;

  String? _paese;
  String? get paese => _$this._paese;
  set paese(String? paese) => _$this._paese = paese;

  String? _nazione;
  String? get nazione => _$this._nazione;
  set nazione(String? nazione) => _$this._nazione = nazione;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  EnteOutputBuilder() {
    EnteOutput._defaults(this);
  }

  EnteOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _nomeEnte = $v.nomeEnte;
      _paese = $v.paese;
      _nazione = $v.nazione;
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EnteOutput other) {
    _$v = other as _$EnteOutput;
  }

  @override
  void update(void Function(EnteOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EnteOutput build() => _build();

  _$EnteOutput _build() {
    final _$result = _$v ??
        _$EnteOutput._(
          id: id,
          nomeEnte: nomeEnte,
          paese: paese,
          nazione: nazione,
          email: email,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
