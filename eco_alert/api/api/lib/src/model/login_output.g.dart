// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_output.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoginOutput extends LoginOutput {
  @override
  final int? userId;
  @override
  final String? token;
  @override
  final String? ruolo;

  factory _$LoginOutput([void Function(LoginOutputBuilder)? updates]) =>
      (LoginOutputBuilder()..update(updates))._build();

  _$LoginOutput._({this.userId, this.token, this.ruolo}) : super._();
  @override
  LoginOutput rebuild(void Function(LoginOutputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoginOutputBuilder toBuilder() => LoginOutputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoginOutput &&
        userId == other.userId &&
        token == other.token &&
        ruolo == other.ruolo;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, ruolo.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LoginOutput')
          ..add('userId', userId)
          ..add('token', token)
          ..add('ruolo', ruolo))
        .toString();
  }
}

class LoginOutputBuilder implements Builder<LoginOutput, LoginOutputBuilder> {
  _$LoginOutput? _$v;

  int? _userId;
  int? get userId => _$this._userId;
  set userId(int? userId) => _$this._userId = userId;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  String? _ruolo;
  String? get ruolo => _$this._ruolo;
  set ruolo(String? ruolo) => _$this._ruolo = ruolo;

  LoginOutputBuilder() {
    LoginOutput._defaults(this);
  }

  LoginOutputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _token = $v.token;
      _ruolo = $v.ruolo;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LoginOutput other) {
    _$v = other as _$LoginOutput;
  }

  @override
  void update(void Function(LoginOutputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoginOutput build() => _build();

  _$LoginOutput _build() {
    final _$result = _$v ??
        _$LoginOutput._(
          userId: userId,
          token: token,
          ruolo: ruolo,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
