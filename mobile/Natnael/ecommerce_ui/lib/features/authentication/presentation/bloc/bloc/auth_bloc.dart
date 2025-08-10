import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entity/authentication.dart';
import '../../../domain/usecase/login_usecase.dart' as login_usecase;
import '../../../domain/usecase/logout_usecase.dart';
import '../../../domain/usecase/sign_up_usecase.dart' as sign_up_usecase;

part 'auth_event.dart';
part 'auth_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid Input - The number must be a positive integer';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final login_usecase.LoginUsecase login;
  final LogoutUsecase logout;
  final sign_up_usecase.SignUpUsecase signUp;

  AuthBloc({
    required this.login,
    required this.logout,
    required this.signUp
  }):super(InitialState()){
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<SignUpEvent>(_onSignUp);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure _:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(LoadingState());
    final failureOrSuccess = await login(login_usecase.Params(event.auth));
    failureOrSuccess.fold(
      (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
      (token) => emit(LoginState(token)),
    );
  }


  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  )async{
    emit(LoadingState());
    final failureOrSuccess = await logout(NoParams());
    failureOrSuccess.fold(
      (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
      (_) => emit(const LogoutState()),
    );
  }


  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  )async{
    emit(LoadingState());
    final failureOrSuccess = await signUp(sign_up_usecase.Params(event.auth));
    failureOrSuccess.fold(
      (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
      (Authentication) => emit(SignUpState(Authentication.name ?? '')),
    );
  }



}

