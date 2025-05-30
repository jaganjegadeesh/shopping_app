import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/auth/login.dart';
import 'package:shopping_app/db/db.dart';
import 'package:shopping_app/model/cart_model.dart';
import 'package:shopping_app/constant/const.dart';
import 'package:shopping_app/pages/order_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _login = false;

  @override
  void initState() {
    super.initState();
    initialFun();
  }

  void initialFun() {
    fetchData();
  }

  void fetchData() async {
    bool loginState = await Db.checkLogin();
    setState(() {
      _login = loginState;
    });
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
          var cartItemLength = value.cartItem.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "My Cart",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              value.cartItem.isEmpty
                  ? const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "!Oops there is no cart Items",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: value.cartItem.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                leading: SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: CachedNetworkImage(
                                    imageUrl: value.cartItem[index]
                                                ['product_id'] !=
                                            ''
                                        ? '${Constants.url}uploads/${value.cartItem[index]['product_id']}.jpg'
                                        : 'https://via.placeholder.com/70',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  '${value.cartItem[index]['name'] ?? 'Unnamed'} x ${value.cartItem[index]['quantity'] ?? 1}',
                                ),
                                subtitle: Text(
                                  '₹${value.cartItem[index]['rate'] ?? '0'}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.cancel),
                                  onPressed: () {
                                    Provider.of<CartModel>(context,
                                            listen: false)
                                        .removeItemFromCart(index);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(36.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Price",
                            style: TextStyle(color: Colors.green[100]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹${value.calculateTotal()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (cartItemLength > 0)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    !_login ? const Login() : const OrderPage()),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green.shade100),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Text(
                                  !_login ? "Login" : "Order Now",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
