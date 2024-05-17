import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State {
  int totalBusinesses = 0;
  int totalCustomers = 0;
  int totalOrders = 0;
  int totalSales = 0;

  int totalOrdersCount = 0;
  int totalOrdersAmount = 0;
  double averageOrderValue = 0;

  Map<String, int> orderStatusCount = {};
  Map<String, int> orderisTraveling = {};

  int totalProducts = 0;
  Map<String, int> productSalesAmount = {};
  Map<String, int> productQuantitySold = {};

  int totalUsers = 0;
  int foodVendorsCount = 0;
  int customersCount = 0;
  int AdminCount = 0;
  int activeUsersCount = 0;

  int productCategory1 = 0;
  int productCategory2 = 0;
  int productCategory3 = 0;
  int productCategory4 = 0;
  int productCategory5 = 0;
  int productCategory6 = 0;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    await _fetchBusinessesAnalytics();
    await _fetchOrdersAnalytics();
    //await _fetchProductsAnalytics();
    //await _fetchProductsAnalytics();
    await fetchProductAnalytics();
    await _fetchUsersAnalytics();
  }

  Future<void> _fetchBusinessesAnalytics() async {
    QuerySnapshot businessesSnapshot =
        await FirebaseFirestore.instance.collection('businesses').get();

    setState(() {
      totalBusinesses = businessesSnapshot.docs.length;
      totalOrders = businessesSnapshot.docs
          .where((doc) => doc['totalOrders'] > 0)
          .toList()
          .length;

      totalSales = businessesSnapshot.docs
          .where((doc) => doc['totalSales'] > 0)
          .toList()
          .length;

      totalCustomers = businessesSnapshot.docs
          .where((doc) => doc['totalCustomers'] > 0)
          .toList()
          .length;
    });
  }

  Future<void> _fetchOrdersAnalytics() async {
    QuerySnapshot ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    setState(() {
      totalOrdersCount = ordersSnapshot.docs.length;

      orderStatusCount = {};
      ordersSnapshot.docs.forEach((doc) {
        String status = doc['status'] ?? 'unknown';
        orderStatusCount[status] = (orderStatusCount[status] ?? 0) + 1;
      });
    });
  }

  Future<void> fetchProductAnalytics() async {
    QuerySnapshot productSnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      totalProducts = productSnapshot.docs.length;

      productCategory1 = productSnapshot.docs
          .where((doc) => doc['category'] == 'Meat')
          .toList()
          .length;

      productCategory2 = productSnapshot.docs
          .where((doc) => doc['category'] == 'Snacks')
          .toList()
          .length;
      productCategory3 = productSnapshot.docs
          .where((doc) => doc['category'] == 'Drinks')
          .toList()
          .length;

      productCategory4 = productSnapshot.docs
          .where((doc) => doc['category'] == 'Grains')
          .toList()
          .length;

      productCategory5 = productSnapshot.docs
          .where((doc) => doc['category'] == 'Real Food')
          .toList()
          .length;

      productCategory6 = productSnapshot.docs
          .where((doc) => doc['category'] == 'Fruits')
          .toList()
          .length;

      activeUsersCount = customersCount + foodVendorsCount;
    });
  }

  Future<void> _fetchUsersAnalytics() async {
    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    setState(() {
      totalUsers = usersSnapshot.docs.length;

      foodVendorsCount = usersSnapshot.docs
          .where((doc) => doc['role'] == 'Food Vendor')
          .toList()
          .length;

      customersCount = usersSnapshot.docs
          .where((doc) => doc['role'] == 'Customer')
          .toList()
          .length;

      AdminCount = usersSnapshot.docs
          .where((doc) => doc['role'] == 'Admin')
          .toList()
          .length;

      activeUsersCount = customersCount + foodVendorsCount + AdminCount;
    });
  }

  // //products
  // Future<void> _fetchProductsAnalytics() async {
  //   QuerySnapshot productSnapshot =
  //       await FirebaseFirestore.instance.collection('products').get();

  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Analytics'),
      // ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Businesses Analytics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Total Businesses: $totalBusinesses'),
                    Text('Total Customers: $totalCustomers'),
                    Text('Total Orders: $totalOrders'),
                    Text('Total Sales: $totalSales'),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders Analytics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Total Orders: $totalOrdersCount'),
                    Text('Order Statuses:'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: orderStatusCount.keys
                          .map((status) =>
                              Text('- $status: ${orderStatusCount[status]}'))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Products Analytics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Total Products: $totalProducts'),
                    Text('Types Of Categories  : 6'),
                    Text('Meat Category  : $productCategory1'),
                    Text('Snacks Category: $productCategory2'),
                    Text('Drinks Category: $productCategory3'),
                    Text('Grains Category: $productCategory4'),
                    Text('Real Food Category: $productCategory5'),
                    Text('Fruits Category: $productCategory6'),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Users Analytics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Total Users: $totalUsers'),
                    Text('Food Vendors: $foodVendorsCount'),
                    Text('Customers: $customersCount'),
                    Text('Admin: $AdminCount'),
                    Text('Active Users: $activeUsersCount'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
