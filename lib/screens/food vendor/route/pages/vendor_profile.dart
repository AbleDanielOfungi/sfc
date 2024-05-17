import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sfc/screens/food%20vendor/route/screens/orders/users_orders_customer.dart';
import 'package:sfc/screens/food%20vendor/route/screens/orders/vendor_order_handling.dart';
import 'package:sfc/screens/food%20vendor/route/screens/register_vendor_business.dart';
import '../screens/my_business.dart';
// Import the UserOrdersScreen

class VendorProfile extends StatefulWidget {
  final String userId;
  final String userEmail; // Add userEmail here

  const VendorProfile({Key? key, required this.userId, required this.userEmail})
      : super(key: key);

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  String _businessName = '';
  bool _isLoading = false; // Track loading state

  @override
  void initState() {
    super.initState();
    if (widget.userId.isNotEmpty) {
      _fetchBusinessName();
    }
  }

  Future<void> _fetchBusinessName() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });
    final DocumentSnapshot businessSnapshot = await FirebaseFirestore.instance
        .collection('businesses')
        .doc(widget.userId)
        .get();

    if (businessSnapshot.exists) {
      setState(() {
        _businessName = businessSnapshot.get('name');
        _isLoading = false; // Set loading state to false when data is loaded
      });
    } else {
      setState(() {
        _isLoading = false; // Set loading state to false when no data is found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            text: 'Register Business',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BusinessRegistrationScreen()),
              );
            },
          ),
          const SizedBox(height: 40),
          _buildButton(
            text: 'My Businesses',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyBusinessesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          _isLoading
              ? CircularProgressIndicator()
              : _businessName.isEmpty
                  ? SizedBox()
                  : _buildButton(
                      text: 'My Orders',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessOrdersScreen(
                              businessId: widget.userId,
                              businessName: _businessName,
                            ),
                          ),
                        );
                      },
                    ),
          const SizedBox(height: 40),
          _buildButton(
            text: 'Your Orders', // Button to navigate to UserOrdersScreen
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserOrdersScreen(
                    userEmail: widget.userEmail, // Pass userEmail here
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required String text, required Function onPressed}) {
    return Center(
      child: GestureDetector(
        onTap: () => onPressed(),
        child: Container(
          height: 50,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
