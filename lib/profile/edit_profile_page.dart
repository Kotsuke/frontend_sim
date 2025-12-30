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
  bool loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.currentName);
    phoneCtrl = TextEditingController(text: widget.currentPhone);
    bioCtrl = TextEditingController(text: widget.currentBio);
  }

  Future<void> _saveProfile() async {
    setState(() => loading = true);

    bool success = await UserService.updateProfile(widget.userId, {
      'full_name': nameCtrl.text,
      'phone': phoneCtrl.text,
      'bio': bioCtrl.text,
    });

    setState(() => loading = false);

    if (success) {
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profil')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioCtrl,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _saveProfile,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
