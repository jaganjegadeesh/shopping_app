import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/auth/login.dart';
import 'package:shopping_app/auth/profile.dart';
import 'package:shopping_app/components/product_item_tile.dart';
import 'package:shopping_app/constant/const.dart';
import 'package:shopping_app/db/db.dart';
import 'package:shopping_app/model/cart_model.dart';
import 'package:shopping_app/pages/cart_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  String? name;
  File? _profile;
  bool _login = false;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  void logout() async {
    await Db.clearDb();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Color parseColor(dynamic colorValue) {
    if (colorValue is String) {
      if (colorValue.startsWith('#')) {
        return Color(int.parse(colorValue.replaceFirst('#', '0x')));
      } else {
        switch (colorValue.toLowerCase()) {
          case 'red':
            return Colors.red;
          case 'green':
            return Colors.green;
          case 'blue':
            return Colors.blue;
          case 'black':
            return Colors.black;
          case 'white':
            return Colors.white;
          case 'yellow':
            return Colors.yellow;
          case 'orange':
            return Colors.orange;
          case 'pink':
            return Colors.pink;
          case 'purple':
            return Colors.purple;
          case 'grey':
          case 'gray':
            return Colors.grey;
          default:
            return Colors.grey;
        }
      }
    } else {
      return Colors.grey;
    }
  }

  Future<void> fetchItems() async {
    Map<String, String>? user = await Db.getData();
    bool loginState = await Db.checkLogin();
    if (user != null) {
      setState(() {
        _login = loginState;
        name = user['name'] ?? 'No name';
        if (user['imageUrl'] != null) {
          final tempImage = File(user['imageUrl']!);
          _profile = tempImage;
        }
      });
    }
    List<Map<String, dynamic>> productList = [];
    final url = Uri.parse("${Constants.url}shop_product.php?getAllProduct=");
    // ignore: use_build_context_synchronously
    Provider.of<CartModel>(context, listen: false).loadCartFromStorage();
    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success' && jsonData['data'] is List) {
          setState(() {
            productList = List<Map<String, dynamic>>.from(jsonData['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
    // ignore: use_build_context_synchronously
    Provider.of<CartModel>(context, listen: false).setShopItems(productList);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => TextButton(
              onLongPress: () {
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;
                final RenderBox box = context.findRenderObject() as RenderBox;
                final Offset position = box.localToGlobal(Offset.zero);

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    position.dx,
                    position.dy + box.size.height,
                    overlay.size.width - position.dx,
                    0,
                  ),
                  items: [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(
                            Icons.power_settings_new,
                            color: Colors.black,
                          ),
                          SizedBox(width: 10),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                ).then((value) {
                  if (value == 'logout') {
                    logout();
                  }
                });
              },
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          _login ? const Profile() : const Login()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              child: _profile != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: FileImage(_profile!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CartPage())),
        backgroundColor: Colors.black,
        child: const Icon(Icons.shopping_bag, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text("Let's Order"),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(),
            ),
            Expanded(child: Consumer<CartModel>(
              builder: (context, value, child) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.3,
                  ),
                  itemCount: value.shopItems.length,
                  itemBuilder: (context, index) {
                    final item = value.shopItems[index];
                    return ProductItemTile(
                      itemName: item['name'],
                      itemPrice: item['rate'],
                      imagePath: item['product_id'],
                      color: parseColor(item['color']),
                      onPressed: () {
                        Provider.of<CartModel>(context, listen: false)
                            .addItemToCart(index);
                      },
                    );
                  },
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}
