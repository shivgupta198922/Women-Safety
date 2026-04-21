import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'theme.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, String>> pages = [
    {
      'title': 'Your Guardian Angel',
      'description': '24/7 protection with one tap SOS, live tracking & safety network',
      'animation': 'assets/animations/sos.json',
    },
    {
      'title': 'Smart Emergency Tools',
      'description': 'Shake to SOS, fake call escape, secret recording, voice commands',
      'animation': 'assets/animations/shake.json',
    },
    {
      'title': 'Private Safety Network',
      'description': 'Share live location with family, group alerts, safe arrival checkins',
      'animation': 'assets/animations/network.json',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => currentPage = index),
            itemBuilder: (context, index) {
              return FadeInUp(
                delay: Duration(milliseconds: index * 200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lottie animation
                    SizedBox(
                      height: 300,
                      child: Lottie.asset(
                        pages[index]['animation']!,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      pages[index]['title']!,
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        pages[index]['description']!,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: pages.length,
          ),
          // Bottom indicators & buttons
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pages.length, (index) => 
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: currentPage == index 
                          ? GuardianTheme.primaryGradientStart 
                          : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginScreen()),
                      ),
                      icon: Icon(Icons.login),
                      label: Text('Login'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      ),
                      icon: Icon(Icons.person_add),
                      label: Text('Get Started'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

