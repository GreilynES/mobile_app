class AuthUser {
  final int id;
  final String username;
  final String email;
  final bool isActive;
  final String roleName;

  AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isActive,
    required this.roleName,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    // El backend devuelve el usuario dentro de un objeto 'user' o directo.
    // Según la especificación del usuario:
    // user.role.name -> roleName
    
    final userMap = json.containsKey('user') ? json['user'] : json;
    
    return AuthUser(
      id: userMap['id'],
      username: userMap['username'],
      email: userMap['email'],
      isActive: userMap['isActive'] ?? true,
      roleName: userMap['role'] != null ? userMap['role']['name'] : 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'isActive': isActive,
      'roleName': roleName,
    };
  }
}
