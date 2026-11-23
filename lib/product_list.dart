import 'package:flutter/material.dart';
import 'api.dart';
import 'cart.dart';
import 'product_card.dart';
import 'product_detail.dart';
import 'profile.dart';
import 'settings.dart';

// Màn hình danh sách sản phẩm
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

// Xây dựng giao diện màn hình danh sách sản phẩm
class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  int _currentNavIndex = 0;
  final _searchController = TextEditingController();

  @override
  // Khởi tạo trạng thái và tải danh sách sản phẩm khi màn hình được tạo
  void initState() {
    super.initState();
    _loadProducts();
  }

// Tải danh sách sản phẩm từ API
  Future<void> _loadProducts([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      final data = query.trim().isEmpty
          ? await ApiService.fetchProducts()
          : await ApiService.searchProducts(query.trim());
      setState(() {
        _products = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải sản phẩm: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  // Xây dựng giao diện màn hình danh sách sản phẩm
  Widget build(BuildContext context) {
    final userAvatar = ApiService.currentUser?['image'];

    return Scaffold(
      appBar: AppBar(
        // Chỉnh sửa tiêu đề của AppBar sang "ShopEasy" và bấm thì refesh lại danh sách sản phẩm 
        title: GestureDetector(
          onTap: () => _loadProducts(),
          child: const Text('ShopEasy'),
          
        ),
        // Chinh sửa màu của AppBar sang màu cam đỏ
        backgroundColor: const Color.fromARGB(255, 255, 87, 34),
        actions: [
          IconButton(
            tooltip: 'Hồ sơ cá nhân',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: userAvatar != null
                ? CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(userAvatar),
                  )
                : const Icon(Icons.account_circle, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Thân màn hình hiển thị danh sách sản phẩm
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => _loadProducts(value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm (VD: phone, laptop)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadProducts();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Hiển thị danh sách sản phẩm hoặc thông báo khi không có sản phẩm
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                    ? const Center(child: Text('Không tìm thấy sản phẩm nào'))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ProductCardItem(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    productId: product.id,
                                  ),
                                ),
                              );
                            },
                            onAddToCart: () {
                              ApiService.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Đã thêm "${product.title}" vào giỏ!'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      // Thanh điều hướng dưới cùng với các nút Trang chủ, Giỏ hàng và Cài đặt
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentNavIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ).then((_) => setState(() => _currentNavIndex = 0));
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) => setState(() => _currentNavIndex = 0));
          }
        },
        destinations: const [
          // Nút điều hướng Trang chủ
          NavigationDestination(icon: Icon(Icons.home), label: 'Trang chủ'),
          // Nút điều hướng Giỏ hàng
          NavigationDestination(
              icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          // Nút điều hướng Cài đặt
          NavigationDestination(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}