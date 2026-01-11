import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'auth/login_page.dart';
import 'core/auth_service.dart';
import 'profile/profile_page.dart';
import 'home/feed_page.dart';
import 'upload/upload_page.dart';
import 'map/map_page.dart';
import 'chat/chat_page.dart';
import 'core/rating_service.dart';
import 'core/rating_dialog.dart';

import 'core/navigation_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// ===============================
/// ROOT APP
/// ===============================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey, // KUNCI NAVIGASI GLOBAL
      title: 'Smart Infra Social',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          return snapshot.data! ? const MainNavigation() : const LoginPage();
        },
      ),
    );
  }
}

/// ===============================
/// MAIN NAVIGATION (MEDSOS STYLE)
/// ===============================
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FeedPage(),
    MapPage(),
    UploadPage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowRating();
    });
  }

  Future<void> _checkAndShowRating() async {
    if (await RatingService.shouldShowRating()) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => const RatingDialog(),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await [
        Permission.location,
        Permission.camera,
        Permission.photos,
      ].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Feed',
                  index: 0,
                ),
                _navItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Map',
                  index: 1,
                ),
                _navItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  label: 'Upload',
                  index: 2,
                ),
                _navItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Chat',
                  index: 3,
                ),
                _navItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================= NAV ITEM =================
  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.blue : Colors.grey,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
