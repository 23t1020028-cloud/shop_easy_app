import 'package:flutter/material.dart';
import 'login.dart';

// Quản lý trạng thái Chế độ Sáng / Tối
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Quản lý trạng thái Ngôn ngữ ('vi' - Tiếng Việt, 'en' - English)
final ValueNotifier<String> localeNotifier = ValueNotifier('vi');

void main() {
  runApp(const MyApp());
}
// Widget gốc của ứng dụng
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  // Xây dựng giao diện người dùng dựa trên trạng thái hiện tại của ThemeMode và Ngôn ngữ
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return ValueListenableBuilder<String>(
          valueListenable: localeNotifier,
          builder: (context, currentLang, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: currentMode,
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                colorSchemeSeed: Colors.blue,
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                colorSchemeSeed: Colors.blue,
              ),
              home: const LoginScreen(),
            );
          },
        );
      },
    );
  }
}