import 'package:flutter/material.dart';
import 'api.dart';
import 'login.dart';
// Quản lý trạng thái Chế độ Sáng / Tối
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
// Quản lý trạng thái Chế độ Sáng / Tối
class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  // Hàm tải thông tin hồ sơ người dùng từ API
  Future<void> _loadProfile() async {
    try {
      // Gọi GET /auth/me kèm Bearer Token
      final data = await ApiService.fetchProfile();
      setState(() {
        _userProfile = data;
        _isLoading = false;
      });
    } catch (e) {
      // Dự phòng nếu token hết hạn thì lấy từ dữ liệu đã lưu lúc login
      setState(() {
        _userProfile = ApiService.currentUser;
        _isLoading = false;
      });
    }
  }
  // Hàm đăng xuất, xóa token và thông tin người dùng, chuyển về màn hình đăng nhập
  void _logout() {
    ApiService.accessToken = null;
    ApiService.currentUser = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
  // Widget hiển thị thông tin hồ sơ người dùng
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(child: Text('Không có thông tin người dùng'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Ảnh đại diện
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            NetworkImage(_userProfile!['image'] ?? ''),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_userProfile!['firstName']} ${_userProfile!['lastName']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${_userProfile!['username']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),

                      // Thẻ thông tin chi tiết lấy từ DummyJSON
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: const Text('Email'),
                              subtitle: Text(_userProfile!['email'] ?? ''),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: const Text('Số điện thoại'),
                              subtitle: Text(_userProfile!['phone'] ?? 'Chưa cập nhật'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('Giới tính / Tuổi'),
                              subtitle: Text(
                                  '${_userProfile!['gender'] ?? ''} • ${_userProfile!['age'] ?? ''} tuổi'),
                            ),
                            if (_userProfile!['address'] != null) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.location_on_outlined),
                                title: const Text('Địa chỉ'),
                                subtitle: Text(
                                    '${_userProfile!['address']['address']}, ${_userProfile!['address']['city']}'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nút Đăng xuất
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Đăng xuất',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}