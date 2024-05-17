import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sfc/screens/food%20vendor/route/screens/crud/product_edit.dart';

class ProductManagementScreen extends StatefulWidget {
  final String businessId;
  final String businessName; // Add business name parameter

  ProductManagementScreen(
      {required this.businessId, required this.businessName});

  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedCategory = 'Meat';
  File? _imageFile;
  bool _isSaving = false;

  Map<String, String> categoryImages = {
    'Meat': 'assets/categories/meat.png',
    'Snacks': 'assets/categories/snacks.png',
    'Drinks': 'assets/categories/soda.png',
    'Grains': 'assets/categories/grains.png',
    'Real Food': 'assets/categories/meal.png',
    'Fruits': 'assets/categories/meal.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Management',
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
                    : Image.file(_imageFile!),
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _productNameController,
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
                labelText: 'Product Name',
                hintText: 'Enter Business Product Name',
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _priceController,
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
                labelText: 'price',
                hintText: 'Enter product price',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _descriptionController,
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
                labelText: 'Product Description',
                hintText: 'Enter Product Description',
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _quantityController,
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
                labelText: 'Product Quantity',
                hintText: 'Enter Business Product Quantity',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              value: _selectedCategory,
              borderRadius: BorderRadius.circular(5),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: categoryImages.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          categoryImages[value]!,
                          height: 24,
                          width: 24,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Center(child: Text(value)),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20.0),
            _isSaving
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveProduct,
                    child: Text(
                      'Save Product',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
            SizedBox(height: 20.0),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('businessId', isEqualTo: widget.businessId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('No products registered for this business.'));
                }
                return ListView(
                  shrinkWrap: true,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: ListTile(
                        title: Text(data['productName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: Ugx ${data['price'].toString()}'),
                            Text('Description: ${data['description']}'),
                            Text('Quantity: ${data['quantity'].toString()}'),
                            Text('Category: ${data['category']}'),
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(data['imageUrl']),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProductScreen(
                                        productId: document.id),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteProduct(document.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    setState(() {
      _isSaving = true;
    });

    if (_validateFields()) {
      try {
        String imageUrl = '';
        if (_imageFile != null) {
          imageUrl = await _uploadImage();
        }

        await FirebaseFirestore.instance.collection('products').add({
          'businessId': widget.businessId,
          'productName': _productNameController.text.trim(),
          'price': int.parse(_priceController.text.trim()),
          'description': _descriptionController.text.trim(),
          'quantity': int.parse(_quantityController.text.trim()),
          'category': _selectedCategory,
          'imageUrl': imageUrl,
        });

        _clearFields();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save product: $e')),
        );
        print('Error saving product: $e');
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    } else {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<String> _uploadImage() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('product_images');
      final fileName = '${DateTime.now()}.png';
      final uploadTask = storageRef.child(fileName).putFile(_imageFile!);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _clearFields() {
    _productNameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    setState(() {
      _imageFile = null;
      _selectedCategory = 'Meat';
    });
  }

  bool _validateFields() {
    if (_productNameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return false;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return false;
    }
    return true;
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $e')),
      );
      print('Error deleting product: $e');
    }
  }
}
