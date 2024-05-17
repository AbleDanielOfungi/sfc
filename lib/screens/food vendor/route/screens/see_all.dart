import 'package:flutter/material.dart';
import 'package:sfc/screens/food%20vendor/route/screens/all_businesses_vc.dart';

//dsiplays all businesses
class SeeAll extends StatefulWidget {
  const SeeAll({super.key});

  @override
  State<SeeAll> createState() => _SeeAllState();
}

class _SeeAllState extends State<SeeAll> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Businesses',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AllBusinessesScreen(),
    );
  }
}
