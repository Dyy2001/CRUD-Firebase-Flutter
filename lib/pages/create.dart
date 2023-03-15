import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:d_input/d_input.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final descriptionController = TextEditingController();

  CollectionReference _reference =
      FirebaseFirestore.instance.collection('cars');

  String imageUrl = '';

  File? _imageFile;

// ...

  pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    print('${file?.path}');

    if (file == null) return;

    // setelah memilih gambar
    setState(() {
      imageUrl = file.path;
    });
  }

// ...

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

  saveData() async {
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

          await _reference.add({
            'nama': namaController.text,
            'description': descriptionController.text,
            'image': imageUrl,
            'userId': user.uid,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data berhasil ditambahkan')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Anda harus login terlebih dahulu')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan data: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Create Page'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DInput(
              controller: namaController,
              title: 'Merek',
              validator: (input) => input == '' ? "Tidak Boleh Kosong" : null,
            ),
            DView.spaceHeight(),
            DInput(
              controller: descriptionController,
              maxLine: 5,
              minLine: 1,
              title: 'Description',
              validator: (input) => input == '' ? "Tidak Boleh Kosong" : null,
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
            imageUrl.isEmpty
                ? const Text('empty photo')
                : Image.file(
                    File(imageUrl),
                    width: 280,
                    fit: BoxFit.fitHeight,
                  ),
            DView.spaceHeight(),
            ElevatedButton(
              onPressed: () => saveData(),
              child: Text("Simpan"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
