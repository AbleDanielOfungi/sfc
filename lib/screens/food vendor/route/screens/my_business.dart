import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sfc/screens/food%20vendor/route/screens/product_management/edit_my_business.dart';
import 'package:sfc/screens/food%20vendor/route/screens/product_management/product_management.dart';

//vendorz businesses registered displayed here for that specific vendor
class MyBusinessesScreen extends StatelessWidget {
  const MyBusinessesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Businesses',
          style: TextStyle(color: Colors.green),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('businesses')
            .where('userId',
                isEqualTo: userId) // Filter by current user's userId
            .snapshots(),
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
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String businessId = document.id; // Get the businessId
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['location']),
                trailing: IconButton(
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
                                  FirebaseFirestore.instance
                                      .collection('businesses')
                                      .doc(businessId)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Business Deleted successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        });
                  },
                  icon: Icon(Icons.delete),
                ),
                // Add more details to display if needed
                onTap: () {
                  // Navigate to product management screen when a business is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductManagementScreen(
                        businessId: businessId, // Pass the businessId
                        businessName: data['name'], // Pass the businessName
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  // Navigate to edit business screen when a business is long pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBusinessScreen(
                        businessId: businessId, // Pass the businessId
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
