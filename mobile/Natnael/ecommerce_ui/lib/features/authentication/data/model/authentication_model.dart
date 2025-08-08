import '../../domain/entity/authentication.dart';

class AuthenticationModel extends Authentication {
  const AuthenticationModel({
    super.name,
    required super.email,
    super.id,
    required super.password,
  });

  factory AuthenticationModel.fromJson(Map<String, dynamic> json) {
    return AuthenticationModel(
      name: json['name'],
      email: json['email'],
      id: json['id'],
      password: '',
    );
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };
    // Only include the name in the JSON if it's not null.
    if (name != null) {
      data['name'] = name;
    }
    
    return data;
  }
}
