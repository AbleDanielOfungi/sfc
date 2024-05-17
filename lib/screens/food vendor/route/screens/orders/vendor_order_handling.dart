import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//showing orders amde to a vendor
class BusinessOrdersScreen extends StatelessWidget {
  final String businessId;
  final String businessName;

  BusinessOrdersScreen({required this.businessId, required this.businessName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$businessName Orders'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('businessId', isEqualTo: businessId)
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
                child: Text('No orders available for $businessName.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return OrderItemCard(
                orderId: document.id,
                productName: data['productName'],
                quantity: data['quantity'],
                totalAmount: data['totalAmount'],
                amountPaid: data['amountPaid'],
                isTraveling: data['isTraveling'],
                currentLocation: data['currentLocation'],
                userDetails: data['userDetails'],
                orderDateTime: data['orderDateTime'],
                status: data['status'],
              );
            },
          );
        },
      ),
    );
  }
}

class OrderItemCard extends StatelessWidget {
  final String orderId;
  final String productName;
  final int quantity;
  final double totalAmount;
  final String? amountPaid;
  final bool isTraveling;
  final String? currentLocation;
  final String? userDetails;
  final DateTime? orderDateTime;
  final String status;

  OrderItemCard({
    required this.orderId,
    required this.productName,
    required this.quantity,
    required this.totalAmount,
    required this.amountPaid,
    required this.isTraveling,
    required this.currentLocation,
    required this.userDetails,
    required this.orderDateTime,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: $productName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text('Quantity: $quantity'),
            Text('Total Amount: Ugx $totalAmount'),
            Text('Amount Paid: Ugx ${amountPaid ?? 'N/A'}'),
            Text('Is Traveling: ${isTraveling ? 'Yes' : 'No'}'),
            Text('Current Location: ${currentLocation ?? 'N/A'}'),
            Text('User Details: ${userDetails ?? 'N/A'}'),
            Text('Order Date: ${orderDateTime?.toString() ?? 'N/A'}'),
            const SizedBox(height: 8.0),
            Text('Status: $status'),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _updateOrderStatus(context, 'approved'),
                  child: const Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () => _updateOrderStatus(context, 'declined'),
                  child: const Text('Decline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateOrderStatus(BuildContext context, String newStatus) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus}).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order $orderId $newStatus'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order status: $error'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
}
