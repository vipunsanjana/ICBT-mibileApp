import 'dart:convert';
import 'package:ecomm/screen/adminProfile/adminProfile.dart';
import 'package:ecomm/screen/approveAdd/approveAdd.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecomm/screen/profile/profile.dart'; // Import the Profile screen



class AdminHome extends StatefulWidget {
  const AdminHome({Key? key, required this.userId,required this.token }) : super(key: key);

  final String userId;
  final String token;

  @override
  _AdminHomeState createState() => _AdminHomeState(userId: userId,token: token); // Pass userId here
}

class _AdminHomeState extends State<AdminHome> {
  final String userId;
  final String token;

  _AdminHomeState({required this.userId, required this.token}); // No need for another constructor

  List<dynamic> approvedAdds = [];
  bool isLoading = true;
  int _selectedIndex = 0;

// ... rest of your code



  // Index for the selected bottom navigation bar item

  @override
  void initState() {
    super.initState();
    fetchApprovedAdds();
  }

  Future<void> fetchApprovedAdds() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3002/api/admin/get-all-adds'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          approvedAdds = responseData['data'];
          isLoading = false;
        });
        print(userId);
        print(userId);
        print(userId);

      } else {
        print('Failed to load data: ${response.statusCode}');
        // Handle error cases here
      }
    } catch (error) {
      print('Error fetching data: $error');
      // Handle error cases here
    }
  }



  List<String> imagePaths = [
    'asset/image/full.jpg',
    'asset/image/home2.jpeg',
    'asset/image/home3.png',
    'asset/image/home4.png',
    'asset/image/home5.jpg',
    // Add more image paths as needed
  ];





  // Function to handle bottom navigation bar item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Navigate to other screens based on index
      switch (index) {
        case 0:
        // Navigate to the Home screen
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
          break;
        case 1:
        // Navigate to the Profile screen
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ApproveAdd(userId: userId,token: token)));
          break;

        case 2:
        // Navigate to the Profile screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AdminProfile(userId: userId, token: token),
            ),
          );
          break;
      // Add cases for other screens if needed
      }
    });
  }

  // Function to navigate to the details page of a selected ad
  void _navigateToAdDetails(dynamic ad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdDetailsPage(ad: ad),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: Text('Island Homes'),

      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : approvedAdds.isEmpty
          ? Center(child: Text('No adds found'))
          : SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true, // Set shrinkWrap to true
          itemCount: approvedAdds.length,
          itemBuilder: (context, index) {
            final add = approvedAdds[index];
            return GestureDetector(
              onTap: () => _navigateToAdDetails(add),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  width: double.infinity,
                  height: 185, // Increased height
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 190,top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${add['name'] ?? ''}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Description: ${add['description'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'From: ${add['from'] ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Price: \$${add['price'] ?? ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              imagePaths[index % imagePaths.length], // Adjust this to use the actual image path
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ), BottomNavigationBarItem(
            icon: Icon(Icons.approval),
            label: 'Approve Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          // Add more BottomNavigationBarItems for other screens if needed
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}


class AdDetailsPage extends StatelessWidget {
  final dynamic ad;

  const AdDetailsPage({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> imagePaths = [
      'asset/image/full.jpg',
      'asset/image/home2.jpeg',
      'asset/image/home3.png',
      'asset/image/home4.png',
      'asset/image/home5.jpg',
      // Add more image paths as needed
    ];
    imagePaths.shuffle();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Details'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white24,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  imagePaths[0], // Display a randomly picked image
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 16),
                Text(
                  ad['name'] ?? '',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  ad['description'] ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Price: \$${ad['price'] ?? ''}',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}