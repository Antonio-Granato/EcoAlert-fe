// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utente_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UtenteInput extends UtenteInput {
  @override
  final String? nome;
  @override
  final String? cognome;
  @override
  final String? email;
  @override
  final String? password;
  @override
  final String? paese;
  @override
  final String? nazione;
  @override
  final String? ruolo;

  factory _$UtenteInput([void Function(UtenteInputBuilder)? updates]) =>
      (UtenteInputBuilder()..update(updates))._build();

  _$UtenteInput._(
      {this.nome,
      this.cognome,
      this.email,
      this.password,
      this.paese,
      this.nazione,
      this.ruolo})
      : super._();
  @override
  UtenteInput rebuild(void Function(UtenteInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UtenteInputBuilder toBuilder() => UtenteInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UtenteInput &&
        nome == other.nome &&
        cognome == other.cognome &&
        email == other.email &&
        password == other.password &&
        paese == other.paese &&
        nazione == other.nazione &&
        ruolo == other.ruolo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nome.hashCode);
    _$hash = $jc(_$hash, cognome.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, paese.hashCode);
    _$hash = $jc(_$hash, nazione.hashCode);
    _$hash = $jc(_$hash, ruolo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UtenteInput')
          ..add('nome', nome)
          ..add('cognome', cognome)
          ..add('email', email)
          ..add('password', password)
          ..add('paese', paese)
          ..add('nazione', nazione)
          ..add('ruolo', ruolo))
        .toString();
  }
}

class UtenteInputBuilder implements Builder<UtenteInput, UtenteInputBuilder> {
  _$UtenteInput? _$v;

  String? _nome;
  String? get nome => _$this._nome;
  set nome(String? nome) => _$this._nome = nome;

  String? _cognome;
  String? get cognome => _$this._cognome;
  set cognome(String? cognome) => _$this._cognome = cognome;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  String? _paese;
  String? get paese => _$this._paese;
  set paese(String? paese) => _$this._paese = paese;

  String? _nazione;
  String? get nazione => _$this._nazione;
  set nazione(String? nazione) => _$this._nazione = nazione;

  String? _ruolo;
  String? get ruolo => _$this._ruolo;
  set ruolo(String? ruolo) => _$this._ruolo = ruolo;

  UtenteInputBuilder() {
    UtenteInput._defaults(this);
  }

  UtenteInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nome = $v.nome;
      _cognome = $v.cognome;
      _email = $v.email;
      _password = $v.password;
      _paese = $v.paese;
      _nazione = $v.nazione;
      _ruolo = $v.ruolo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UtenteInput other) {
    _$v = other as _$UtenteInput;
  }

  @override
  void update(void Function(UtenteInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UtenteInput build() => _build();

  _$UtenteInput _build() {
    final _$result = _$v ??
        _$UtenteInput._(
          nome: nome,
          cognome: cognome,
          email: email,
          password: password,
          paese: paese,
          nazione: nazione,
          ruolo: ruolo,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
