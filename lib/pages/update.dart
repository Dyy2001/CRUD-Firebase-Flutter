import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:d_input/d_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdatePage extends StatefulWidget {
  final String cars;
  const UpdatePage({Key? key, required this.cars}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final descriptionController = TextEditingController();

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('cars');

  String imageUrl = '';

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    getCarData();
  }

  getCarData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('cars')
        .doc(widget.cars)
        .get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      namaController.text = data['nama'];
      descriptionController.text = data['description'];
      imageUrl = data['image'];
      setState(() {});
    }
  }

  pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    print('${file?.path}');

    if (file == null) return;

    setState(() {
      _imageFile = File(file.path);
    });
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
        height: 200,
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 200,
      );
    } else {
      return Container(
        height: 200,
        color: Colors.grey[300],
      );
    }
  }

  updateData() async {
    if (formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Upload image to Firebase Storage if available
          if (_imageFile != null) {
            String uniqueFileName =
                DateTime.now().millisecondsSinceEpoch.toString();
            Reference referenceRoot = FirebaseStorage.instance.ref();
            Reference referenceDirImages = referenceRoot.child('images');
            Reference referenceImageToUpload =
                referenceDirImages.child(uniqueFileName);
            await referenceImageToUpload.putFile(_imageFile!);
            imageUrl = await referenceImageToUpload.getDownloadURL();
          }

          await _reference.doc(widget.cars).update({
            'nama': namaController.text,
            'description': descriptionController.text,
            'image': imageUrl,
            // 'userId': user.uid,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data berhasil diupdate')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Anda harus login terlebih dahulu')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengupdate data: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Update Page'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _reference.doc(widget.cars).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic>? data =
              snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return Center(child: Text('Data tidak ditemukan'));
          }

          namaController.text = data['nama'] ?? '';
          descriptionController.text = data['description'] ?? '';
          imageUrl = data['image'] ?? '';

          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DInput(
                  controller: namaController,
                  title: 'Merek',
                  validator: (input) =>
                      input == '' ? "Tidak Boleh Kosong" : null,
                ),
                DView.spaceHeight(),
                DInput(
                  controller: descriptionController,
                  maxLine: 5,
                  minLine: 1,
                  title: 'Description',
                  validator: (input) =>
                      input == '' ? "Tidak Boleh Kosong" : null,
                ),
                DView.spaceHeight(),
                ElevatedButton(
                  onPressed: () => pickImage(),
                  child: Text("Pick Image"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
                DView.spaceHeight(),
                _buildImage(),
                DView.spaceHeight(),
                ElevatedButton(
                  onPressed: () => updateData(),
                  child: Text("Update"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
