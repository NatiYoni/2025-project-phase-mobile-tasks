part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable{
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpEvent extends AuthEvent{
  final Authentication auth;

  const SignUpEvent(this.auth);
  @override
  List<Object?> get props => [auth];
}

class LoginEvent extends AuthEvent{
  final Authentication auth;

  const LoginEvent(this.auth);

  @override
  List<Object?> get props => [auth];
}

class LogoutEvent extends AuthEvent{
  const LogoutEvent();
}