import 'package:equatable/equatable.dart';

class Authentication extends Equatable{ 
  final String? name;
  final String email;
  final String password;
  final String? id;
  const Authentication({this.name, required this.email, required this.password, this.id});


  @override
  List<Object?> get props => [id, name, email, password];
}