
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';

abstract class AuthenticationLocalDataSource {

  /// saves the token given by the api and cached it locally
  Future<void> cacheToken(String tokenToCache);

  /// gets the cached token
  Future<String> getCachedToken();  

  /// Deletes the cached token
  Future<void> clearToken();
}

const CACHED_TOKEN = 'CACHED_TOKEN';

class AuthenticationLocalDataSourceImpl implements AuthenticationLocalDataSource{
  final SharedPreferences sharedPreferences;

  AuthenticationLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheToken(String tokenToCache) {
    return sharedPreferences.setString(CACHED_TOKEN, tokenToCache);
  }

  @override
  Future<String> getCachedToken() {
    final token = sharedPreferences.getString(CACHED_TOKEN);

    if(token != null){
      return Future.value(token);
    }else{
      throw CacheException();
    }
  }
  
  @override
  Future<void> clearToken(){
    return sharedPreferences.remove(CACHED_TOKEN);
  }

}

