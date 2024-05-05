class User {
  int? id;
  String username;
  String password;

  User({this.id, required this.username, required this.password});

  // Método de fábrica para crear un User desde un mapa de datos
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }

  // Método para convertir un User a un mapa de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }
}
