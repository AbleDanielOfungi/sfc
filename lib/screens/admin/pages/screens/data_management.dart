import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class DataManagementScreen extends StatefulWidget {
  @override
  _DataManagementScreenState createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Data Management"),
      // ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/sfc.png',
              height: 100,
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return OrderScreen();
                }));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Center(
                      child: Text('Orders',
                          style: TextStyle(
                            color: Colors.white,
                          ))),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            DataCategoryCard(
              categoryName: 'Businesses',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DataListScreen(
                        collection: 'businesses', itemName: 'Business'),
                  ),
                );
              },
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return UserScreen();
                }));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('Users')),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ProductScreen();
                }));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 70,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('Products')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataCategoryCard extends StatelessWidget {
  final String categoryName;
  final VoidCallback onTap;

  DataCategoryCard({required this.categoryName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              categoryName,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class DataListScreen extends StatefulWidget {
  final String collection;
  final String itemName;

  DataListScreen({required this.collection, required this.itemName});

  @override
  _DataListScreenState createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${widget.itemName}',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(
                    () {}); // Update the UI when the user types something in the search field
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection(widget.collection).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child:
                        Text('No ${widget.itemName.toLowerCase()} available'),
                  );
                }

                List<DocumentSnapshot> businesses = snapshot.data!.docs;
                businesses =
                    _filterBusinesses(businesses, _searchController.text);

                if (businesses.isEmpty) {
                  return Center(
                    child: Text('No ${widget.itemName.toLowerCase()} found'),
                  );
                }

                return ListView.builder(
                  itemCount: businesses.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> data =
                        businesses[index].data() as Map<String, dynamic>;

                    return BusinessCard(
                      businessData: data,
                      onEdit: () {
                        _editData(context, businesses[index].id, data);
                      },
                      onDelete: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmation'),
                                content: Text(
                                    'Are you sure you want to Delete this Business?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteData(
                                          context, businesses[index].id);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DocumentSnapshot> _filterBusinesses(
      List<DocumentSnapshot> businesses, String query) {
    if (query.isEmpty) {
      return businesses;
    }

    List<DocumentSnapshot> filteredBusinesses = [];
    businesses.forEach((business) {
      Map<String, dynamic> data = business.data() as Map<String, dynamic>;
      if (data['name'].toLowerCase().contains(query.toLowerCase())) {
        filteredBusinesses.add(business);
      }
    });
    return filteredBusinesses;
  }

  void _editData(
      BuildContext context, String documentId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // TextControllers for each field
        TextEditingController _nameController =
            TextEditingController(text: data['name']);
        TextEditingController _locationController =
            TextEditingController(text: data['location']);
        TextEditingController _categoryController =
            TextEditingController(text: data['foodCategory']);
        TextEditingController _totalCustomersController =
            TextEditingController(text: data['totalCustomers'].toString());
        TextEditingController _totalOrdersController =
            TextEditingController(text: data['totalOrders'].toString());
        TextEditingController _totalSalesController =
            TextEditingController(text: data['totalSales'].toString());

        return AlertDialog(
          title: Text('Edit Business'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _totalCustomersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Total Customers'),
                ),
                TextFormField(
                  controller: _totalOrdersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Total Orders'),
                ),
                TextFormField(
                  controller: _totalSalesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Total Sales'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Update data in Firestore
                _firestore
                    .collection(widget.collection)
                    .doc(documentId)
                    .update({
                  'name': _nameController.text,
                  'location': _locationController.text,
                  'foodCategory': _categoryController.text,
                  'totalCustomers': int.parse(_totalCustomersController.text),
                  'totalOrders': int.parse(_totalOrdersController.text),
                  'totalSales': int.parse(_totalSalesController.text),
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Business updated successfully!'),
                    ),
                  );
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update business: $error'),
                    ),
                  );
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteData(BuildContext context, String documentId) {
    _firestore.collection(widget.collection).doc(documentId).delete();
  }
}

class BusinessCard extends StatelessWidget {
  final Map<String, dynamic> businessData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  BusinessCard(
      {required this.businessData,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              businessData['name'] ?? 'Name not available',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            businessData['imageUrl'] != null
                ? Image.network(
                    businessData['imageUrl'],
                    width: double.infinity,
                    height: 200.0,
                    fit: BoxFit.cover,
                  )
                : SizedBox.shrink(),
            SizedBox(height: 8.0),
            Text(
                'Location: ${businessData['location'] ?? 'Location not available'}'),
            Text(
                'Food Category: ${businessData['foodCategory'] ?? 'Category not available'}'),
            Text('Total Customers: ${businessData['totalCustomers'] ?? '0'}'),
            Text('Total Orders: ${businessData['totalOrders'] ?? '0'}'),
            Text('Total Sales:Ugx ${businessData['totalSales'] ?? '0'}'),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    // _updateImage(
                    //     context, businessData['imageUrl'], businessData['id']);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateImage(BuildContext context, String? imageUrl, String businessId) {
    TextEditingController _imageUrlController =
        TextEditingController(text: imageUrl ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Image URL'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Update image URL in Firestore
                FirebaseFirestore.instance
                    .collection('businesses')
                    .doc(businessId)
                    .update({
                  'imageUrl': _imageUrlController.text,
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Image URL updated successfully!'),
                    ),
                  );
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update image URL: $error'),
                    ),
                  );
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }
}

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: OrderList(),
    );
  }
}

