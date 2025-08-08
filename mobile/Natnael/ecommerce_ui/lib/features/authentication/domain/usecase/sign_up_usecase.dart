import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entity/authentication.dart';
import '../repository/authentication_repository.dart';

class SignUpUsecase  extends Usecase<Authentication,Params>{
  final AuthenticationRepository repository;

  SignUpUsecase(this.repository);

  @override
  Future<Either<Failure, Authentication>> call(Params params) async {
    return await repository.signUp(params.authentication);
  }
}

class Params extends Equatable{
  final Authentication authentication;

  const Params(this.authentication);

  @override
  List<Object?> get props => [authentication];

}