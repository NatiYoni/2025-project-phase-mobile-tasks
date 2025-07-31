import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entity/product.dart';
import '../repository/ProductRepository.dart';

class ViewProductUseCase extends Usecase<Product, Params>{

  final ProductRepository repository;
  ViewProductUseCase(this.repository);

  @override
  Future<Either<Failure, Product>> call(Params params) async{
    return await repository.getProductById(params.id);
  }
  
}

class Params extends Equatable{
  final String  id;
  const Params(this.id);

  @override
  List<Object?> get props =>[];

}