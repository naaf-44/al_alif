import 'dart:async';
import 'dart:convert';

import 'package:al_alif/firebase_db_reference/firebase_db_reference.dart';
import 'package:al_alif/model_class/image_model.dart';
import 'package:al_alif/screens/admin/add_item_screen.dart';
import 'package:al_alif/screens/admin/view_image.dart';
import 'package:al_alif/utils/string_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminGalleryScreen extends StatefulWidget {
  const AdminGalleryScreen({Key? key}) : super(key: key);

  @override
  State<AdminGalleryScreen> createState() => _AdminGalleryScreenState();
}

class _AdminGalleryScreenState extends State<AdminGalleryScreen> {
  final searchController = TextEditingController();
  bool isLoading = false;
  Timer? _debounce;

  List<ImageModel> imageModelList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(onTap: addItems, child: Container(margin: const EdgeInsets.only(right: 10), child: const Icon(Icons.add_circle_outline, color: Colors.white)))
        ],
        backgroundColor: Colors.deepPurple,
        title: const Text("Product List"),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: FutureBuilder(
                future: getGallery(),
                builder: (context, snapShot) {
                  if (snapShot.hasError) {
                    return const Center(child: Text("No Data Found"));
                  } else {
                    if (snapShot.data == null) {
                      return Container();
                    }
                    List<ImageModel> imageModelList = snapShot.data as List<ImageModel>;
                    return ListView.builder(
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
                              Padding(padding: const EdgeInsets.only(left: 10), child: Text("ID: ${imageModelList[index].key}")),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
    );
  }

  Future<List<ImageModel>> getGallery() async {
    List<ImageModel> imageModelList = [];

    DatabaseReference databaseReference = FirebaseDbReference.getReference();
    await databaseReference.child("gallery").once().then((value) {
      for (DataSnapshot snap in value.snapshot.children) {
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
    });

    return imageModelList;
  }

  addItems() async {
    if (await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddItemScreen())) ?? false) {
      setState(() {});
    }
  }

  viewProduct(ImageModel imageModel) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewImage(imageStringList: imageModel.images, index: 0, productId: imageModel.key)));
  }
}
