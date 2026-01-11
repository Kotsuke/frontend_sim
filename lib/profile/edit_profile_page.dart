import 'package:flutter/material.dart';
import '../core/user_service.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;
  final String currentName;
  final String currentPhone;
  final String currentBio;

  const EditProfilePage({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentPhone,
    required this.currentBio,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController bioCtrl;
  late TextEditingController passwordCtrl;
  bool loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.currentName);
    phoneCtrl = TextEditingController(text: widget.currentPhone);
    bioCtrl = TextEditingController(text: widget.currentBio);
    passwordCtrl = TextEditingController();
  }

  Future<void> _saveProfile() async {
    setState(() => loading = true);

    final data = {
      'full_name': nameCtrl.text,
      'phone': phoneCtrl.text,
      'bio': bioCtrl.text,
    };

    if (passwordCtrl.text.isNotEmpty) {
      data['password'] = passwordCtrl.text;
    }

    bool success = await UserService.updateProfile(widget.userId, data);

    setState(() => loading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui profil')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.blue.shade200,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= PROFILE INFO =================
            const Text(
              'Informasi Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// FULL NAME
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// PHONE
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// BIO
                    TextField(
                      controller: bioCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell us about yourself...',
                        prefixIcon: const Icon(Icons.edit),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// ================= SECURITY =================
            const Text(
              'Keamanan Akun',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'New Password (Optional)',
                    hintText: 'Leave empty to keep current',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            /// ================= SAVE BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}