part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class InitialState extends AuthState {}

class LoadingState extends AuthState {}

class SignUpState extends AuthState{
  final String name;

  const SignUpState(this.name);
  @override
  List<Object> get props => [name];
}

class LoginState extends AuthState{
  final String token;

  const LoginState(this.token);

  @override
  List<Object> get props => [token];
}

class LogoutState extends AuthState{
  const LogoutState();
}

class ErrorState extends AuthState {
  final String message;

  const ErrorState(this.message);

  @override
  List<Object> get props => [message];
}