import 'package:dartz/dartz.dart';
import 'package:ecommerce_ui/core/error/failure.dart';
import 'package:ecommerce_ui/core/usecases/usecase.dart';
import 'package:ecommerce_ui/core/util/input_converter.dart';
import 'package:ecommerce_ui/features/product/domain/entity/product.dart';
import 'package:ecommerce_ui/features/product/domain/usecase/create_product_usecase.dart';
import 'package:ecommerce_ui/features/product/domain/usecase/delete_product_usecase.dart';
import 'package:ecommerce_ui/features/product/domain/usecase/update_product_usecase.dart';
import 'package:ecommerce_ui/features/product/domain/usecase/viewAll_products_usecase.dart';
import 'package:ecommerce_ui/features/product/domain/usecase/view_product_usecase.dart';
import 'package:ecommerce_ui/features/product/domain/usecase/view_product_usecase.dart' as view_product;
import 'package:ecommerce_ui/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_bloc_test.mocks.dart';

@GenerateMocks([
  CreateProductUsecase,
  DeleteProductUsecase,
  UpdateProductUsecase,
  ViewAllProductsUseCase,
  ViewProductUseCase,
  InputConverter,
])


void main() {
  late ProductBloc bloc;
  late MockCreateProductUsecase mockCreateProduct;
  late MockDeleteProductUsecase mockDeleteProduct;
  late MockUpdateProductUsecase mockUpdateProduct;
  late MockViewAllProductsUseCase mockViewAllProducts;
  late MockViewProductUseCase mockViewProduct;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockCreateProduct = MockCreateProductUsecase();
    mockDeleteProduct = MockDeleteProductUsecase();
    mockUpdateProduct = MockUpdateProductUsecase();
    mockViewAllProducts = MockViewAllProductsUseCase();
    mockViewProduct = MockViewProductUseCase();
    mockInputConverter = MockInputConverter();

    bloc = ProductBloc(
      createProduct: mockCreateProduct,
      deleteProduct: mockDeleteProduct,
      inputConverter: mockInputConverter,
      updateProduct: mockUpdateProduct,
      viewAllProducts: mockViewAllProducts,
      viewProduct: mockViewProduct,
    );
  });

  test('initial state should be InitialState', () {
    expect(bloc.state, equals(InitialState()));
  });

  group('CreateProductEvent', () {
    const tId = '123';
    const tName = 'Test Product';
    const tDescription = 'Test Description';
    const tImageUrl = 'test.jpg';
    const tPriceString = '123.45';
    const tPriceDouble = 123.45;

    final tProduct = const Product(
      id: '123', 
      name: tName,
      description: tDescription,
      imageUrl: tImageUrl,
      price: tPriceDouble,
    );

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedDouble(any))
            .thenReturn(const Right(tPriceDouble));
            
    test(
      'should emit [Loading, LoadedAllProductState] when product is created successfully',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockCreateProduct(any)).thenAnswer((_) async => Right(tProduct));
        when(mockViewAllProducts(any)).thenAnswer((_) async => Right([tProduct]));
        // assert later
        final expected = [
          LoadingState(),
          LoadedAllProductState([tProduct]),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(CreateProductEvent(tProduct));
    });

    test(
      'should emit [Loading, Error] when creating a product fails',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockCreateProduct(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          LoadingState(),
          const ErrorState(SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(CreateProductEvent(tProduct));
    });
  });

  group('GetSingleProductEvent', () {
    const tId = '123';
    const tName = 'Test Product';
    const tDescription = 'Test Description';
    const tImageUrl = 'test.jpg';
    const tPriceDouble = 123.45;

    final tProduct = const Product(
      id: tId,
      name: tName,
      description: tDescription,
      imageUrl: tImageUrl,
      price: tPriceDouble,
    );

    test(
      'should get data from the view product use case',
      () async {
        // arrange
        when(mockViewProduct(any)).thenAnswer((_) async => Right(tProduct));
        // act
        bloc.add(const GetSingleProductEvent(tId));
        await untilCalled(mockViewProduct(any));
        // assert
        verify(mockViewProduct(const view_product.Params(tId)));
      },
    );

    test(
      'should emit [Loading, LoadedSingleProductState] when data is gotten successfully',
      () async {
        // arrange
        when(mockViewProduct(any)).thenAnswer((_) async => Right(tProduct));
        // assert later
        final expected = [
          LoadingState(),
          LoadedSingleProductState(tProduct),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetSingleProductEvent(tId));
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        when(mockViewProduct(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          LoadingState(),
          const ErrorState(SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetSingleProductEvent(tId));
      },
    );
  });

  group('LoadAllProductEvent', () {
    final tProductList = [
      const Product(id: '1', name: 'Product 1', description: 'P1 desc', imageUrl: 'url1', price: 10),
      const Product(id: '2', name: 'Product 2', description: 'P2 desc', imageUrl: 'url2', price: 20),
    ];

    test(
      'should get all products from the view all products use case',
      () async {
        // arrange
        when(mockViewAllProducts(any)).thenAnswer((_) async => Right(tProductList));
        // act
        bloc.add(const LoadAllProductEvent());
        await untilCalled(mockViewAllProducts(any));
        // assert
        verify(mockViewAllProducts(NoParams()));
      },
    );

    test(
      'should emit [Loading, LoadedAllProductState] when data is gotten successfully',
      () async {
        // arrange
        when(mockViewAllProducts(any)).thenAnswer((_) async => Right(tProductList));
        // assert later
        final expected = [
          LoadingState(),
          LoadedAllProductState(tProductList),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const LoadAllProductEvent());
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async {
        // arrange
        when(mockViewAllProducts(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          LoadingState(),
          const ErrorState(SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const LoadAllProductEvent());
      },
    );
  });

  group('UpdateProductEvent', () {
    const tId = '123';
    const tName = 'Test Product';
    const tDescription = 'Test Description';
    const tImageUrl = 'test.jpg';
    const tPriceDouble = 123.45;

    final tProduct = const Product(
      id: tId,
      name: tName,
      description: tDescription,
      imageUrl: tImageUrl,
      price: tPriceDouble,
    );

    test(
      'should emit [Loading, LoadedAllProductState] when product is updated successfully',
      () async {
        // arrange
        when(mockUpdateProduct(any)).thenAnswer((_) async => Right(tProduct));
        when(mockViewAllProducts(any)).thenAnswer((_) async => Right([tProduct]));
        // assert later
        final expected = [
          LoadingState(),
          LoadedAllProductState([tProduct]),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(UpdateProductEvent(tProduct));
      },
    );

    test(
      'should emit [Loading, Error] when updating a product fails',
      () async {
        // arrange
        when(mockUpdateProduct(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          LoadingState(),
          const ErrorState(SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(UpdateProductEvent(tProduct));
      },
    );
  });

  group('DeleteProductEvent', () {
    const tId = '123';
    final tProductList = [
      const Product(id: '1', name: 'Product 1', description: 'P1 desc', imageUrl: 'url1', price: 10),
    ];

    test(
      'should emit [Loading, LoadedAllProductState] when product is deleted successfully',
      () async {
        // arrange
        when(mockDeleteProduct(any)).thenAnswer((_) async => const Right(null));
        when(mockViewAllProducts(any)).thenAnswer((_) async => Right(tProductList));
        // assert later
        final expected = [
          LoadingState(),
          LoadedAllProductState(tProductList),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const DeleteProductEvent(tId));
      },
    );

    test(
      'should emit [Loading, Error] when deleting a product fails',
      () async {
        // arrange
        when(mockDeleteProduct(any)).thenAnswer((_) async => Left(ServerFailure()));
        // assert later
        final expected = [
          LoadingState(),
          const ErrorState(SERVER_FAILURE_MESSAGE),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const DeleteProductEvent(tId));
      },
    );
  });
}
