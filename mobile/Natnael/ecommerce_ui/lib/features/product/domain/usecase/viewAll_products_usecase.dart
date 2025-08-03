import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entity/product.dart';
import '../repository/ProductRepository.dart';

class ViewAllProductsUseCase extends Usecase<List<Product>, NoParams>{

  final ProductRepository repository;
  ViewAllProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async{
    return await repository.getProducts();
  }
  
}
