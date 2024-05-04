import 'dart:convert';

import 'package:al_alif/firebase_db_reference/firebase_db_reference.dart';
import 'package:al_alif/model_class/admin_auth_model.dart';
import 'package:al_alif/screens/admin/login_screen.dart';
import 'package:al_alif/screens/user/gallery_screen.dart';
import 'package:al_alif/shared_preference/shared_preference.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:universal_html/html.dart" as uHtml;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCmguPGqSa4y0Cx5NeeCq2RL-ARH0UGBsM",
        appId: "1:639659895565:web:bb94bae9d963d8f8911e44",
        messagingSenderId: "639659895565",
        projectId: "al-alif",
        databaseURL: "https://al-alif-default-rtdb.firebaseio.com",
        storageBucket: "al-alif.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    checkUserType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/logo.png", height: 100, width: 100),
          const Text("Al Alif Furniture"),
          const SizedBox(height: 40),
          const CircularProgressIndicator(),
        ],
      ),
    ));
  }

  checkUserType() async {
    await Future.delayed(const Duration(seconds: 2));
    if (kIsWeb) {
      var uri = Uri.dataFromString(uHtml.window.location.href);
      Map<String, String> params = uri.queryParameters;
      var productId = params['productId'] ?? "";

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => GalleryScreen(productId: productId.toString())), (route) => false);
      }
    } else {
      DatabaseReference databaseReference = FirebaseDbReference.getReference();
      DatabaseEvent event = await databaseReference.once();

      var jsonData = jsonDecode(jsonEncode(event.snapshot.value));
      AdminAuthModel authModel = AdminAuthModel.fromJson(jsonData);

      if (await LocalData.getUserName() == authModel.admin!.auth!.username.toString() &&
          await LocalData.getPassword() == authModel.admin!.auth!.password.toString()) {
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const GalleryScreen(isAdmin: true)), (route) => false);
        }
      } else {
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        }
      }
    }
  }
}
