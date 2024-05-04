import 'dart:convert';

import 'package:al_alif/firebase_db_reference/firebase_db_reference.dart';
import 'package:al_alif/model_class/admin_auth_model.dart';
import 'package:al_alif/screens/user/gallery_screen.dart';
import 'package:al_alif/shared_preference/shared_preference.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:text_field_validator/text_field_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool passwordVisible = false;
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: ListView(
                  children: [
                    TextFormField(
                      controller: usernameController,
                      keyboardType: TextInputType.text,
                      validator: (val) {
                        return TextFieldValidator.textValidator(value: val);
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: "Username",
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (val) {
                            return TextFieldValidator.passWordValidator(password: val);
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                              child: Icon(passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            ),
                            labelText: "Password",
                            focusedBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
                            enabledBorder:
                                OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red, width: 2)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Login"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      DatabaseReference databaseReference = FirebaseDbReference.getReference();
      DatabaseEvent event = await databaseReference.once();

      var jsonData = jsonDecode(jsonEncode(event.snapshot.value));
      AdminAuthModel authModel = AdminAuthModel.fromJson(jsonData);

      if (authModel.admin!.auth!.username == usernameController.text && authModel.admin!.auth!.password == passwordController.text) {
        await LocalData.setUserName(usernameController.text);
        await LocalData.setPassword(passwordController.text);

        if (context.mounted) {
          Navigator.of(context)
              .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const GalleryScreen(isAdmin: true, productId: "")), (route) => false);
        }
      } else {
        var snackBar = const SnackBar(content: Text("Invalid Username or Password"));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
      setState(() {
        isLoading = false;
      });
    }
  }
}
