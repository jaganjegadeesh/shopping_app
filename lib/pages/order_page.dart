import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/constant/const.dart';
import 'package:shopping_app/db/db.dart';
import 'package:shopping_app/model/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/pages/home_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  Map<String, String>? userData;
  UserModel? user;
  bool _isLoading = false;
  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    userData = await Db.getData();
    var doc = await firebase.collection('users').doc(userData?['id']).get();

    if (doc.exists) {
      user = UserModel.fromJson(doc.data()!);
      setState(() {
        _nameController.text = user?.name ?? '';
        _phoneController.text = user?.phone ?? '';
      });
    }
  }

  Future<void> placeOrder() async {
    setState(() {
      _isLoading = true;
    });

    final cartItems = Provider.of<CartModel>(context, listen: false).cartItem;

    final productIds = cartItems
        .map((item) => item['product_id'].toString())
        .where((id) => id.isNotEmpty)
        .toList();
    final products = jsonEncode(productIds);

    final quantities = cartItems
        .map((item) => item['quantity'].toString())
        .where((id) => id.isNotEmpty)
        .toList();
    final quantity = jsonEncode(quantities);

    final order = {
      "edit": false,
      "name": _nameController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
      "products": products,
      "quantity": quantity,
    };

    var url = Uri.parse('http://192.168.1.221/project/api/shop_order.php');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(order),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ignore: use_build_context_synchronously
      Provider.of<CartModel>(context, listen: false).removeAllItemFromCart();
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed'),
          content: Text(
              'Thank you ${_nameController.text}!\nYour order has been placed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // ignore: avoid_print
      print('Failed to place order: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<CartModel>(
        builder: (context, value, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Cart",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: ListView.builder(
                    itemCount: value.cartItem.length,
                    itemBuilder: (context, index) {
                      final item = value.cartItem[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: SizedBox(
                              width: 70,
                              height: 70,
                              child: CachedNetworkImage(
                                imageUrl: item['product_id'] != null
                                    ? '${Constants.url}uploads/${item['product_id']}.jpg'
                                    : 'https://via.placeholder.com/70',
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                                '${item['name'] ?? 'Unnamed'} x ${item['quantity'] ?? 1}'),
                            subtitle: Text('₹${item['rate'] ?? '0'}'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 40),
                const Text(
                  "Customer Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: "Phone"),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: "Address"),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? Center(
                              child: LoadingAnimationWidget.hexagonDots(
                                color: const Color.fromARGB(255, 252, 75, 75),
                                size: 50,
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await placeOrder();
                                }
                              },
                              child: const Text("Place Order"),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