class OrderList extends StatefulWidget {
  @override
  _OrderListState createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  late TextEditingController _searchController;
  late String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final orders = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final productName = data['productName'] ?? '';
                return productName.toLowerCase().contains(_searchQuery);
              }).toList();

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final orderData =
                      orders[index].data() as Map<String, dynamic>;

                  return OrderCard(
                    orderId: orders[index].id,
                    orderData: orderData,
                    onEdit: () {
                      _editData(context, orders[index].id, orderData);
                    },
                    onDelete: () {
                      _deleteData(context, orders[index].id);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _editData(
      BuildContext context, String orderId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Order'),
          content: OrderEditForm(orderId: orderId, orderData: data),
        );
      },
    );
  }

  void _deleteData(BuildContext context, String orderId) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order deleted successfully!'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete order: $error'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  OrderCard(
      {required this.orderId,
      required this.orderData,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Name: ${orderData['productName'] ?? 'Product Name not available'}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Current Location: ${orderData['currentLocation'] ?? 'Location not available'}',
            ),
            Text(
              'Is Traveling: ${orderData['isTraveling'] ?? 'Is Traveling not available'}',
            ),
            Text(
              'Order Date Time: ${_formatDateTime(orderData['orderDateTime'])}',
            ),
            Text(
              'Product Price: ${orderData['productPrice'] ?? 'Product Price not available'}',
            ),
            Text(
              'Quantity: ${orderData['quantity'] ?? 'Quantity not available'}',
            ),
            Text(
              'Status: ${orderData['status'] ?? 'Status not available'}',
            ),
            Text(
              'Total Amount: ${orderData['totalAmount'] ?? 'Total Amount not available'}',
            ),
            Text(
              'User Details: ${orderData['userDetails'] ?? 'User Details not available'}',
            ),
            Text(
              'User Email: ${orderData['userEmail'] ?? 'User Email not available'}',
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: const Text(
                                'Are you sure you want to Delete this order?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  onDelete();
                                  Navigator.of(context).pop();
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp != null) {
      DateTime dateTime = timestamp.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
    }
    return 'Date Time not available';
  }
}

class OrderEditForm extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> orderData;

  OrderEditForm({required this.orderId, required this.orderData});

  @override
  _OrderEditFormState createState() => _OrderEditFormState();
}

class _OrderEditFormState extends State<OrderEditForm> {
  late TextEditingController _currentLocationController;
  late TextEditingController _isTravelingController;
  late TextEditingController _productNameController;
  late TextEditingController _productPriceController;
  late TextEditingController _quantityController;
  late TextEditingController _statusController;
  late TextEditingController _totalAmountController;
  late TextEditingController _userDetailsController;
  late TextEditingController _userEmailController;

  @override
  void initState() {
    super.initState();
    _currentLocationController =
        TextEditingController(text: widget.orderData['currentLocation']);
    _isTravelingController =
        TextEditingController(text: widget.orderData['isTraveling'].toString());
    _productNameController =
        TextEditingController(text: widget.orderData['productName']);
    _productPriceController = TextEditingController(
        text: widget.orderData['productPrice'].toString());
    _quantityController =
        TextEditingController(text: widget.orderData['quantity'].toString());
    _statusController = TextEditingController(text: widget.orderData['status']);
    _totalAmountController =
        TextEditingController(text: widget.orderData['totalAmount'].toString());
    _userDetailsController =
        TextEditingController(text: widget.orderData['userDetails']);
    _userEmailController =
        TextEditingController(text: widget.orderData['userEmail']);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _currentLocationController,
            decoration: InputDecoration(labelText: 'Current Location'),
          ),
          TextFormField(
            controller: _isTravelingController,
            decoration: InputDecoration(labelText: 'Is Traveling'),
          ),
          TextFormField(
            controller: _productNameController,
            decoration: InputDecoration(labelText: 'Product Name'),
          ),
          TextFormField(
            controller: _productPriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Product Price'),
          ),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Quantity'),
          ),
          TextFormField(
            controller: _statusController,
            decoration: InputDecoration(labelText: 'Status'),
          ),
          TextFormField(
            controller: _totalAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Total Amount'),
          ),
          TextFormField(
            controller: _userDetailsController,
            decoration: InputDecoration(labelText: 'User Details'),
          ),
          TextFormField(
            controller: _userEmailController,
            decoration: InputDecoration(labelText: 'User Email'),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  _updateData();
                },
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateData() {
    FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
      'currentLocation': _currentLocationController.text,
      'isTraveling': _isTravelingController.text.toLowerCase() == 'true',
      'productName': _productNameController.text,
      'productPrice': int.tryParse(_productPriceController.text) ?? 0,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'status': _statusController.text,
      'totalAmount': int.tryParse(_totalAmountController.text) ?? 0,
      'userDetails': _userDetailsController.text,
      'userEmail': _userEmailController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order updated successfully!'),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $error'),
        ),
      );
    });
  }
}

