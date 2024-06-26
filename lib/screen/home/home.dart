import 'dart:convert';
import 'package:ecomm/predict/predict.dart';
import 'package:ecomm/screen/createAdd/createAdd.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecomm/screen/profile/profile.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.userId, required this.token}) : super(key: key);

  final String userId;
  final String token;

  @override
  _HomeState createState() => _HomeState(userId: userId, token: token);
}

class _HomeState extends State<Home> {
  final String userId;
  final String token;

  _HomeState({required this.userId, required this.token});

  TextEditingController searchController = TextEditingController();

  List<dynamic> approvedAdds = [];
  List<dynamic> fromAdds = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchApprovedAdds();
    fetchFromAdds();
  }

  Future<void> fetchApprovedAdds() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3002/api/user/get-approved-adds'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          approvedAdds = responseData['data'];
          isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
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

  int currentIndex = 0;

  Future<void> fetchFromAdds() async {
    try {
      String from = searchController.text;
      final response = await http.get(Uri.parse('http://localhost:3002/api/user/get-from-adds/$from'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          fromAdds = responseData['data'];
          isLoading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void _handleSearchButton() {
    String searchValue = searchController.text;
    if (searchValue.isNotEmpty) {
      fetchFromAdds();
      setState(() {
        isSearching = true;
      });
    } else {
      fetchApprovedAdds();
      setState(() {
        isSearching = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          break;
        case 1:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CreateAddPage(userId: userId, token: token)));
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(userId: userId, token: token),
            ),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PredictPage(userId: userId, token: token),
            ),
          );
          break;
      }
    });
  }

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
    imagePaths.shuffle();
    return Scaffold(
      appBar: AppBar(
        title: Text('Island Homes'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      filled: true,
                      fillColor: Colors.grey,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _handleSearchButton,
                  child: Text('Search'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isSearching
          ? fromAdds.isEmpty
          ? Center(child: Text('No ads found'))
          : ListView.builder(
        itemCount: fromAdds.length,
        itemBuilder: (context, index) {
          final add = fromAdds[index];
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
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 190, top: 20),
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
                              offset: Offset(0, 3),
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
      )
          : approvedAdds.isEmpty
          ? Center(child: Text('No ads found'))
          : ListView.builder(
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
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 190, top: 20),
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
                              offset: Offset(0, 3),
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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.home,
                color: Colors.black,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
            label: 'Create Add',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.person,
                color: Colors.black,
              ),
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
                Icons.batch_prediction,
                color: Colors.black,
              ),
            ),
            label: 'Predict',
          ),
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