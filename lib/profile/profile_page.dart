import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/user_service.dart';
import '../core/auth_service.dart';
import '../auth/login_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? userId;
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // Coba ambil dari SharedPreferences dulu jika ada
    final username = prefs.getString('username');
    final fullName = prefs.getString('full_name');

    if (username != null && fullName != null) {
      setState(() {
        profile = {
          'username': username,
          'full_name': fullName,
          'email': prefs.getString('email') ?? '-',
          'role': prefs.getString('role') ?? '-',
          'phone': prefs.getString('phone') ?? '-',
          'bio': prefs.getString('bio') ?? '',
        };
        loading = false;
      });
    }

    userId = prefs.getInt('user_id');

    // Jika userId tidak ada, berarti login tidak sempurna / sesi habis
    if (userId == null) {
      setState(() => loading = false);
      return;
    }

    // Always Refresh data from API
    try {
      final data = await UserService.getProfile(userId!);
      setState(() {
        profile = data;
        loading = false;
      });

      // Update data terbaru ke SharedPreferences
      if (data['email'] != null) prefs.setString('email', data['email']);
      if (data['phone'] != null) prefs.setString('phone', data['phone']);
      if (data['bio'] != null) prefs.setString('bio', data['bio']);
      if (data['full_name'] != null)
        prefs.setString('full_name', data['full_name']);
    } catch (e) {
      print('Gagal refresh profil dari API: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil terbaru: $e')),
        );
      }
      setState(() => loading = false);
    }
  }

  void _logout() async {
    await AuthService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Profile',
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
        shadowColor:
            Colors.blue.shade200, // Added elevation for a more modern look
      ),
      body: profile == null
          ? const Center(child: Text('Gagal memuat profil'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  /// ================= HEADER =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile!['full_name'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${profile!['username']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ================= CONTENT =================
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        /// BIO CARD
                        if ((profile!['bio'] ?? '').isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              profile!['bio'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                        /// EDIT PROFILE
                        if (userId != null)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfilePage(
                                      userId: userId!,
                                      currentName: profile!['full_name'],
                                      currentPhone: profile!['phone'] == '-'
                                          ? ''
                                          : (profile!['phone'] ?? ''),
                                      currentBio: profile!['bio'] ?? '',
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  _loadProfile();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 28),

                        /// INFO CARD
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _infoTile('Email', profile!['email']),
                                const Divider(),
                                _infoTile('Phone', profile!['phone'] ?? '-'),
                                const Divider(),
                                _infoTile('Role', profile!['role']),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        /// LOGOUT (DANGER ZONE)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}