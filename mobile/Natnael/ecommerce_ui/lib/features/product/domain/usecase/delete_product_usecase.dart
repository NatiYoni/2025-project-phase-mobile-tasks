import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/ProductRepository.dart';

class DeleteProductUsecase  extends Usecase<void, Params>{
  final ProductRepository repository;
  DeleteProductUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(Params params) async{
    return await repository.deleteProduct(params.id);
  }

}

class Params extends Equatable{

  final String id;
  const Params(this.id);

  @override
  List<Object?> get props => [id];

}