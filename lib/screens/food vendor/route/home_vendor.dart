import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sfc/screens/food%20vendor/route/pages/constants/categories.dart';
import 'package:sfc/screens/food%20vendor/route/screens/all_businesses_vc.dart';
import 'package:sfc/screens/food%20vendor/route/screens/see_all.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorHome extends StatefulWidget {
  final String userId;

  const VendorHome({Key? key, required this.userId}) : super(key: key);

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late List<String> businessIds;

  String greetings = '';

  greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      setState(() {
        greetings = 'Good Morning';
      });
    } else if ((hour >= 12) && (hour <= 16)) {
      setState(() {
        greetings = 'Good Afternoon,';
      });
    } else if ((hour > 16) && (hour < 20)) {
      setState(() {
        greetings = 'Good Evening,';
      });
    } else {
      setState(() {
        greetings = 'Good Evening,';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    greeting();
    _getBusinessIds();
  }

  void _getBusinessIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('businesses')
        .where('userId', isEqualTo: currentUser.uid)
        .get();
    setState(() {
      businessIds = snapshot.docs.map((doc) => doc.id).toList(growable: false);
    });

    businessIds.forEach((businessId) {
      FirebaseFirestore.instance
          .collection('orders')
          .where('businessId', isEqualTo: businessId)
          .get()
          .then((querySnapshot) {
        int totalOrders = querySnapshot.docs.length;
        int totalSales = 0;
        Set<String> customers = Set<String>();
        querySnapshot.docs.forEach((order) {
          totalSales += order.data()['totalAmount'] as int;
          customers.add(order.data()['userDetails']);
        });
        FirebaseFirestore.instance
            .collection('businesses')
            .doc(businessId)
            .update({
          'totalOrders': totalOrders,
          'totalSales': totalSales,
          'totalCustomers': customers.length,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          greetings,
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("${currentUser.email!}"),
                        // Text(
                        //   'Comfort!',
                        //   style: TextStyle(
                        //     fontSize: 15,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Hungry Today!',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderHandlingScreen(
                                  businessIds: businessIds,
                                ),
                              ),
                            );
                          },
                          child: Icon(Icons.shopping_cart),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                          },
                          child: Icon(Icons.logout),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Container(
            //         decoration: BoxDecoration(
            //           color: Colors.grey[200],
            //           borderRadius: BorderRadius.circular(24.0),
            //         ),
            //         child: Padding(
            //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //           child: TextField(
            //             decoration: InputDecoration(
            //               hintText: 'Search...',
            //               border: InputBorder.none,
            //               suffixIcon: Icon(Icons.search),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AnalyticsScreen(
                          businessIds: businessIds!,
                        );
                      }));
                    },
                    child: Text('Analytics')),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return SeeAll();
                    }));
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  // Categories
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: AllBusinessesScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderHandlingScreen extends StatelessWidget {
  final List<String> businessIds;

  const OrderHandlingScreen({Key? key, required this.businessIds})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Handling'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('businessId', whereIn: businessIds)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders available.'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Total Amount')),
                DataColumn(label: Text('Order Date')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Traveling')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _buildOrderRows(context, snapshot.data!.docs),
            ),
          );
        },
      ),
    );
  }

  List<DataRow> _buildOrderRows(
      BuildContext context, List<QueryDocumentSnapshot> documents) {
    List<DataRow> rows = [];
    documents.forEach((document) {
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      rows.add(DataRow(
        cells: [
          DataCell(Text(data['productName'])),
          DataCell(Text(data['productPrice'].toString())),
          DataCell(Text(data['quantity'].toString())),
          DataCell(Text(data['totalAmount'].toString())),
          // DataCell(Text(data['orderDateTime'].toString())),
          DataCell(Text(_formatDateTime(data['orderDateTime']))),
          DataCell(Text(data['currentLocation'] ?? 'N/A')),
          DataCell(Text(data['isTraveling'] ? 'Yes' : 'No')),
          DataCell(Text(data['status'])),
          DataCell(Row(
            children: [
              ElevatedButton(
                onPressed: () => _handleOrder(context, document.id, 'approved'),
                child: Text('Approve'),
              ),
              ElevatedButton(
                onPressed: () => _handleOrder(context, document.id, 'declined'),
                child: Text('Decline'),
              ),
              ElevatedButton(
                onPressed: () => _removeOrder(context, document.id),
                child: Text('Remove'),
              ),
            ],
          )),
        ],
      ));
    });
    return rows;
  }

  void _handleOrder(BuildContext context, String orderId, String status) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': status,
    }).then((value) {
      // Send notification to the user
      _sendNotificationToUser(orderId, status);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error handling order: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _removeOrder(BuildContext context, String orderId) {
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .delete()
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order removed successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing order: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _sendNotificationToUser(String orderId, String status) async {
    // Retrieve user details
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get()
        .then((doc) {
      Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
      String userPhone = orderData['userDetails'];
      String message = 'Your order ${orderId.substring(0, 6)} is $status.';
      // Send a message to the user
      sendMessage(userPhone, message);
    }).catchError((error) {
      print('Error sending notification: $error');
    });
  }

  void sendMessage(String userPhone, String message) async {
    final url = 'sms:$userPhone?body=$message';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
}

//analytics
class AnalyticsScreen extends StatelessWidget {
  final List<String> businessIds;

  const AnalyticsScreen({Key? key, required this.businessIds})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'),
      ),
      body: ListView.builder(
        itemCount: businessIds.length,
        itemBuilder: (context, index) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('businesses')
                .doc(businessIds[index])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (!snapshot.hasData) {
                return Container();
              }

              var businessData = snapshot.data!.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(businessData['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Orders: ${businessData['totalOrders'] ?? 0}'),
                      Text('Total Sales: ${businessData['totalSales'] ?? 0}'),
                      Text(
                          'Total Customers: ${businessData['totalCustomers'] ?? 0}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
