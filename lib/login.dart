import 'package:flutter/material.dart';
import 'api.dart';
import 'main.dart';
import 'register.dart';
import 'forgot_password.dart';
import 'product_list.dart';

// Widget đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Widget trạng thái của màn hình đăng nhập
class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  @override
  // Giải phóng bộ nhớ khi widget bị hủy
  void dispose() {
    _usernameController.dispose();
    _passController.dispose();
    super.dispose();
  }
  // Xử lý đăng nhập
  Future<void> _handleLogin() async {
    if (_usernameController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ tài khoản và mật khẩu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await ApiService.login(
        username: _usernameController.text,
        password: _passController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xin chào ${user['firstName']} ${user['lastName']}!'),
          backgroundColor: const Color.fromARGB(255, 34, 0, 255),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProductListScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      // Hiển thị thông báo lỗi nếu đăng nhập thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  // Xây dựng giao diện người dùng của màn hình đăng nhập
  Widget build(BuildContext context) {
    bool isEn = localeNotifier.value == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? 'Login' : 'Đăng nhập'),
        actions: [
          TextButton.icon(
            onPressed: () {
              _usernameController.text = 'emilys';
              _passController.text = 'emilyspass';
            },
            icon: const Icon(Icons.bolt, size: 18),
            label: const Text('Demo User'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: isEn ? 'Username' : 'Tên đăng nhập',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: isEn ? 'Password' : 'Mật khẩu',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                  );
                },
                child: Text(isEn ? 'Forgot Password?' : 'Quên mật khẩu?'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEn ? 'Login' : 'Đăng nhập', style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(isEn ? "Don't have an account?" : 'Chưa có tài khoản?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: Text(isEn ? 'Register now' : 'Đăng ký ngay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}