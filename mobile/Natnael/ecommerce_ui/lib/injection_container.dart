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

//! chat related
import 'features/chat/data/datasource/chat_remote_data_source.dart';
import 'features/chat/data/repository/chat_repository_impl.dart';
import 'features/chat/domain/repository/chat_repository.dart';
import 'features/chat/domain/usecase/get_chats_usecase.dart';
import 'features/chat/domain/usecase/get_messages_usecase.dart' as get_messages_uc;
import 'features/chat/domain/usecase/get_message_stream_usecase.dart';
import 'features/chat/domain/usecase/initiate_chat_usecase.dart' as initiate_chat_uc;
import 'features/chat/domain/usecase/delete_chat_usecase.dart' as delete_chat_uc;
import 'features/chat/domain/usecase/send_message_usecase.dart' as send_message_uc;
import 'features/chat/presentation/bloc/chat_bloc.dart';

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

  //! Features - Chat (placed after external so http.Client is registered)
  // Bloc
  sl.registerFactory(() => ChatBloc(
        remoteDataSource: sl(),
        getChatsUsecase: sl(),
        getMessagesUsecase: sl(),
        getMessagesStreamUsecase: sl(),
        initiateChatUsecase: sl(),
        deleteChatUsecase: sl(),
        sendMessageUsecase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetChatsUsecase(sl()));
  sl.registerLazySingleton(() => get_messages_uc.GetMessagesUsecase(sl()));
  sl.registerLazySingleton(() => GetMessagesStreamUsecase(sl()));
  sl.registerLazySingleton(() => initiate_chat_uc.InitiateChatUsecase(sl()));
  sl.registerLazySingleton(() => delete_chat_uc.DeleteChatUsecase(sl()));
  sl.registerLazySingleton(() => send_message_uc.SendMessageUsecase(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(
        networkInfo: sl(),
        remoteDataSource: sl(),
      ));

  // Data source
  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(client: sl()));
}
