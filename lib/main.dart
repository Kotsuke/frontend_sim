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
      await [Permission.location, Permission.camera, Permission.photos].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Upload',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
