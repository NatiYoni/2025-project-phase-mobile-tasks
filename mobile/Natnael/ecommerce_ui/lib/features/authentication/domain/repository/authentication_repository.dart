import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entity/authentication.dart';

abstract class AuthenticationRepository {

  Future<Either<Failure, Authentication>> signUp(Authentication authentication);
  Future<Either<Failure, String>> login(Authentication authentication);
  Future<Either<Failure, void>> logout();

}