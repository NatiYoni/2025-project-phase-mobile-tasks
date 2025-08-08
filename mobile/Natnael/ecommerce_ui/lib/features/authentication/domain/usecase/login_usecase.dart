import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entity/authentication.dart';
import '../repository/authentication_repository.dart';

class LoginUsecase  extends Usecase<String,Params>{
  final AuthenticationRepository repository;

  LoginUsecase(this.repository);

  @override
  Future<Either<Failure, String>> call(Params params) async {
    return await repository.login(params.auth);
  }
}

class Params extends Equatable{
  final Authentication auth;

  const Params(this.auth);

  @override
  List<Object?> get props => [auth];

}