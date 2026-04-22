// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:guardian_angel_flutter/providers/auth_provider.dart'; // Corrected import
// import 'package:guardian_angel_flutter/core/theme.dart'; // Corrected import
// import 'package:guardian_angel_flutter/providers/contact_provider.dart'; // Corrected import
// import 'package:guardian_angel_flutter/providers/ai_detection_provider.dart'; // Corrected import
// import 'package:guardian_angel_flutter/providers/location_provider.dart'; // Corrected import
// import 'package:guardian_angel_flutter/providers/sos_provider.dart'; // Corrected import
// import 'package:guardian_angel_flutter/providers/journey_provider.dart'; // Corrected import
// import 'package:guardian_angel_flutter/providers/settings_provider.dart'; // Corrected import
// import 'package:guardian_angel_flutter/services/socket_service.dart'; // Corrected import

// // Import your screens
// import 'package:guardian_angel_flutter/screens/dashboard/fake_call_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/dashboard/nearby_police_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/dashboard/safety_tips_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/dashboard/women_helpline_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/dashboard/safe_journey_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/dashboard/live_location_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/auth/login_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/auth/signup_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/dashboard/home_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/dashboard/sos_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/settings/contacts_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/settings/profile_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/splash_screen.dart'; // Corrected import
// import 'package:guardian_angel_flutter/screens/settings/settings_screen.dart'; // Corrected import

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
//           create: (_) => SettingsProvider(),
//           update: (_, auth, settings) => settings!..update(auth),
//         ),
//         ChangeNotifierProvider(create: (_) => AuthProvider()..loadUser()),
//         ChangeNotifierProvider(create: (_) => ContactProvider()),
//         ChangeNotifierProvider(create: (_) => SosProvider()),
//         ChangeNotifierProvider(create: (_) => LocationProvider()),
//         ChangeNotifierProvider(create: (_) => AIDetectionProvider()),
//         ChangeNotifierProvider(create: (_) => JourneyProvider()), // New provider
//       ],
//       child: const GuardianAngelApp(),
//     ),
//   );
// }
 
// class GuardianAngelApp extends StatelessWidget {
//   const GuardianAngelApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Guardian Angel Premium',
//       debugShowCheckedModeBanner: false,
//       theme: GuardianTheme.lightTheme, // Default light theme
//       darkTheme: GuardianTheme.darkTheme, // Default dark theme
//       themeMode: Provider.of<SettingsProvider>(context).themeMode, // Use SettingsProvider for theme
//       initialRoute: '/', // Set up named routing
//       routes: {
//         '/': (context) => const AuthWrapper(), // Handles initial routing based on auth state
//         '/login': (context) => const LoginScreen(),
//         '/signup': (context) => const SignupScreen(),
//         '/home': (context) => const HomeScreen(),
//         '/sos': (context) => const SosScreen(), // This will be the dedicated SOS screen
//         '/contacts': (context) => const ContactsScreen(),
//         '/profile': (context) => const ProfileScreen(),
//         '/settings': (context) => const SettingsScreen(), // Add settings route
//         '/fake_call': (context) => const FakeCallScreen(),
//         '/nearby_police': (context) => const NearbyPoliceScreen(),
//         '/safety_tips': (context) => const SafetyTipsScreen(),
//         '/women_helpline': (context) => const WomenHelplineScreen(), // New route
//         '/safe_journey': (context) => const SafeJourneyScreen(), // New route
//         '/live_location': (context) => const LiveLocationScreen(),
//       },
//     );
//   }
// }
 
// /// Listens to AuthProvider and determines the initial screen.
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         // Show Splash Screen while checking login state
//         if (authProvider.isLoading) {
//           return const PremiumSplashScreen();
//         }

//         // If logged in -> Home Dashboard
//         if (authProvider.isAuthenticated) {
//           // Connect to Socket.IO once authenticated with user ID
//           SocketService().connect(userId: authProvider.user?.id); // Fixed SocketService connect
//           return const HomeScreen();
//         }

//         // If not logged in -> Login Screen
//         return const LoginScreen();
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/contact_provider.dart';
import 'providers/ai_detection_provider.dart';
import 'providers/location_provider.dart';
import 'providers/sos_provider.dart';
import 'providers/journey_provider.dart';
import 'providers/settings_provider.dart';

import 'core/theme.dart';
import 'services/socket_service.dart';

// Real paths from your screenshots
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';

import 'screens/dashboard/home_screen.dart';
import 'screens/dashboard/sos_screen.dart';
import 'screens/dashboard/fake_call_screen.dart';
import 'screens/dashboard/nearby_police_screen.dart';
import 'screens/dashboard/safety_tips_screen.dart';
import 'screens/dashboard/women_helpline_screen.dart';
import 'screens/dashboard/safe_journey_screen.dart';
import 'screens/dashboard/live_location_screen.dart';
import 'screens/dashboard/contacts_screen.dart';
import 'screens/dashboard/profile_screen.dart';
import 'screens/dashboard/settings_screen.dart';
import 'utils/app_utils.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => SosProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => AIDetectionProvider()),
        ChangeNotifierProvider(create: (_) => JourneyProvider()),
        ChangeNotifierProxyProvider<AuthProvider, SettingsProvider>(
          create: (_) => SettingsProvider(),
          update: (_, auth, settings) => settings!..update(auth),
        ),
      ],
      child: const GuardianAngelApp(),
    ),
  );
}

class GuardianAngelApp extends StatelessWidget {
  const GuardianAngelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guardian Angel Premium',
      navigatorKey: AppUtils.navigatorKey,
      scaffoldMessengerKey: AppUtils.scaffoldMessengerKey,
      theme: GuardianTheme.lightTheme,
      darkTheme: GuardianTheme.darkTheme,
      themeMode: settings.themeMode,

      home: const AuthWrapper(),

      routes: {
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignupScreen(),
        '/home': (_) => HomeScreen(),
        '/sos': (_) => SosScreen(),
        '/contacts': (_) => ContactsScreen(),
        '/profile': (_) => ProfileScreen(),
        '/settings': (_) => SettingsScreen(),
        '/fake_call': (_) => FakeCallScreen(),
        '/nearby_police': (_) => NearbyPoliceScreen(),
        '/safety_tips': (_) => SafetyTipsScreen(),
        '/women_helpline': (_) => WomenHelplineScreen(),
        '/safe_journey': (_) => SafeJourneyScreen(),
        '/live_location': (_) => LiveLocationScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.isLoading) {
          return const PremiumSplashScreen();
        }

        if (auth.isAuthenticated) {
          try {
            SocketService().connect(
              userId: auth.user?.id,
              accountType: auth.user?.accountType,
              userName: auth.user?.fullName,
            );
          } catch (_) {}
          return HomeScreen();
        }

        return LoginScreen();
      },
    );
  }
}
