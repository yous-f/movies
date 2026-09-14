abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> updateProfile({String? name});
}