import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';
import 'features/product/data/datasources/product_local_data_source.dart';
import 'features/product/data/datasources/product_remote_data_source.dart';
import 'features/product/data/repository/product_repository_impl.dart';
import 'features/product/domain/repository/ProductRepository.dart';
import 'features/product/domain/usecase/create_product_usecase.dart';
import 'features/product/domain/usecase/delete_product_usecase.dart';
import 'features/product/domain/usecase/update_product_usecase.dart';
import 'features/product/domain/usecase/viewAll_products_usecase.dart';
import 'features/product/domain/usecase/view_product_usecase.dart';
import 'features/product/presentation/bloc/product_bloc.dart';

final sl = GetIt.instance;
Future<void> init() async {
  //! Features - Product
  //bloc
  sl.registerFactory(
    () => ProductBloc(
      createProduct: sl(),
      deleteProduct: sl(),
      inputConverter: sl(),
      updateProduct: sl(),
      viewAllProducts: sl(),
      viewProduct: sl(),
    ),
  );

  // use cases
  sl.registerLazySingleton(() => CreateProductUsecase(sl()));
  sl.registerLazySingleton(() => UpdateProductUsecase(sl()));
  sl.registerLazySingleton(() => DeleteProductUsecase(sl()));
  sl.registerLazySingleton(() => ViewAllProductsUseCase(sl()));
  sl.registerLazySingleton(() => ViewProductUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );


  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl( sl()),
  );

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
   final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );                      
}
