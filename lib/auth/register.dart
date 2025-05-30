import 'dart:io';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:shopping_app/auth/login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  FirebaseFirestore firebase = FirebaseFirestore.instance;
  final TextEditingController _gender = TextEditingController();
  final TextEditingController _dob = TextEditingController();
  bool _formSubmitted = false;
  File? _selectImage;

  Future<void> registervalidation(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    String? imageUrl;
    if (_selectImage != null) {
      // Get local app directory
      final appDir = await getApplicationDocumentsDirectory();

      // Create 'user_image' folder
      final userImageDir = Directory('${appDir.path}/user_image');
      if (!(await userImageDir.exists())) {
        await userImageDir.create(recursive: true);
      }

      // Copy image into 'user_image' folder
      final fileName = basename(_selectImage!.path);
      final localImagePath = '${userImageDir.path}/$fileName';
      final savedImage = await _selectImage!.copy(localImagePath);

      imageUrl = savedImage.path; // Local file path

      // Optional: Delete the temp file
      if (await _selectImage!.exists()) {
        await _selectImage!.delete();
      }
    }
    try {
      await firebase.collection('users').add({
        "name": _name.text,
        "email": _email.text,
        "phone": _phone.text,
        "dob": _dob.text,
        "gender": _gender.text,
        "password": _password.text,
        "role": "user",
        "userId": randomAlphaNumeric(10),
        if (imageUrl != null) "imageUrl": imageUrl,
      });

      if (!mounted) return;

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Align(
            alignment: Alignment.center,
            child: Text("Register Successful"),
          ),
        ),
      );

      // ignore: use_build_context_synchronously
      Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const Login()));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text("Registration failed: $e")));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final tempImage = File(pickedFile.path);

    setState(() {
      _selectImage = tempImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Account",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.red[200]),
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: TextFormField(
                                  controller: _name,
                                  decoration: const InputDecoration(
                                    labelText: "Name",
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black12,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.blue,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter the Name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                TextButton(
                                  onPressed: _pickImageFromGallery,
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: _selectImage != null
                                        ? FileImage(_selectImage!)
                                        : null,
                                    child: _selectImage == null
                                        ? const Icon(Icons.person, size: 40)
                                        : null,
                                  ),
                                ),
                                if (_selectImage == null && _formSubmitted)
                                  const Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.all(0),
                                      child: Text(
                                        'select Profile.',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            label: Text("E-mail"),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            } else {
                              final regexEmail = RegExp(
                                r"^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$",
                              );

                              if (!regexEmail.hasMatch(value)) {
                                return 'Invalid email';
                              } else {
                                return null;
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _phone,
                          decoration: const InputDecoration(
                            label: Text("Phone"),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter the Phone';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _dob,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              _dob.text = DateFormat(
                                'dd-MM-yyyy',
                              ).format(pickedDate);
                            }
                          },
                          decoration: const InputDecoration(
                            label: Text("Date of birth"),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Select a Date';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<String>(
                            style: SegmentedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: const BorderSide(color: Colors.grey),
                              backgroundColor: Colors.grey[200],
                            ),
                            segments: const <ButtonSegment<String>>[
                              ButtonSegment<String>(
                                value: 'Male',
                                label: Text('Male'),
                                icon: Icon(Icons.man_outlined),
                              ),
                              ButtonSegment<String>(
                                value: 'Female',
                                label: Text('Female'),
                                icon: Icon(Icons.woman_2_rounded),
                              ),
                            ],
                            selected: <String>{_gender.text},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _gender.text = newSelection.first;
                              });
                            },
                          ),
                        ),
                        if (_gender.text.isEmpty && _formSubmitted)
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: Text(
                                'Please select your gender.',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: true,
                          controller: _password,
                          decoration: const InputDecoration(
                            label: Text("Password"),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter the Password';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: true,
                          decoration: const InputDecoration(
                            label: Text("Confirm Password"),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Re-Enter the Password';
                            } else {
                              if (_password.text != value) {
                                return "Password Mismatch";
                              } else {
                                return null;
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        _isLoading
                            ? Center(
                                child: LoadingAnimationWidget.hexagonDots(
                                  color: const Color.fromARGB(255, 252, 75, 75),
                                  size: 50,
                                ),
                              )
                            : ElevatedButton(
                                statesController: WidgetStatesController(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow,
                                  shadowColor: const Color.fromARGB(
                                    255,
                                    224,
                                    224,
                                    167,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _formSubmitted = true;
                                  });
                                  if (_formKey.currentState!.validate() &&
                                      _gender.text.isNotEmpty &&
                                      (_selectImage != null &&
                                          // ignore: unrelated_type_equality_checks
                                          _selectImage != "")) {
                                    registervalidation(context);
                                  }
                                },
                                child: const Text("Confirm"),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an Account ? "),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomAppBar(color: AppColors.primaryColor),
    );
  }
}
