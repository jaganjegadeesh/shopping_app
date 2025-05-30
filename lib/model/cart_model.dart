import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartModel extends ChangeNotifier {
  // ignore: prefer_final_fields, non_constant_identifier_names
  List _cart_items = [];
  List get cartItem => _cart_items;

  List<Map<String, dynamic>> _shopItems = [];

  List<Map<String, dynamic>> get shopItems => _shopItems;

  void setShopItems(List<Map<String, dynamic>> items) {
    _shopItems = items;
    notifyListeners();
  }

  Future<void> loadCartFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString('cart_items');

    if (cartData != '') {
      _cart_items = List<Map<String, dynamic>>.from(jsonDecode(cartData!));
      notifyListeners();
    }
  }

  Future<void> saveCartToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart_items', jsonEncode(_cart_items));
  }

  void addItemToCart(int index) {
    final product = shopItems[index];
    final productId = product['product_id'];

    // Check if item already in cart
    final existingIndex =
        _cart_items.indexWhere((item) => item['product_id'] == productId);

    if (existingIndex != -1) {
      // If exists, increase quantity
      _cart_items[existingIndex]['quantity'] += 1;
    } else {
      // If not, add item with quantity = 1
      final newItem = Map<String, dynamic>.from(product);
      newItem['quantity'] = 1;
      _cart_items.add(newItem);
    }

    saveCartToStorage();
    notifyListeners();
  }

  void removeItemFromCart(int index) {
    _cart_items.removeAt(index);
    saveCartToStorage(); // persist
    notifyListeners();
  }

  void removeAllItemFromCart() {
    _cart_items.clear();
    saveCartToStorage(); // persist
    notifyListeners();
  }

  double calculateTotal() {
    double total = 0.0;
    for (var item in cartItem) {
      final rate = double.tryParse(item['rate'].toString()) ?? 0.0;
      final qty = item['quantity'] ?? 1;
      total += rate * qty;
    }
    return total;
  }
}
