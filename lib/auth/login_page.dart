import 'package:flutter/material.dart';
import '../core/auth_service.dart';
import '../main.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;
  bool googleLoading = false;

  // ================= LOGIN BIASA =================
  void _login() async {
    setState(() => loading = true);

    bool success = await AuthService.login(
      usernameCtrl.text,
      passwordCtrl.text,
    );

    setState(() => loading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login gagal - Username atau password salah'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= GOOGLE SIGN-IN =================
  void _loginWithGoogle() async {
    setState(() => googleLoading = true);

    final result = await AuthService.signInWithGoogle();

    setState(() => googleLoading = false);

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Login Google gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  const primaryColor = Color.fromARGB(255, 0, 47, 255);

  return Scaffold(
    backgroundColor: primaryColor,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ===== HEADER =====
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'SMART\nINFRASTRUKTUR\nMONITORING',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== IMAGE =====
            Image.asset(
              'assets/infrastruktur.png',
              height: 150,
            ),

            const SizedBox(height: 16),

            // ===== CARD LOGIN =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== USERNAME =====
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== PASSWORD =====
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== BUTTON LOGIN =====
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== GOOGLE LOGIN =====
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: googleLoading ? null : _loginWithGoogle,
                      icon: Image.asset(
                        'assets/google.png',
                        height: 20,
                      ),
                      label: const Text(
                        'Login dengan Google',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== REGISTER =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun?'),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
                        child: const Text(
                          'Daftar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}