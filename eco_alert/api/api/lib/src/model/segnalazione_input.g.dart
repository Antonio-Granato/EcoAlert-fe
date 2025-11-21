// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segnalazione_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SegnalazioneInput extends SegnalazioneInput {
  @override
  final String? titolo;
  @override
  final String descrizione;
  @override
  final double latitudine;
  @override
  final double longitudine;
  @override
  final int idEnte;

  factory _$SegnalazioneInput(
          [void Function(SegnalazioneInputBuilder)? updates]) =>
      (SegnalazioneInputBuilder()..update(updates))._build();

  _$SegnalazioneInput._(
      {this.titolo,
      required this.descrizione,
      required this.latitudine,
      required this.longitudine,
      required this.idEnte})
      : super._();
  @override
  SegnalazioneInput rebuild(void Function(SegnalazioneInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SegnalazioneInputBuilder toBuilder() =>
      SegnalazioneInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SegnalazioneInput &&
        titolo == other.titolo &&
        descrizione == other.descrizione &&
        latitudine == other.latitudine &&
        longitudine == other.longitudine &&
        idEnte == other.idEnte;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, titolo.hashCode);
    _$hash = $jc(_$hash, descrizione.hashCode);
    _$hash = $jc(_$hash, latitudine.hashCode);
    _$hash = $jc(_$hash, longitudine.hashCode);
    _$hash = $jc(_$hash, idEnte.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SegnalazioneInput')
          ..add('titolo', titolo)
          ..add('descrizione', descrizione)
          ..add('latitudine', latitudine)
          ..add('longitudine', longitudine)
          ..add('idEnte', idEnte))
        .toString();
  }
}

class SegnalazioneInputBuilder
    implements Builder<SegnalazioneInput, SegnalazioneInputBuilder> {
  _$SegnalazioneInput? _$v;

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

  int? _idEnte;
  int? get idEnte => _$this._idEnte;
  set idEnte(int? idEnte) => _$this._idEnte = idEnte;

  SegnalazioneInputBuilder() {
    SegnalazioneInput._defaults(this);
  }

  SegnalazioneInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _titolo = $v.titolo;
      _descrizione = $v.descrizione;
      _latitudine = $v.latitudine;
      _longitudine = $v.longitudine;
      _idEnte = $v.idEnte;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SegnalazioneInput other) {
    _$v = other as _$SegnalazioneInput;
  }

  @override
  void update(void Function(SegnalazioneInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SegnalazioneInput build() => _build();

  _$SegnalazioneInput _build() {
    final _$result = _$v ??
        _$SegnalazioneInput._(
          titolo: titolo,
          descrizione: BuiltValueNullFieldError.checkNotNull(
              descrizione, r'SegnalazioneInput', 'descrizione'),
          latitudine: BuiltValueNullFieldError.checkNotNull(
              latitudine, r'SegnalazioneInput', 'latitudine'),
          longitudine: BuiltValueNullFieldError.checkNotNull(
              longitudine, r'SegnalazioneInput', 'longitudine'),
          idEnte: BuiltValueNullFieldError.checkNotNull(
              idEnte, r'SegnalazioneInput', 'idEnte'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
