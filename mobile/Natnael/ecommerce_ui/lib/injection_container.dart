import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

//! core related
import 'core/network/network_info.dart';
import 'core/util/input_converter.dart';

//! authentication related
import 'features/authentication/data/datasource/authentication_local_data_source.dart';
import 'features/authentication/data/datasource/authentication_remote_data_source.dart';
import 'features/authentication/data/repository/authentication_repository_impl.dart';
import 'features/authentication/domain/repository/authentication_repository.dart';
import 'features/authentication/domain/usecase/login_usecase.dart';
import 'features/authentication/domain/usecase/logout_usecase.dart';
import 'features/authentication/domain/usecase/sign_up_usecase.dart';
import 'features/authentication/presentation/bloc/bloc/auth_bloc.dart';

//! Proudct realted
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
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      login: sl(),
      logout: sl(),
      signUp: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => SignUpUsecase(sl()));

  // Repository
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthenticationRemoteDataSource>(
    () => AuthenticationRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthenticationLocalDataSource>(
    () => AuthenticationLocalDataSourceImpl( sl()),
  );

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
