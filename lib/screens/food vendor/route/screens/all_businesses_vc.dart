import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

//displays all business, when clicked on a business card
//displays all the available products
//user can go on to place an orders

class AllBusinessesScreen extends StatefulWidget {
  @override
  State<AllBusinessesScreen> createState() => _AllBusinessesScreenState();
}

class _AllBusinessesScreenState extends State<AllBusinessesScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {}); // Trigger rebuild on text change
            },
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('businesses').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No businesses registered yet.'));
              }
              // Filtering the Business based on user input
              final filteredOrders = snapshot.data!.docs.where((businesses) {
                final businessName =
                    businesses['name'].toString().toLowerCase();
                final searchValue = _searchController.text.toLowerCase();
                return businessName.contains(searchValue);
              }).toList();

              if (filteredOrders.isEmpty) {
                return Center(child: Text('No businesses registered yet.'));
              }

              return ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = filteredOrders[index];
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return SizedBox(
                    height: 250,
                    child: BusinessCard(
                      businessId: document.id,
                      name: data['name'],
                      location: data['location'],
                      category: data['foodCategory'],
                      contact: data['contact'],
                      imageUrl: data['imageUrl'],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

//business cards
class BusinessCard extends StatefulWidget {
  final String businessId;
  final String name;
  final String location;
  final String category;
  final String contact;
  final String imageUrl;

  const BusinessCard({
    required this.businessId,
    required this.name,
    required this.location,
    required this.category,
    required this.contact,
    required this.imageUrl,
  });

  @override
  State<BusinessCard> createState() => _BusinessCardState();
}

class _BusinessCardState extends State<BusinessCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProducts(context),
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined),
                      Text(
                        widget.location,
                        style: TextStyle(color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Category: ${widget.category}',
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.0),
                  GestureDetector(
                    onTap: () => _launchPhone(widget.contact),
                    child: Row(
                      children: [
                        Icon(Icons.phone, color: Colors.green),
                        SizedBox(width: 4.0),
                        Text(
                          widget.contact,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessProductsScreen(
            businessId: widget.businessId, businessName: widget.name),
      ),
    );
  }

  void _launchPhone(String phone) async {
    if (await canLaunch('tel:$phone')) {
      await launch('tel:$phone');
    } else {
      throw 'Could not launch $phone';
    }
  }
}

//screen showing products of that clicked business cards
class BusinessProductsScreen extends StatefulWidget {
  final String businessId;
  final String businessName;

  BusinessProductsScreen(
      {required this.businessId, required this.businessName});

  @override
  State<BusinessProductsScreen> createState() => _BusinessProductsScreenState();
}

class _BusinessProductsScreenState extends State<BusinessProductsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.businessName} Products',
          style: const TextStyle(color: Colors.green, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild on text change
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('businessId', isEqualTo: widget.businessId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(
                          'No products available for ${widget.businessName}.'));
                }
                // Filtering the Business based on user input
                final filteredProducts = snapshot.data!.docs.where((products) {
                  final productName =
                      products['productName'].toString().toLowerCase();
                  final searchValue = _searchController.text.toLowerCase();
                  return productName.contains(searchValue);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                      child: Text('No Products registered yet.'));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = filteredProducts[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ProductCard(
                      name: data['productName'],
                      price: int.parse(data['price'].toString()),
                      description: data['description'],
                      quantity: data['quantity'],
                      category: data['category'],
                      imageUrl: data['imageUrl'],
                      businessId: widget.businessId,
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
}

//product card
class ProductCard extends StatelessWidget {
  final String name;
  final int price;
  final String description;
  final int quantity;
  final String category;
  final String imageUrl;
  final String businessId;

  const ProductCard({
    required this.name,
    required this.price,
    required this.description,
    required this.quantity,
    required this.category,
    required this.imageUrl,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showProductDetails(context),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text('Price: $price'),
                Text('Quantity: $quantity'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderScreen(
                          productName: name,
                          productPrice: price,
                          businessId: businessId,
                        ),
                      ),
                    );
                  },
                  child: const Text('Order Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8.0),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Price: Ugx$price',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Description: $description',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Quantity: $quantity',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Category: $category',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        );
      },
    );
  }
}

//orders screen: u place orders here
class OrderScreen extends StatefulWidget {
  final String productName;
  final int productPrice;
  final String businessId;

  const OrderScreen({
    required this.productName,
    required this.productPrice,
    required this.businessId,
  });

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isTraveling = false;
  String? currentLocation;
  String? userDetails;
  DateTime? orderDateTime;
  int quantity = 1;
  int totalAmount = 0;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    calculateTotalAmount();
  }

  void _getUserEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userEmail = user.email;
    }
  }

  void calculateTotalAmount() {
    setState(() {
      totalAmount = widget.productPrice * quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order ${widget.productName}',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Product: ${widget.productName}',
                        style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Price per unit: Ugx${widget.productPrice}',
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (quantity > 1) quantity--;
                        calculateTotalAmount();
                      });
                    },
                  ),
                  Text(
                    ' $quantity ',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        quantity++;
                        calculateTotalAmount();
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Amount: Ugx$totalAmount',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              TextFormField(
                enabled: false,
                initialValue: totalAmount.toString(),
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
                  labelText: 'Amount Paid',
                  hintText: 'Enter Amount Paid',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  // Nothing to do here
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
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
                  labelText: 'Current Location',
                  hintText: 'Enter Current Location',
                ),
                onChanged: (value) {
                  currentLocation = value;
                },
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                keyboardType: TextInputType.number,
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
                  labelText: 'User Contact',
                  hintText: 'Enter User Contact',
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) {
                  userDetails = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a contact number';
                  } else if (value.length != 10) {
                    return 'Contact number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              CheckboxListTile(
                title: Text('Is Traveling'),
                value: isTraveling,
                onChanged: (value) {
                  setState(() {
                    isTraveling = value!;
                  });
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  orderDateTime = DateTime.now();
                  _placeOrder(context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Place Order',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context) {
    // Get current date and time
    DateTime now = DateTime.now();

    // Calculate total amount
    totalAmount = widget.productPrice * quantity;

    // Validate user contact number
    if (userDetails == null || userDetails!.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 10-digit contact number'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Create order object
    Map<String, dynamic> orderData = {
      'userEmail': userEmail, // Add user email to order data
      'productName': widget.productName,
      'productPrice': widget.productPrice,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'currentLocation': currentLocation,
      'isTraveling': isTraveling,
      'userDetails': userDetails,
      'orderDateTime': now,
      'status': 'pending',
      'businessId': widget.businessId,
    };

    // Add order to Firestore
    FirebaseFirestore.instance
        .collection('orders')
        .add(orderData)
        .then((value) {
      // Send notification to the business owner
      _sendNotificationToBusinessOwner(context);

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed for ${widget.productName}'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _sendNotificationToBusinessOwner(BuildContext context) {
    // Implement sending notification to business owner here
  }
}
