// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_input.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LoginInput extends LoginInput {
  @override
  final String email;
  @override
  final String password;

  factory _$LoginInput([void Function(LoginInputBuilder)? updates]) =>
      (LoginInputBuilder()..update(updates))._build();

  _$LoginInput._({required this.email, required this.password}) : super._();
  @override
  LoginInput rebuild(void Function(LoginInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LoginInputBuilder toBuilder() => LoginInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LoginInput &&
        email == other.email &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LoginInput')
          ..add('email', email)
          ..add('password', password))
        .toString();
  }
}

class LoginInputBuilder implements Builder<LoginInput, LoginInputBuilder> {
  _$LoginInput? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  LoginInputBuilder() {
    LoginInput._defaults(this);
  }

  LoginInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LoginInput other) {
    _$v = other as _$LoginInput;
  }

  @override
  void update(void Function(LoginInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LoginInput build() => _build();

  _$LoginInput _build() {
    final _$result = _$v ??
        _$LoginInput._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'LoginInput', 'email'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'LoginInput', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
