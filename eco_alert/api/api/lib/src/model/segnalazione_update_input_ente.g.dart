// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segnalazione_update_input_ente.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SegnalazioneUpdateInputEnte extends SegnalazioneUpdateInputEnte {
  @override
  final StatoEnum? stato;
  @override
  final String? ditta;

  factory _$SegnalazioneUpdateInputEnte(
          [void Function(SegnalazioneUpdateInputEnteBuilder)? updates]) =>
      (SegnalazioneUpdateInputEnteBuilder()..update(updates))._build();

  _$SegnalazioneUpdateInputEnte._({this.stato, this.ditta}) : super._();
  @override
  SegnalazioneUpdateInputEnte rebuild(
          void Function(SegnalazioneUpdateInputEnteBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SegnalazioneUpdateInputEnteBuilder toBuilder() =>
      SegnalazioneUpdateInputEnteBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SegnalazioneUpdateInputEnte &&
        stato == other.stato &&
        ditta == other.ditta;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, stato.hashCode);
    _$hash = $jc(_$hash, ditta.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SegnalazioneUpdateInputEnte')
          ..add('stato', stato)
          ..add('ditta', ditta))
        .toString();
  }
}

class SegnalazioneUpdateInputEnteBuilder
    implements
        Builder<SegnalazioneUpdateInputEnte,
            SegnalazioneUpdateInputEnteBuilder> {
  _$SegnalazioneUpdateInputEnte? _$v;

  StatoEnum? _stato;
  StatoEnum? get stato => _$this._stato;
  set stato(StatoEnum? stato) => _$this._stato = stato;

  String? _ditta;
  String? get ditta => _$this._ditta;
  set ditta(String? ditta) => _$this._ditta = ditta;

  SegnalazioneUpdateInputEnteBuilder() {
    SegnalazioneUpdateInputEnte._defaults(this);
  }

  SegnalazioneUpdateInputEnteBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _stato = $v.stato;
      _ditta = $v.ditta;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SegnalazioneUpdateInputEnte other) {
    _$v = other as _$SegnalazioneUpdateInputEnte;
  }

  @override
  void update(void Function(SegnalazioneUpdateInputEnteBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SegnalazioneUpdateInputEnte build() => _build();

  _$SegnalazioneUpdateInputEnte _build() {
    final _$result = _$v ??
        _$SegnalazioneUpdateInputEnte._(
          stato: stato,
          ditta: ditta,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
