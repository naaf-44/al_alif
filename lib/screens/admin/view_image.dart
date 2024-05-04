import 'dart:io';

import 'package:al_alif/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ViewImage extends StatefulWidget {
  final List<XFile>? imageFileList;
  final List<String>? imageStringList;
  final String? productId;
  final int? index;

  const ViewImage({Key? key, this.imageFileList, this.index, this.imageStringList, this.productId}) : super(key: key);

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (widget.productId != null) Align(alignment: Alignment.center, child: Text("Product ID: ${widget.productId}")),
            if (widget.productId != null) const SizedBox(height: 10),
            widget.imageFileList != null
                ? Image.file(File(widget.imageFileList![currentIndex].path), fit: BoxFit.cover)
                : Image.memory(StringUtils.convertBase64ToImage(widget.imageStringList![currentIndex]), fit: BoxFit.cover),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (currentIndex > 0) {
                      setState(() {
                        currentIndex--;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  child: const Icon(Icons.arrow_circle_left_outlined),
                ),
                widget.imageFileList != null
                    ? Text("${currentIndex + 1}/${widget.imageFileList!.length}")
                    : Text("${currentIndex + 1}/${widget.imageStringList!.length}"),
                ElevatedButton(
                  onPressed: () {
                    if (widget.imageFileList != null) {
                      if (currentIndex < widget.imageFileList!.length - 1) {
                        setState(() {
                          currentIndex++;
                        });
                      }
                    } else {
                      if (currentIndex < widget.imageStringList!.length - 1) {
                        setState(() {
                          currentIndex++;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  child: const Icon(Icons.arrow_circle_right_outlined),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
