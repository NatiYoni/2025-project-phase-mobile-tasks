import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entity/product.dart';
import '../repository/ProductRepository.dart';

class ViewAllProductsUseCase extends Usecase<List<Product>, Params>{

  final ProductRepository repository;
  ViewAllProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(Params params) async{
    return await repository.getProduct();
  }
  
}

class Params extends Equatable{
  final Product product;
  
  const Params(this.product);

  @override
  List<Object?> get props =>[];

}