import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/home/home_dashboard.dart';
import 'core/theme.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeDashboard(),
        ),
        GoRoute(
          path: '/sos',
          builder: (context, state) => SOSScreen(),
        ),
        GoRoute(
          path: '/network',
          builder: (context, state) => SafetyNetworkScreen(), // to create
        ),
        GoRoute(
          path: '/services',
          builder: (context, state) => NearbyServicesScreen(), // to create
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => SettingsScreen(), // to create
        ),
      ],
    ),
  ],
);

class ScaffoldWithBottomNav extends StatefulWidget {
  final Widget child;

  const ScaffoldWithBottomNav({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ScaffoldWithBottomNav> createState() => _ScaffoldWithBottomNavState();
}

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          final routes = ['/home', '/sos', '/network', '/services', '/settings'];
          context.go(routes[index]);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sos), label: 'SOS'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Network'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: SOSButton(onPressed: () => context.go('/sos')),
    );
  }
}

