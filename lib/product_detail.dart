import 'package:flutter/material.dart';
import 'api.dart';
import 'cart.dart';
import 'product_card.dart';

// Quản lý trạng thái Chế độ Sáng / Tối
class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

// Quản lý trạng thái Ngôn ngữ ('vi' - Tiếng Việt, 'en' - English)
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await ApiService.fetchProductDetail(widget.productId);
      setState(() {
        _product = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final images = _product?.images.isNotEmpty == true
        ? _product!.images
        : (_product != null ? [_product!.thumbnail] : []);

    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.title ?? 'Chi tiết sản phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Không tải được dữ liệu sản phẩm'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh chính
                      Container(
                        height: 260,
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        child: Image.network(
                          images[_selectedImageIndex],
                          fit: BoxFit.contain,
                        ),
                      ),
                      // Danh sách ảnh nhỏ
                      if (images.length > 1)
                        SizedBox(
                          height: 64,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: images.length,
                            itemBuilder: (context, idx) {
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedImageIndex = idx),
                                child: Container(
                                  width: 48,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _selectedImageIndex == idx
                                          ? Colors.deepOrange
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.network(images[idx],
                                      fit: BoxFit.cover),
                                ),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_product!.category.isNotEmpty)
                                  Chip(
                                    label: Text(_product!.category),
                                    backgroundColor:
                                        Colors.deepOrange.withOpacity(0.1),
                                  ),
                                const SizedBox(width: 8),
                                if (_product!.brand != null)
                                  Chip(label: Text(_product!.brand!)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _product!.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '\$${_product!.price}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (_product!.discountPercentage > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '-${_product!.discountPercentage}%',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('${_product!.rating} / 5.0'),
                                const Spacer(),
                                Text(
                                  'Kho còn: ${_product!.stock} sản phẩm',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const Divider(height: 28),
                            const Text(
                              'Mô tả sản phẩm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _product!.description,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: _product == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ApiService.addToCart(_product!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Đã thêm "${_product!.title}" vào giỏ hàng!'),
                          action: SnackBarAction(
                            label: 'Xem giỏ',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CartScreen()),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text(
                      'Thêm vào giỏ hàng',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}