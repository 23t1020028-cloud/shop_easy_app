import 'package:flutter/material.dart';
import 'api.dart';
import 'main.dart';

// Màn hình giỏ hàng
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}
// Trạng thái của màn hình giỏ hàng
class _CartScreenState extends State<CartScreen> {
  List<CartItem> get _cartItems => ApiService.cartItems;

  double get _subtotal {
    double total = 0;
    for (var item in _cartItems) {
      if (item.isSelected) {
        total += item.product.price * item.quantity;
      }
    }
    return total;
  }

  double get _shippingFee {
    if (_subtotal == 0) return 0;
    return _subtotal >= 100 ? 0 : 10;
  }

  double get _grandTotal => _subtotal + _shippingFee;

  bool get _isAllSelected =>
      _cartItems.isNotEmpty && _cartItems.every((item) => item.isSelected);
  // Chọn hoặc bỏ chọn tất cả sản phẩm trong giỏ hàng
  void _toggleSelectAll(bool? value) {
    setState(() {
      for (var item in _cartItems) {
        item.isSelected = value ?? false;
      }
    });
  }
  // Xử lý thanh toán
  void _checkout(bool isEn) {
    if (_subtotal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEn
                ? 'Please select at least one item!'
                : 'Vui lòng chọn ít nhất 1 sản phẩm để thanh toán!',
          ),
        ),
      );
      return;
    }
    // Hiển thị hộp thoại xác nhận đơn hàng
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEn ? 'Order Confirmed' : 'Đặt hàng thành công'),
        content: Text(
          isEn
              ? 'Total payment: \$${_grandTotal.toStringAsFixed(2)}. Thank you!'
              : 'Tổng thanh toán: \$${_grandTotal.toStringAsFixed(2)}. Cảm ơn bạn đã mua sắm tại ShopEasy!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cartItems.removeWhere((item) => item.isSelected);
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  // Xây dựng giao diện màn hình giỏ hàng
  Widget build(BuildContext context) {
    bool isEn = localeNotifier.value == 'en';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEn
              ? 'Shopping Cart (${_cartItems.length})'
              : 'Giỏ hàng (${_cartItems.length})',
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _cartItems.removeWhere((item) => item.isSelected);
                });
              },
              child: Text(
                isEn ? 'Delete' : 'Xóa đã chọn',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isEn ? 'Your cart is empty' : 'Giỏ hàng của bạn đang trống',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(isEn ? 'Continue Shopping' : 'Tiếp tục mua sắm'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.4),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isAllSelected,
                        onChanged: _toggleSelectAll,
                      ),
                      Text(
                        isEn
                            ? 'Select All (${_cartItems.length} items)'
                            : 'Chọn tất cả (${_cartItems.length} sản phẩm)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      final product = item.product;
                      return Dismissible(
                        key: Key(product.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          setState(() {
                            _cartItems.removeAt(index);
                          });
                        },
                        child: Card(
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: item.isSelected,
                                  onChanged: (val) {
                                    setState(() {
                                      item.isSelected = val ?? false;
                                    });
                                  },
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.thumbnail,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.category,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '\$${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.deepOrange,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (item.quantity > 1) {
                                                        item.quantity -= 1;
                                                      } else {
                                                        _cartItems
                                                            .removeAt(index);
                                                      }
                                                    });
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.remove,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Text(
                                                    '${item.quantity}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      item.quantity += 1;
                                                    });
                                                  },
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'Order Summary' : 'Tổng quan đơn hàng',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEn ? 'Subtotal' : 'Tạm tính',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '\$${_subtotal.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEn ? 'Shipping Fee' : 'Phí vận chuyển',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              _shippingFee == 0
                                  ? (isEn ? 'Free' : 'Miễn phí')
                                  : '\$${_shippingFee.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _shippingFee == 0 ? Colors.green : null,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEn ? 'Total' : 'Tổng thanh toán',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_grandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _checkout(isEn),
                            child: Text(
                              isEn ? 'Proceed to Checkout' : 'Thanh toán ngay',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}