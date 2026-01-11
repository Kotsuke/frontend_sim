import 'package:flutter/material.dart';
import '../core/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  void _register() async {
    bool success = await AuthService.register(
      username: usernameCtrl.text,
      email: emailCtrl.text,
      password: passwordCtrl.text,
      fullName: nameCtrl.text,
    );

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Register gagal')));
    }
  }

  @override
Widget build(BuildContext context) {
  const primaryColor = Color.fromARGB(255, 0, 47, 255);

  return Scaffold(
    backgroundColor: primaryColor,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ===== HEADER =====
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "DAFTAR AKUN",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== CARD FORM =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  // ===== FULL NAME =====
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: "Nama Lengkap",
                      prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== USERNAME =====
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      hintText: "Username",
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== EMAIL =====
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== PASSWORD =====
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== BUTTON REGISTER =====
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Daftar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== BACK TO LOGIN =====
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Sudah punya akun? Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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