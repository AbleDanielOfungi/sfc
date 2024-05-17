import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

//registering vendor business
class BusinessRegistrationScreen extends StatefulWidget {
  @override
  _BusinessRegistrationScreenState createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState
    extends State<BusinessRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _foodCategoryController = TextEditingController();
  XFile? _imageFile;
  bool _isRegistering = false;

  Future<void> _registerBusiness() async {
    setState(() {
      _isRegistering = true;
    });
    if (_validateFields()) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('User not logged in');
        }
        final userId = currentUser.uid;

        final QuerySnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('businesses')
                .where('name', isEqualTo: _nameController.text.trim())
                .get();

        if (snapshot.docs.isNotEmpty) {
          _showSnackBar('Business name already exists', false);
        } else {
          final imageUrl = await _uploadImage();
          await FirebaseFirestore.instance.collection('businesses').add({
            'userId': userId,
            'name': _nameController.text.trim(),
            'location': _locationController.text.trim(),
            'contact': _contactController.text.trim(),
            'foodCategory': _foodCategoryController.text.trim(),
            'imageUrl': imageUrl,
          });
          _showSnackBar('Business registered successfully', true);
          _clearFields(); // Clear input fields after successful registration
        }
      } catch (e) {
        _showSnackBar('Failed to register business', false);
        print('Error registering business: $e');
      } finally {
        setState(() {
          _isRegistering = false;
        });
      }
    } else {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  void _clearFields() {
    _nameController.clear();
    _locationController.clear();
    _contactController.clear();
    _foodCategoryController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  bool _validateFields() {
    if (_nameController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _foodCategoryController.text.isEmpty ||
        _imageFile == null) {
      _showSnackBar('Please fill all fields and select an image', false);
      return false;
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(_contactController.text)) {
      _showSnackBar('Please enter a valid 10-digit contact number', false);
      return false;
    }
    return true;
  }

  Future<String> _uploadImage() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('business_images/${_nameController.text.trim()}');
      final uploadTask = storageRef.putFile(File(_imageFile!.path));
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  Future<void> _getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register Your Business',
          style: TextStyle(color: Colors.green),
        ),
      ),
      body: SingleChildScrollView(
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
                    ? Text('Tap to select image')
                    : Image.file(File(_imageFile!.path)),
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
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
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
                enabledBorder: OutlineInputBorder(
                  gapPadding: 10,
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                labelText: 'Contact Number',
                hintText: 'Enter Business Contact Number',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a contact number';
                } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                  return 'Please enter a valid 10-digit contact number';
                }
                return null;
              },
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _foodCategoryController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
                enabledBorder: OutlineInputBorder(
                  gapPadding: 10,
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                labelText: 'Food category',
                hintText: 'Enter Business Food Category',
              ),
            ),
            SizedBox(height: 20.0),
            _isRegistering
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _registerBusiness,
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
