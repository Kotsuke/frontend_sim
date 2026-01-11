import 'package:flutter_test/flutter_test.dart';

class AuthService {
  bool login(String email, String password) {
    if (email.isEmpty || password.isEmpty) return false;
    if (password.length < 6) return false;
    return true;
  }
}

void main() {
  group('Auth Service Test', () {
    test('Login berhasil jika email & password valid', () {
      final auth = AuthService();
      expect(auth.login('test@mail.com', '123456'), true);
    });

    test('Login gagal jika password kurang dari 6', () {
      final auth = AuthService();
      expect(auth.login('test@mail.com', '123'), false);
    });

    test('Login gagal jika email kosong', () {
      final auth = AuthService();
      expect(auth.login('', '123456'), false);
    });
  });
}
