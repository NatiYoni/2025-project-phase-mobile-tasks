/// this page is repository page

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entity/authentication.dart';
import '../../domain/repository/authentication_repository.dart';
import '../datasource/authentication_local_data_source.dart';
import '../datasource/authentication_remote_data_source.dart';
import '../model/authentication_model.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final NetworkInfo networkInfo;
  final AuthenticationRemoteDataSource remoteDataSource;
  final AuthenticationLocalDataSource localDataSource;

  AuthenticationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  AuthenticationModel _authenticationModel(Authentication authentication) =>
      AuthenticationModel(
        name: authentication.name,
        email: authentication.email,
        password: authentication.password
      );


  Future<Either<Failure, T>> _getResponse<T>(
      Future<T> Function() remoteCall,
      [Future<T> Function()? localCall]) async {
    if (await networkInfo.isConnected) {
      try {
        return Right(await remoteCall());
      } on ServerException  {
        return Left(ServerFailure());
      }
    } else {
      if (localCall != null) {
        try {
          return Right(await localCall());
        } on CacheException {
          return Left(CacheFailure());
        }
      } 

      return Left(NetworkFailure());
    
    }
  }


  @override
  Future<Either<Failure, String>> login(Authentication auth)async {
    if (await networkInfo.isConnected) {
      try {
        final model = _authenticationModel(auth);
        final remoteAuth = await remoteDataSource.login(model);
        await localDataSource.cacheToken(remoteAuth);
        return Right(remoteAuth);
      } on ServerException {
        return Left(ServerFailure());
      } on CacheException {
        return Left(CacheFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async{
    try {
      await localDataSource.clearToken();
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Authentication>> signUp(
    Authentication authentication,
  ) async{
    final  model = _authenticationModel(authentication);
    return await _getResponse<Authentication>(()async{
      final remoteAuth = await remoteDataSource.signUp(model);
      return remoteAuth;
    });
  }

  @override
  Future<Either<Failure, List<Authentication>>> getAllUsers(String token) async {
    return await _getResponse<List<Authentication>>(() async {
      final models = await remoteDataSource.getAllUsers(token);
      return models; // models already extend Authentication
    });
  }

  @override
  Future<Either<Failure, Authentication>> getCurrentUser(String token) async {
    return await _getResponse<Authentication>(() async {
      final model = await remoteDataSource.getCurrentUser(token);
      return model; // extends entity
    });
  }
  
}
