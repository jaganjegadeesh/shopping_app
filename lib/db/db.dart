import 'package:shared_preferences/shared_preferences.dart';

class Db {
  static Future<SharedPreferences> connect() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> checkLogin() async {
    var cn = await connect();
    bool? r = cn.getBool('login');
    return r ?? false;
  }

  static Future setLogin({required LoginModel model}) async {
    var cn = await connect();
    cn.setString('email', model.email ?? "");
    cn.setString('password', model.password ?? "");
    cn.setString('name', model.name ?? "");
    cn.setString('phone', model.phone ?? "");
    cn.setString('dob', model.dob ?? "");
    cn.setString('gender', model.gender ?? "");
    cn.setString('role', model.role ?? "");
    cn.setString('id', model.id ?? "");
    cn.setString('userId', model.userId ?? "");
    cn.setString('imageUrl', model.imageUrl ?? "");
    cn.setBool('login', true);
  }

  static Future<Map<String, String>?> getData() async {
    var cn = await connect();
    final String? email = cn.getString('email');
    final String? name = cn.getString('name');
    final String? phone = cn.getString('phone');
    final String? dob = cn.getString('dob');
    final String? gender = cn.getString('gender');
    final String? role = cn.getString('role');
    final String? id = cn.getString('id');
    final String? userId = cn.getString('userId');
    final String? imageUrl = cn.getString('imageUrl');

    if (email != null &&
        name != null &&
        phone != null &&
        id != null &&
        userId != null &&
        gender != null &&
        dob != null &&
        role != null) {
      return {
        'email': email,
        'name': name,
        'phone': phone,
        'id': id,
        'userId': userId,
        'gender': gender,
        'role': role,
        'dob': dob,
        'imageUrl': imageUrl ?? "",
      };
    } else {
      return null;
    }
  }

  static Future<bool> clearDb() async {
    var cn = await connect();
    return cn.clear();
  }
}

class LoginModel {
  String? id;
  String? userId;
  String? email;
  String? phone;
  String? dob;
  String? gender;
  String? password;
  String? name;
  String? role;
  String? imageUrl;
  LoginModel({
    this.id,
    this.userId,
    this.email,
    this.password,
    this.phone,
    this.name,
    this.dob,
    this.gender,
    this.role,
    this.imageUrl,
  });
}

class UserModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String role;
  final String imageUrl;
  final String gender;
  final String password;

  UserModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.role,
    required this.imageUrl,
    required this.gender,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      password: json['password'] ?? '',
    );
  }
  @override
  String toString() {
    return 'UserModel(userId: $userId, name: $name, email: $email, phone: $phone,  dob: $dob,  gender: $gender, password: $password, role: $role, imageUrl: $imageUrl)';
  }
}

class ProductModel {
  final String id;
  final String productId;
  final String name;
  final String color;
  final String imageUrl;
  final String rate;

  ProductModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.rate,
    required this.color,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      rate: json['rate'] ?? '',
      color: json['color'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
  @override
  String toString() {
    return 'ProductModel(productId: $productId, name: $name, rate: $rate, color: $color, imageUrl: $imageUrl)';
  }
}
