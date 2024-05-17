import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditBusinessScreen extends StatefulWidget {
  final String businessId;

  const EditBusinessScreen({Key? key, required this.businessId})
      : super(key: key);

  @override
  _EditBusinessScreenState createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _foodCategoryController = TextEditingController();
  File? _imageFile;
  bool _saving = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    // Fetch business details from the database
    FirebaseFirestore.instance
        .collection('businesses')
        .doc(widget.businessId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Populate the text fields with the business details
        setState(() {
          _nameController.text = documentSnapshot['name'];
          _locationController.text = documentSnapshot['location'];
          _contactController.text = documentSnapshot['contact'];
          _foodCategoryController.text = documentSnapshot['foodCategory'];
          _imageUrl = documentSnapshot['imageUrl'];
        });
      } else {
        print('Document does not exist on the database');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Business',
          style: TextStyle(
            color: Colors.green,
          ),
        ),
      ),
      body: _saving
          ? Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: _getImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                      ),
                      padding: EdgeInsets.all(10),
                      child: _imageFile == null
                          ? _imageUrl != null
                              ? Image.network(_imageUrl!)
                              : Text('Tap to select image')
                          : Image.file(_imageFile!),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 42, vertical: 20),
                      enabledBorder: OutlineInputBorder(
                        gapPadding: 10,
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      labelText: 'Business Name',
                      hintText: 'Enter Business Name',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 42, vertical: 20),
                      enabledBorder: OutlineInputBorder(
                        gapPadding: 10,
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      labelText: 'Location',
                      hintText: 'Enter Business Location',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 42, vertical: 20),
                      enabledBorder: OutlineInputBorder(
                        gapPadding: 10,
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      labelText: 'contact',
                      hintText: 'Enter Business contact',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: _foodCategoryController,
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 42, vertical: 20),
                      enabledBorder: OutlineInputBorder(
                        gapPadding: 10,
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      labelText: 'Food Category',
                      hintText: 'Enter Business Food Category',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _saveBusiness,
                    child: const Text(
                      'Update Business',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveBusiness() async {
    if (_saving) return;
    setState(() {
      _saving = true;
    });

    try {
      if (_validateFields()) {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImage();
        }

        await FirebaseFirestore.instance
            .collection('businesses')
            .doc(widget.businessId)
            .update({
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'contact': _contactController.text.trim(),
          'foodCategory': _foodCategoryController.text.trim(),
          if (imageUrl != null) 'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Business details updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update business details'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error saving business details: $e');
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  Future<String> _uploadImage() async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('business_images');
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  bool _validateFields() {
    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _foodCategoryController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return false;
    }
    return true;
  }
}
