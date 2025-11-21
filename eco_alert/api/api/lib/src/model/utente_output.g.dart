// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utente_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UtenteOutput extends UtenteOutput {
  @override
  final int? id;
  @override
  final String? email;
  @override
  final String? ruolo;

  factory _$UtenteOutput([void Function(UtenteOutputBuilder)? updates]) =>
      (UtenteOutputBuilder()..update(updates))._build();

  _$UtenteOutput._({this.id, this.email, this.ruolo}) : super._();
  @override
  UtenteOutput rebuild(void Function(UtenteOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UtenteOutputBuilder toBuilder() => UtenteOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UtenteOutput &&
        id == other.id &&
        email == other.email &&
        ruolo == other.ruolo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, ruolo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UtenteOutput')
          ..add('id', id)
          ..add('email', email)
          ..add('ruolo', ruolo))
        .toString();
  }
}

class UtenteOutputBuilder
    implements Builder<UtenteOutput, UtenteOutputBuilder> {
  _$UtenteOutput? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _ruolo;
  String? get ruolo => _$this._ruolo;
  set ruolo(String? ruolo) => _$this._ruolo = ruolo;

  UtenteOutputBuilder() {
    UtenteOutput._defaults(this);
  }

  UtenteOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _ruolo = $v.ruolo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UtenteOutput other) {
    _$v = other as _$UtenteOutput;
  }

  @override
  void update(void Function(UtenteOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UtenteOutput build() => _build();

  _$UtenteOutput _build() {
    final _$result = _$v ??
        _$UtenteOutput._(
          id: id,
          email: email,
          ruolo: ruolo,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
