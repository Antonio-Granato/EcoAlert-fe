import 'dart:html' as html;

class WebStorage {
  static void setLastRoute(String route) =>
      html.window.localStorage['eco_last_route'] = route;
  static String? getLastRoute() => html.window.localStorage['eco_last_route'];
  static void setUserId(int id) =>
      html.window.localStorage['eco_user_id'] = id.toString();
  static int? getUserId() {
    final v = html.window.localStorage['eco_user_id'];
    if (v == null) return null;
    return int.tryParse(v);
  }

  static void clearAll() {
    html.window.localStorage.remove('eco_user_id');
    html.window.localStorage.remove('eco_last_route');
  }
}
