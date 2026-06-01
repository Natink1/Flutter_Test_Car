import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._authService);

  final AuthService _authService;

  AppUser? user;
  bool isLoading = true;

  bool get isAuthenticated => user != null;

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    try {
      user = await _authService.me();
    } catch (_) {
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final session = await _authService.login(email: email, password: password);
    user = session.user;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final session = await _authService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    user = session.user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    notifyListeners();
  }
}
