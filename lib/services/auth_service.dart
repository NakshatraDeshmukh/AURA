import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<bool> login(String email, String password) async {
    final response = await _apiService.postRequest('login', {
      'email': email,
      'password': password,
    });

    if (response != null && response['token'] != null) {
      await _storageService.saveString('auth_token', response['token']);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await _storageService.removeKey('auth_token');
  }

  Future<String?> getToken() async {
    return await _storageService.getString('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
