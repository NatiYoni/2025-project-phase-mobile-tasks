import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/authentication_repository.dart';

class LogoutUsecase extends Usecase<void,NoParams>{
  final AuthenticationRepository repository;

  LogoutUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams noParams) async {
    return await repository.logout();
  }
}

