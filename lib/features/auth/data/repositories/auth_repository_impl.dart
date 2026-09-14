import 'package:movies/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:movies/features/auth/data/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<void> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }

  @override
  Future<void> signInWithGoogle() {
    return _remoteDataSource.signInWithGoogle();
  }
}
