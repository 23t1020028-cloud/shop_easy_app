import 'package:flutter/material.dart';

class Product {
  final int id;
  final String title;
  final String description;
  final String thumbnail;
  final List<String> images;
  final double price;
  final double discountPercentage;
  final double rating;
  final String category;
  final String? brand;
  final int stock;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.images,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    this.category = '',
    this.brand,
    this.stock = 0,
    this.isFavorite = false,
  });

  // Chuyển đổi từ JSON sang đối tượng Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num? ?? 0).toDouble(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      category: json['category'] ?? '',
      brand: json['brand'],
      stock: json['stock'] ?? 0,
    );
  }
}

// Widget Thẻ sản phẩm tái sử dụng trên lưới sản phẩm
class ProductCardItem extends StatefulWidget {
  final Product product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onTap;

  const ProductCardItem({
    super.key,
    required this.product,
    this.onAddToCart,
    this.onTap,
  });

  @override
  State<ProductCardItem> createState() => _ProductCardItemState();
}

// Widget Thẻ sản phẩm tái sử dụng trên lưới sản phẩm
class _ProductCardItemState extends State<ProductCardItem> {
  @override
  // Xây dựng giao diện thẻ sản phẩm
  Widget build(BuildContext context) {
    final p = widget.product;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: widget.onTap,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(p.thumbnail, fit: BoxFit.cover),
                  ),
                  if (p.discountPercentage > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${p.discountPercentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Nút yêu thích (biểu tượng trái tim) để đánh dấu sản phẩm yêu thích
                  Positioned( 
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        p.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: p.isFavorite ? Colors.red : Colors.grey[700],
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => p.isFavorite = !p.isFavorite),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text('${p.rating}',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${p.price}',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: widget.onAddToCart,
                      child: const Text('Thêm vào giỏ',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Màn hình xem thử thẻ sản phẩm độc lập (nếu gọi từ Settings)
class ProductCardScreen extends StatelessWidget {
  const ProductCardScreen({super.key});

  @override
  // Xây dựng giao diện màn hình xem thử thẻ sản phẩm
  Widget build(BuildContext context) {
    final sampleProduct = Product(
      id: 0,
      title: 'Tai nghe Bluetooth Không dây Cao cấp',
      description: 'Âm thanh sống động, chống ồn chủ động.',
      thumbnail:
          'https://bizweb.dktcdn.net/100/263/281/products/sony-wh-xb900n-11.jpg?v=1589033195480',
      images: [],
      price: 120.0,
      discountPercentage: 20,
      rating: 4.8,
      category: 'Đồ điện tử',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Thẻ sản phẩm')),
      body: Center(
        child: SizedBox(
          width: 240,
          height: 340,
          child: ProductCardItem(product: sampleProduct),
        ),
      ),
    );
  }
}