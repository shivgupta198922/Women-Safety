# Flutter Theme.dart Fix TODO

**Current Task:** Fix theme.dart compile errors for latest Flutter

**Plan Steps:**
1. [ ] Fix theme.dart: Remove const from lightTheme cardTheme, fix BorderRadius, update deprecated withOpacity
2. [ ] Fix glass_card.dart: Update imports, Key?, withOpacity deprecated
3. [ ] Update other files importing theme.dart if needed
4. [ ] Run flutter pub get
5. [ ] Run flutter analyze
6. [ ] Launch flutter run -d chrome
7. [ ] Fix any remaining issues

**Current progress:** Fixed glassWhite reference in GlassCard constructor, all withOpacity deprecated warnings in theme.dart (step 1-2 complete). Theme.dart fully fixed! Ready for pub get & launch.

