import 'dart:html';

class WebStorage {
  static const _tokenKey = 'token';
  static const _userIdKey = 'userId';
  static const _routeKey = 'lastRoute';

  static void setToken(String token) {
    window.localStorage[_tokenKey] = token;
  }

  static String? getToken() {
    return window.localStorage[_tokenKey];
  }

  static void setUserId(int id) {
    window.localStorage[_userIdKey] = id.toString();
  }

  static int? getUserId() {
    final val = window.localStorage[_userIdKey];
    return val != null ? int.tryParse(val) : null;
  }

  static void setLastRoute(String route) {
    window.localStorage[_routeKey] = route;
  }

  static String? getLastRoute() {
    return window.localStorage[_routeKey];
  }

  static void clearAll() {
    window.localStorage.clear();
  }
}
