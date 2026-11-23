import 'package:flutter/material.dart';
import 'main.dart';
import 'profile.dart';
import 'product_card.dart';
import 'login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationOn = true;
  bool _isAutoLoginOn = true;

  void _openLanguageBottomSheet() {
    bool isEn = localeNotifier.value == 'en';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEn ? 'Select Language' : 'Chọn ngôn ngữ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                title: const Text('Tiếng Việt'),
                trailing: !isEn ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  localeNotifier.value = 'vi';
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English'),
                trailing: isEn ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  localeNotifier.value = 'en';
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openLogoutDialog() {
    bool isEn = localeNotifier.value == 'en';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEn ? 'Logout' : 'Đăng xuất'),
          content: Text(
            isEn
                ? 'Are you sure you want to log out?'
                : 'Bạn có chắc chắn muốn đăng xuất không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isEn ? 'Cancel' : 'Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                isEn ? 'Logout' : 'Đăng xuất',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = themeNotifier.value == ThemeMode.dark;
    bool isEn = localeNotifier.value == 'en';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEn ? 'Settings' : 'Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            isEn ? 'ACCOUNT' : 'TÀI KHOẢN',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: Text(isEn ? 'Notifications' : 'Nhận thông báo'),
            value: _isNotificationOn,
            onChanged: (bool value) => setState(() => _isNotificationOn = value),
          ),
          const Divider(),

          SwitchListTile(
            title: Text(isEn ? 'Dark Mode' : 'Chế độ tối'),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: isDarkMode,
            onChanged: (bool value) {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
              setState(() {});
            },
          ),
          const Divider(),

          SwitchListTile(
            title: Text(isEn ? 'Remember Login' : 'Nhớ đăng nhập'),
            value: _isAutoLoginOn,
            onChanged: (bool value) => setState(() => _isAutoLoginOn = value),
          ),

          const SizedBox(height: 24),

          Text(
            isEn ? 'APPLICATION' : 'ỨNG DỤNG',
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            title: Text(isEn ? 'Profile Card' : 'Thẻ hồ sơ cá nhân'),
            subtitle: Text(isEn ? 'View Profile Card UI' : 'Xem giao diện Profile Card'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined, color: Colors.orange),
            title: Text(isEn ? 'Product Card' : 'Thẻ sản phẩm'),
            subtitle: Text(isEn ? 'View Product Card UI' : 'Xem giao diện Product Card'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductCardScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            title: Text(isEn ? 'Language' : 'Ngôn ngữ'),
            subtitle: Text(isEn ? 'English' : 'Tiếng Việt'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openLanguageBottomSheet,
          ),
          const Divider(),

          ListTile(
            title: Text(isEn ? 'Font Size' : 'Cỡ chữ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),

          ListTile(
            title: Text(isEn ? 'About App' : 'Về ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 32),

          OutlinedButton(
            onPressed: _openLogoutDialog,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(isEn ? 'Logout' : 'Đăng xuất'),
          ),
        ],
      ),
    );
  }
}