import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//displaying orders made by each customer or vendor(csutomer)

class UserOrdersScreen extends StatefulWidget {
  final String userEmail;

  const UserOrdersScreen({required this.userEmail});

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
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
        title: const Text(
          'Your Orders',
          style: TextStyle(color: Colors.green),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
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
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userEmail', isEqualTo: widget.userEmail)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders placed yet.'));
                }

                // Filtering the orders based on user input
                final filteredOrders = snapshot.data!.docs.where((order) {
                  final productName =
                      order['productName'].toString().toLowerCase();
                  final searchValue = _searchController.text.toLowerCase();
                  return productName.contains(searchValue);
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(child: Text('No matching orders found.'));
                }

                return ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = filteredOrders[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return OrderCard(
                      productName: data['productName'],
                      productPrice: data['productPrice'],
                      quantity: data['quantity'],
                      totalAmount: data['totalAmount'],
                      status: data['status'],
                      userEmail: widget.userEmail,
                      orderId: document.id,
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

class OrderCard extends StatelessWidget {
  final String productName;
  final int productPrice;
  final int quantity;
  final int totalAmount;
  final String status;
  final String userEmail;
  final String orderId;

  const OrderCard({
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.userEmail,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Product Name: $productName',
                  style: const TextStyle(fontSize: 18.0),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmation'),
                          content: const Text(
                              'Are you sure you want to Delete your Order?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(orderId)
                                    .delete()
                                    .then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Order Deleted successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Failed to delete the order'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                });
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text('Price per unit:Ugx $productPrice'),
            Text('Quantity: $quantity'),
            Text('Total Amount: Ugx $totalAmount'),
            const SizedBox(height: 8.0),
            Text('Status: $status'),
          ],
        ),
      ),
    );
  }
}
