// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utente_dettaglio_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UtenteDettaglioOutput extends UtenteDettaglioOutput {
  @override
  final int? id;
  @override
  final String? ruolo;
  @override
  final String? email;
  @override
  final String? nome;
  @override
  final String? cognome;
  @override
  final String? nomeEnte;
  @override
  final String? paese;
  @override
  final String? nazione;

  factory _$UtenteDettaglioOutput(
          [void Function(UtenteDettaglioOutputBuilder)? updates]) =>
      (UtenteDettaglioOutputBuilder()..update(updates))._build();

  _$UtenteDettaglioOutput._(
      {this.id,
      this.ruolo,
      this.email,
      this.nome,
      this.cognome,
      this.nomeEnte,
      this.paese,
      this.nazione})
      : super._();
  @override
  UtenteDettaglioOutput rebuild(
          void Function(UtenteDettaglioOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UtenteDettaglioOutputBuilder toBuilder() =>
      UtenteDettaglioOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UtenteDettaglioOutput &&
        id == other.id &&
        ruolo == other.ruolo &&
        email == other.email &&
        nome == other.nome &&
        cognome == other.cognome &&
        nomeEnte == other.nomeEnte &&
        paese == other.paese &&
        nazione == other.nazione;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ruolo.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, nome.hashCode);
    _$hash = $jc(_$hash, cognome.hashCode);
    _$hash = $jc(_$hash, nomeEnte.hashCode);
    _$hash = $jc(_$hash, paese.hashCode);
    _$hash = $jc(_$hash, nazione.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UtenteDettaglioOutput')
          ..add('id', id)
          ..add('ruolo', ruolo)
          ..add('email', email)
          ..add('nome', nome)
          ..add('cognome', cognome)
          ..add('nomeEnte', nomeEnte)
          ..add('paese', paese)
          ..add('nazione', nazione))
        .toString();
  }
}

class UtenteDettaglioOutputBuilder
    implements Builder<UtenteDettaglioOutput, UtenteDettaglioOutputBuilder> {
  _$UtenteDettaglioOutput? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _ruolo;
  String? get ruolo => _$this._ruolo;
  set ruolo(String? ruolo) => _$this._ruolo = ruolo;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _nome;
  String? get nome => _$this._nome;
  set nome(String? nome) => _$this._nome = nome;

  String? _cognome;
  String? get cognome => _$this._cognome;
  set cognome(String? cognome) => _$this._cognome = cognome;

  String? _nomeEnte;
  String? get nomeEnte => _$this._nomeEnte;
  set nomeEnte(String? nomeEnte) => _$this._nomeEnte = nomeEnte;

  String? _paese;
  String? get paese => _$this._paese;
  set paese(String? paese) => _$this._paese = paese;

  String? _nazione;
  String? get nazione => _$this._nazione;
  set nazione(String? nazione) => _$this._nazione = nazione;

  UtenteDettaglioOutputBuilder() {
    UtenteDettaglioOutput._defaults(this);
  }

  UtenteDettaglioOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ruolo = $v.ruolo;
      _email = $v.email;
      _nome = $v.nome;
      _cognome = $v.cognome;
      _nomeEnte = $v.nomeEnte;
      _paese = $v.paese;
      _nazione = $v.nazione;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UtenteDettaglioOutput other) {
    _$v = other as _$UtenteDettaglioOutput;
  }

  @override
  void update(void Function(UtenteDettaglioOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UtenteDettaglioOutput build() => _build();

  _$UtenteDettaglioOutput _build() {
    final _$result = _$v ??
        _$UtenteDettaglioOutput._(
          id: id,
          ruolo: ruolo,
          email: email,
          nome: nome,
          cognome: cognome,
          nomeEnte: nomeEnte,
          paese: paese,
          nazione: nazione,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
