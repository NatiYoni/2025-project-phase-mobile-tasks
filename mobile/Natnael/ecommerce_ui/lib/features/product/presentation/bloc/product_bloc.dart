import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entity/product.dart';
import '../../domain/usecase/create_product_usecase.dart' as create;
import '../../domain/usecase/delete_product_usecase.dart' as delete;
import '../../domain/usecase/update_product_usecase.dart' as update;
import '../../domain/usecase/viewAll_products_usecase.dart';
import '../../domain/usecase/view_product_usecase.dart' as view;

part 'product_event.dart';
part 'product_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE = 'Invalid Input - The number must be a positive integer';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final create.CreateProductUsecase createProduct; 
  final delete.DeleteProductUsecase deleteProduct;
  final update.UpdateProductUsecase updateProduct;
  final ViewAllProductsUseCase viewAllProducts;
  final view.ViewProductUseCase viewProduct;
  final InputConverter inputConverter;

  ProductBloc({
    required this.createProduct,
    required this.deleteProduct,
    required this.inputConverter,
    required this.updateProduct,
    required this.viewAllProducts,
    required this.viewProduct,
  }) : super(InitialState()) {

    on<LoadAllProductEvent>(_onLoadAllProducts);
    on<GetSingleProductEvent>(_onGetSingleProduct);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure _:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }

  
  Future<void> _onLoadAllProducts(
    LoadAllProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(LoadingState());
    final failureOrProducts = await viewAllProducts(NoParams());

    failureOrProducts.fold(
      (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
      (products) => emit(LoadedAllProductState(products)),
    );
  }

  Future<void> _onGetSingleProduct(
    GetSingleProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(LoadingState());
    final failureOrProduct = await viewProduct(view.Params(event.id));
    failureOrProduct.fold(
      (failure) => emit(ErrorState( _mapFailureToMessage(failure))),
      (product) => emit(LoadedSingleProductState(product)),
    );
  }
  
    Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(LoadingState());
    final failureOrSuccess = await createProduct(create.Params(event.product));

    if (failureOrSuccess.isLeft()) {
      failureOrSuccess.fold(
          (failure) => emit(ErrorState(_mapFailureToMessage(failure))), (_) {});
    } else {
      final failureOrProducts = await viewAllProducts(NoParams());
      failureOrProducts.fold(
        (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
        (products) => emit(LoadedAllProductState(products)),
      );
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(LoadingState());
    final failureOrSuccess = await updateProduct(update.Params(event.product));

    if (failureOrSuccess.isLeft()) {
      failureOrSuccess.fold(
          (failure) => emit(ErrorState(_mapFailureToMessage(failure))), (_) {});
    } else {
      final failureOrProducts = await viewAllProducts(NoParams());
      failureOrProducts.fold(
        (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
        (products) => emit(LoadedAllProductState(products)),
      );
    }
  }


  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(LoadingState());
    final failureOrSuccess = await deleteProduct(delete.Params(event.id));

    if (failureOrSuccess.isLeft()) {
      failureOrSuccess.fold(
          (failure) => emit(ErrorState(_mapFailureToMessage(failure))), (_) {});
    } else {
      final failureOrProducts = await viewAllProducts(NoParams());
      failureOrProducts.fold(
        (failure) => emit(ErrorState(_mapFailureToMessage(failure))),
        (products) => emit(LoadedAllProductState(products)),
      );
    }
  }
}