//products

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot product = snapshot.data!.docs[index];
                      if (_searchText.isEmpty ||
                          product['productName']
                              .toLowerCase()
                              .contains(_searchText)) {
                        return ProductCard(product);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final DocumentSnapshot product;

  ProductCard(this.product);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  File? _image;
  final picker = ImagePicker();
  bool _savingChanges = false;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImage() async {
    if (_image != null) {
      setState(() {
        _savingChanges = true;
      });

      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().toString()}');
      UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() => null);
      storageReference.getDownloadURL().then((fileURL) {
        FirebaseFirestore.instance
            .collection('products')
            .doc(widget.product.id)
            .update({'imageUrl': fileURL}).then((_) {
          setState(() {
            _savingChanges = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image updated successfully.'),
            ),
          );
        }).catchError((error) {
          setState(() {
            _savingChanges = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update image: $error'),
            ),
          );
        });
      }).catchError((error) {
        setState(() {
          _savingChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get image URL: $error'),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              getImage();
            },
            child: Container(
              width: double.infinity,
              height: 200,
              child: _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      widget.product['imageUrl'],
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          ListTile(
            title: Text(widget.product['productName']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${widget.product['category']}'),
                Text('Description: ${widget.product['description']}'),
                Text('Price: Ugx${widget.product['price'].toString()}'),
                Text('Quantity: ${widget.product['quantity']}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _editProductDialog(widget.product);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: const Text(
                                'Are you sure you want to Delete this Product?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteProduct(widget.product.id);
                                  Navigator.of(context).pop();
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editProductDialog(DocumentSnapshot product) {
    TextEditingController _productNameController =
        TextEditingController(text: product['productName']);
    TextEditingController _categoryController =
        TextEditingController(text: product['category']);
    TextEditingController _descriptionController =
        TextEditingController(text: product['description']);
    TextEditingController _priceController =
        TextEditingController(text: product['price'].toString());
    TextEditingController _quantityController =
        TextEditingController(text: product['quantity'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: _savingChanges
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text('Save'),
              onPressed: _savingChanges
                  ? null
                  : () {
                      setState(() {
                        _savingChanges = true;
                      });
                      FirebaseFirestore.instance
                          .collection('products')
                          .doc(product.id)
                          .update({
                        'productName': _productNameController.text,
                        'category': _categoryController.text,
                        'description': _descriptionController.text,
                        'price': int.parse(_priceController.text),
                        'quantity': int.parse(_quantityController.text),
                      }).then((_) {
                        setState(() {
                          _savingChanges = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Changes saved successfully.'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }).catchError((error) {
                        setState(() {
                          _savingChanges = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to save changes: $error'),
                          ),
                        );
                      });
                    },
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String productId) {
    FirebaseFirestore.instance.collection('products').doc(productId).delete();
  }
}

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot user = snapshot.data!.docs[index];
                      if (_searchText.isEmpty ||
                          user['email'].toLowerCase().contains(_searchText)) {
                        return UserCard(user);
                      } else {
                        return Container();
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final DocumentSnapshot user;

  UserCard(this.user);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(user['email']),
        subtitle: Text('Role: ${user['role']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _editUserDialog(context, user);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text(
                            'Are you sure you want to Delete this User?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteUser(user.id);
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editUserDialog(BuildContext context, DocumentSnapshot user) {
    TextEditingController _emailController =
        TextEditingController(text: user['email']);
    TextEditingController _roleController =
        TextEditingController(text: user['role']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  enabled: false,
                ),
                TextFormField(
                  controller: _roleController,
                  decoration: InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .update({
                  'role': _roleController.text,
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Changes saved successfully.'),
                    ),
                  );
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save changes: $error'),
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}
