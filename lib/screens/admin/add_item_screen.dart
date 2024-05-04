import 'dart:io';

import 'package:al_alif/firebase_db_reference/firebase_db_reference.dart';
import 'package:al_alif/screens/admin/view_image.dart';
import 'package:al_alif/utils/string_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({Key? key}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  List<XFile> selectedImage = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: selectProductFunction,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                        child: const Text("Select Product"),
                      ),
                      ElevatedButton(
                        onPressed: addProductFunction,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                        child: const Text("Add Product"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  selectedImage.isEmpty
                      ? const Center(child: Text("Please select the images"))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: selectedImage.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black, width: 2)),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(File(selectedImage[index].path), width: 50, height: 50, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 5),
                                    Text("${index + 1}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                                    const Spacer(),
                                    IconButton(onPressed: () => viewImage(index), icon: const Icon(Icons.remove_red_eye_outlined)),
                                    IconButton(onPressed: () => deleteImage(index), icon: const Icon(Icons.delete_outline)),
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

  selectProductFunction() async {
    FocusManager.instance.primaryFocus!.unfocus();
    final ImagePicker imagePicker = ImagePicker();

    if (selectedImage.isEmpty) {
      selectedImage = await imagePicker.pickMultiImage(imageQuality: 50);
    } else {
      List<XFile> tempImageList = await imagePicker.pickMultiImage(imageQuality: 50);
      selectedImage.addAll(tempImageList);
    }

    setState(() {});
  }

  addProductFunction() async {
    if (selectedImage.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      String key = DateFormat('yyyMMddHHmmssSSS').format(DateTime.now());
      String date = DateFormat('dd-MM-yyyy').format(DateTime.now());
      String time = DateFormat('HH:mm:ss').format(DateTime.now());
      Map<String, String> imageMap = {};

      for (int i = 0; i < selectedImage.length; i++) {
        imageMap['image$i'] = await StringUtils.convertImageToBase64(selectedImage[i]);
      }

      DatabaseReference databaseReference = FirebaseDbReference.getReference();
      await databaseReference.child("gallery").child(key).set({
        "date": date,
        "time": time,
        "key": key,
        "images": imageMap,
      });
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  deleteImage(int index) {
    setState(() {
      selectedImage.removeAt(index);
    });
  }

  viewImage(int index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewImage(imageFileList: selectedImage, index: index)));
  }
}
