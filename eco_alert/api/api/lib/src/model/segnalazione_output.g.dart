// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segnalazione_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SegnalazioneOutput extends SegnalazioneOutput {
  @override
  final int? id;
  @override
  final int? idUtente;
  @override
  final int? idEnte;
  @override
  final String? titolo;
  @override
  final String? descrizione;
  @override
  final double? latitudine;
  @override
  final double? longitudine;
  @override
  final StatoEnum? stato;
  @override
  final String? ditta;
  @override
  final BuiltList<CommentoOutput>? commenti;

  factory _$SegnalazioneOutput(
          [void Function(SegnalazioneOutputBuilder)? updates]) =>
      (SegnalazioneOutputBuilder()..update(updates))._build();

  _$SegnalazioneOutput._(
      {this.id,
      this.idUtente,
      this.idEnte,
      this.titolo,
      this.descrizione,
      this.latitudine,
      this.longitudine,
      this.stato,
      this.ditta,
      this.commenti})
      : super._();
  @override
  SegnalazioneOutput rebuild(
          void Function(SegnalazioneOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SegnalazioneOutputBuilder toBuilder() =>
      SegnalazioneOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SegnalazioneOutput &&
        id == other.id &&
        idUtente == other.idUtente &&
        idEnte == other.idEnte &&
        titolo == other.titolo &&
        descrizione == other.descrizione &&
        latitudine == other.latitudine &&
        longitudine == other.longitudine &&
        stato == other.stato &&
        ditta == other.ditta &&
        commenti == other.commenti;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, idUtente.hashCode);
    _$hash = $jc(_$hash, idEnte.hashCode);
    _$hash = $jc(_$hash, titolo.hashCode);
    _$hash = $jc(_$hash, descrizione.hashCode);
    _$hash = $jc(_$hash, latitudine.hashCode);
    _$hash = $jc(_$hash, longitudine.hashCode);
    _$hash = $jc(_$hash, stato.hashCode);
    _$hash = $jc(_$hash, ditta.hashCode);
    _$hash = $jc(_$hash, commenti.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SegnalazioneOutput')
          ..add('id', id)
          ..add('idUtente', idUtente)
          ..add('idEnte', idEnte)
          ..add('titolo', titolo)
          ..add('descrizione', descrizione)
          ..add('latitudine', latitudine)
          ..add('longitudine', longitudine)
          ..add('stato', stato)
          ..add('ditta', ditta)
          ..add('commenti', commenti))
        .toString();
  }
}

class SegnalazioneOutputBuilder
    implements Builder<SegnalazioneOutput, SegnalazioneOutputBuilder> {
  _$SegnalazioneOutput? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  int? _idUtente;
  int? get idUtente => _$this._idUtente;
  set idUtente(int? idUtente) => _$this._idUtente = idUtente;

  int? _idEnte;
  int? get idEnte => _$this._idEnte;
  set idEnte(int? idEnte) => _$this._idEnte = idEnte;

  String? _titolo;
  String? get titolo => _$this._titolo;
  set titolo(String? titolo) => _$this._titolo = titolo;

  String? _descrizione;
  String? get descrizione => _$this._descrizione;
  set descrizione(String? descrizione) => _$this._descrizione = descrizione;

  double? _latitudine;
  double? get latitudine => _$this._latitudine;
  set latitudine(double? latitudine) => _$this._latitudine = latitudine;

  double? _longitudine;
  double? get longitudine => _$this._longitudine;
  set longitudine(double? longitudine) => _$this._longitudine = longitudine;

  StatoEnum? _stato;
  StatoEnum? get stato => _$this._stato;
  set stato(StatoEnum? stato) => _$this._stato = stato;

  String? _ditta;
  String? get ditta => _$this._ditta;
  set ditta(String? ditta) => _$this._ditta = ditta;

  ListBuilder<CommentoOutput>? _commenti;
  ListBuilder<CommentoOutput> get commenti =>
      _$this._commenti ??= ListBuilder<CommentoOutput>();
  set commenti(ListBuilder<CommentoOutput>? commenti) =>
      _$this._commenti = commenti;

  SegnalazioneOutputBuilder() {
    SegnalazioneOutput._defaults(this);
  }

  SegnalazioneOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _idUtente = $v.idUtente;
      _idEnte = $v.idEnte;
      _titolo = $v.titolo;
      _descrizione = $v.descrizione;
      _latitudine = $v.latitudine;
      _longitudine = $v.longitudine;
      _stato = $v.stato;
      _ditta = $v.ditta;
      _commenti = $v.commenti?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SegnalazioneOutput other) {
    _$v = other as _$SegnalazioneOutput;
  }

  @override
  void update(void Function(SegnalazioneOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SegnalazioneOutput build() => _build();

  _$SegnalazioneOutput _build() {
    _$SegnalazioneOutput _$result;
    try {
      _$result = _$v ??
          _$SegnalazioneOutput._(
            id: id,
            idUtente: idUtente,
            idEnte: idEnte,
            titolo: titolo,
            descrizione: descrizione,
            latitudine: latitudine,
            longitudine: longitudine,
            stato: stato,
            ditta: ditta,
            commenti: _commenti?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'commenti';
        _commenti?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SegnalazioneOutput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
