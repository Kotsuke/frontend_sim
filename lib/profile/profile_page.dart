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
      if (data['full_name'] != null) prefs.setString('full_name', data['full_name']);
      
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
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: profile == null
          ? const Center(child: Text('Gagal memuat profil'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    profile!['full_name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${profile!['username']}',
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  Text(profile!['bio'] ?? '', textAlign: TextAlign.center),

                  const SizedBox(height: 16),

                  if (userId != null)
                    OutlinedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(
                              userId: userId!,
                              currentName: profile!['full_name'],
                              currentPhone: profile!['phone'] == '-' ? '' : (profile!['phone'] ?? ''),
                              currentBio: profile!['bio'] ?? '',
                            ),
                          ),
                        );

                        if (result == true) {
                          _loadProfile();
                        }
                      },
                      child: const Text('Edit Profile'),
                    ),

                  const SizedBox(height: 24),

                  _infoTile('Email', profile!['email']),
                  _infoTile('Phone', profile!['phone'] ?? '-'),
                  _infoTile('Role', profile!['role']),
                ],
              ),
            ),
    );
  }

  Widget _infoTile(String label, String value) {
    return ListTile(title: Text(label), subtitle: Text(value));
  }
}
