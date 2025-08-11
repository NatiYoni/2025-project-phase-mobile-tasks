import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entity/authentication.dart';
import '../repository/authentication_repository.dart';

class GetCurrentUserUsecase extends Usecase<Authentication, Params> {
	final AuthenticationRepository repository;
	GetCurrentUserUsecase(this.repository);

	@override
	Future<Either<Failure, Authentication>> call(Params params) {
		return repository.getCurrentUser(params.token);
	}
}

class Params extends Equatable {
	final String token;
	const Params(this.token);
	@override
	List<Object?> get props => [token];
}
