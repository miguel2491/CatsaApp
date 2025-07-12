// user_session.dart
class Sessiones {
  static final Sessiones _instance = Sessiones._internal();

  factory Sessiones() {
    return _instance;
  }

  Sessiones._internal();

  // Aquí almacenas los datos que necesitas
  String? token;
  String? userId;
  String? nombre;

  void clear() {
    token = null;
    userId = null;
    nombre = null;
  }
}
