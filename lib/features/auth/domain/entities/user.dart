class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final int accessLevel;
  final int autoLogoutMinutes;
  final String token;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'viewer',
    this.accessLevel = 0,
    this.autoLogoutMinutes = 0,
    this.token = '',
    this.createdAt,
  });

  bool get isAdmin => role == 'admin' || role == 'Administrator';
  bool get isOperator => role == 'operator' || role == 'Operator' || isAdmin;
  bool get isViewer => true;

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    int? accessLevel,
    int? autoLogoutMinutes,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      accessLevel: accessLevel ?? this.accessLevel,
      autoLogoutMinutes: autoLogoutMinutes ?? this.autoLogoutMinutes,
      token: token ?? this.token,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'UserName': name,
    'Roles': [role],
    'AccessLevel': accessLevel,
    'AutoLogOutMin': autoLogoutMinutes,
    'Token': token,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['UserName'] ?? '',
    name: json['UserName'] ?? '',
    email: json['UserName'] ?? '',
    role: (json['Roles'] as List<dynamic>?)?.first?.toString() ?? 'viewer',
    accessLevel: json['AccessLevel'] ?? 0,
    autoLogoutMinutes: json['AutoLogOutMin'] ?? 0,
    token: json['Token'] ?? '',
  );
}
