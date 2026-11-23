import 'package:dio/dio.dart';
import 'product_card.dart';

// Lớp CartItem đại diện cho một sản phẩm trong giỏ hàng
class CartItem {
  final Product product;
  int quantity;
  bool isSelected;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
  });
}

// Lớp ApiService quản lý các API và trạng thái liên quan đến người dùng và giỏ hàng
class ApiService {
  static String? accessToken;
  static dynamic currentUser;

  static List<CartItem> cartItems = [];

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://dummyjson.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void addToCart(Product product) {
    final index =
        cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      cartItems[index].quantity += 1;
    } else {
      cartItems.add(CartItem(product: product, quantity: 1, isSelected: true));
    }
  }

  // 1. API Đăng nhập (POST /auth/login)
  static Future<dynamic> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'username': username.trim(),
          'password': password.trim(),
        },
      );
      accessToken = response.data['accessToken'];
      currentUser = response.data;
      return response.data;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ?? 'Sai tài khoản hoặc mật khẩu';
      throw Exception(message);
    }
  }

  // 2. Lấy danh sách sản phẩm -> List<Product>
  static Future<List<Product>> fetchProducts({int limit = 20}) async {
    final response = await dio.get(
      '/products',
      queryParameters: {'limit': limit},
    );
    final List danhSachJson = response.data['products'];
    return danhSachJson.map((json) => Product.fromJson(json)).toList();
  }

  // 3. Tìm kiếm sản phẩm -> List<Product>
  static Future<List<Product>> searchProducts(String query) async {
    final response = await dio.get(
      '/products/search',
      queryParameters: {'q': query},
    );
    final List danhSachJson = response.data['products'];
    return danhSachJson.map((json) => Product.fromJson(json)).toList();
  }

  // 4. Chi tiết 1 sản phẩm -> Product
  static Future<Product> fetchProductDetail(int id) async {
    final response = await dio.get('/products/$id');
    return Product.fromJson(response.data);
  }

  // 5. Lấy thông tin Profile từ Token (GET /auth/me)
  static Future<dynamic> fetchProfile() async {
    if (accessToken == null) {
      throw Exception('Chưa đăng nhập');
    }
    final response = await dio.get(
      '/auth/me',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    return response.data;
  }
}