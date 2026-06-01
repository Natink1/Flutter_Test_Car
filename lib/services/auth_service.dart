import '../models/app_user.dart';
import 'api_client.dart';

class AuthSession {
  final AppUser user;
  final String token;

  AuthSession({required this.user, required this.token});
}

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final token = data['token'] as String;
    await _api.setToken(token);
    return AuthSession(
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
      token: token,
    );
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _api.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'role': 'customer',
      },
    );
    final token = data['token'] as String;
    await _api.setToken(token);
    return AuthSession(
      user: AppUser.fromJson(data['user'] as Map<String, dynamic>),
      token: token,
    );
  }

  Future<AppUser> me() async {
    final data = await _api.get('/auth/me', auth: true);
    return AppUser.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', auth: true);
    } finally {
      await _api.setToken(null);
    }
  }
}
