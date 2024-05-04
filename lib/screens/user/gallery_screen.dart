import 'dart:async';
import 'dart:convert';

import 'package:al_alif/firebase_db_reference/firebase_db_reference.dart';
import 'package:al_alif/model_class/admin_auth_model.dart';
import 'package:al_alif/model_class/image_model.dart';
import 'package:al_alif/screens/admin/add_item_screen.dart';
import 'package:al_alif/screens/admin/view_image.dart';
import 'package:al_alif/utils/string_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class GalleryScreen extends StatefulWidget {
  final bool isAdmin;
  final String? productId;

  const GalleryScreen({super.key, this.isAdmin = false, this.productId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final searchController = TextEditingController();
  bool isLoading = false;
  Timer? _debounce;

  List<ImageModel> imageModelList = [];

  @override
  void initState() {
    super.initState();

    searchController.text = widget.productId.toString();
    getGallery(key: widget.productId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Product List"),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
        centerTitle: true,
        actions: [
          if (widget.isAdmin)
            InkWell(
                onTap: addItems, child: Container(margin: const EdgeInsets.only(right: 10), child: const Icon(Icons.add_circle_outline, color: Colors.white)))
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Column(
                children: [
                  TextFormField(
                    controller: searchController,
                    keyboardType: TextInputType.number,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info_outline),
                      labelText: "Product ID",
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.deepPurple, width: 2)),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.red, width: 2)),
                    ),
                    onChanged: (val) {
                      searchById();
                    },
                  ),
                  const SizedBox(height: 10),
                  imageModelList.isEmpty
                      ? const Center(child: Text("No data found"))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: imageModelList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                height: MediaQuery.of(context).size.width - 20,
                                child: Stack(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        viewProduct(imageModelList[index]);
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          StringUtils.convertBase64ToImage(imageModelList[index].images![0]),
                                          width: MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context).size.width - 20,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Padding(padding: const EdgeInsets.only(left: 10, top: 5), child: Text("ID: ${imageModelList[index].key}")),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 10),
                                            width: 70,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                shareProduct(imageModelList[index].key!);
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                                              child: const Icon(Icons.share_outlined),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 70,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                copyProduct(imageModelList[index].key!);
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                                              child: const Icon(Icons.copy_outlined),
                                            ),
                                          ),
                                          if (widget.isAdmin)
                                            SizedBox(
                                              width: 70,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  deleteProduct(imageModelList[index].key!);
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                                                child: const Icon(Icons.delete_outline),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                ],
              ),
            ),
    );
  }

  searchById() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      FocusManager.instance.primaryFocus?.unfocus();
      getGallery(key: searchController.text.toString());
    });
  }

  getGallery({String key = ""}) async {
    setState(() {
      isLoading = true;
    });
    imageModelList.clear();

    DatabaseReference databaseReference = FirebaseDbReference.getReference();
    await databaseReference.child("gallery").once().then((value) {
      for (DataSnapshot snap in value.snapshot.children) {
        if (snap.key!.contains(key)) {
          List<String> imageList = [];
          for (DataSnapshot snap2 in snap.children) {
            if (snap2.key == "images") {
              for (DataSnapshot snap3 in snap2.children) {
                imageList.add(snap3.value.toString());
              }
            }
          }
          Map<String, dynamic> jsonData = jsonDecode(jsonEncode(snap.value));
          ImageModel imageModel = ImageModel(date: jsonData['date'], time: jsonData['time'], key: jsonData['key'], images: imageList);
          imageModelList.add(imageModel);
        }
      }
    });

    setState(() {
      isLoading = false;
    });
  }

  addItems() async {
    if (await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddItemScreen())) ?? false) {
      getGallery();
    }
  }

  viewProduct(ImageModel imageModel) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewImage(imageStringList: imageModel.images, index: 0, productId: imageModel.key)));
  }

  shareProduct(String key) async {
    DatabaseReference databaseReference = FirebaseDbReference.getReference();
    DatabaseEvent event = await databaseReference.once();

    var jsonData = jsonDecode(jsonEncode(event.snapshot.value));
    AdminAuthModel authModel = AdminAuthModel.fromJson(jsonData);
    String url = authModel.admin!.shareUrl!.replaceAll("{productId}", key);
    Share.share('Please check this product.\n$url', subject: 'Share Product');
  }

  copyProduct(String key) async {
    await Clipboard.setData(ClipboardData(text: key));
    var snackBar = SnackBar(content: Text("Product ID: ${key.toString()} copied successfully"));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  deleteProduct(String key) async {
    DatabaseReference databaseReference = FirebaseDbReference.getReference();
    await databaseReference.child("gallery").child(key).remove();
    searchController.clear();
    getGallery();
  }
}
