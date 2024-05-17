import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sfc/screens/food%20vendor/route/home_vendor.dart';

import 'package:sfc/screens/food%20vendor/route/pages/vendor_profile.dart';

class Vendor extends StatefulWidget {
  const Vendor({Key? key, required this.userId, required this.userEmail})
      : super(key: key);
  final String userId;
  final String userEmail;

  @override
  State<Vendor> createState() => _VendorState();
}

class _VendorState extends State<Vendor> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List pages = [
      VendorHome(userId: widget.userId),
      //OrderHandlingScreen(businessId: widget.userId),
      //const VendorMarket(),
      VendorProfile(
          userId: widget.userId,
          userEmail: widget.userEmail), // Pass userEmail here
      // const VendorMore(),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(color: Colors.white),
          child: GNav(
            rippleColor: Colors.yellow,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.green,
            padding: const EdgeInsets.all(10),
            gap: 4,
            onTabChange: _onItemTapped,
            tabs: const [
              GButton(
                icon: Icons.home,
                iconColor: Colors.brown,
                text: 'Home',
              ),
              // GButton(
              //   icon: Icons.shop,
              //   iconColor: Colors.brown,
              //   text: 'Orders',
              // ),
              GButton(
                icon: Icons.person,
                iconColor: Colors.brown,
                text: 'Profile',
              ),
              // GButton(
              //   icon: Icons.more_horiz_outlined,
              //   iconColor: Colors.brown,
              //   text: 'More',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
