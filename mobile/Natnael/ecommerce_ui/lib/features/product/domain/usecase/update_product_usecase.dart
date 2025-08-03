import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entity/product.dart';
import '../repository/ProductRepository.dart';

class UpdateProductUsecase extends Usecase<Product,Params>{
  final ProductRepository repository;
  UpdateProductUsecase(this.repository);

  @override
  Future<Either<Failure, Product>> call(Params params) async{
    return await repository.updateProduct(params.product);
  }

}

class Params extends Equatable{
  final Product product;
  const Params(this.product);

  @override
  List<Object?> get props => [product];
  
}