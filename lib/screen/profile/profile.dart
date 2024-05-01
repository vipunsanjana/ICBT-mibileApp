import 'dart:convert';
import 'package:ecomm/screen/SignIn/SignIn.dart';
import 'package:ecomm/screen/home/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Profile extends StatefulWidget {
  const Profile({Key? key, required this.userId, required this.token}) : super(key: key);

  final String userId;
  final String token;

  @override
  _ProfileState createState() => _ProfileState(userId: userId, token: token);
}

class _ProfileState extends State<Profile> {
  final String userId;
  String token;

  _ProfileState({required this.userId, required this.token});

  List<dynamic> adminData = [];
  bool isLoading = true;


  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    AdminDetails();
  }







  void AdminDetails() async {
    try {
      final response = await http.get(
          Uri.parse('http://localhost:3002/api/admin/profile/$userId'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            adminData = [responseData['user']];
            isLoading = false;
          });
        } else {
          print('Failed to load data: ${responseData['message']}');
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  //
  // Future<void> logout(String token) async {
  //   try {
  //     final response = await http.post(Uri.parse('http://10.0.2.2:3002/api/user/logout'),
  //       headers: {
  //         'Authorization': 'Bearer $token', // Attach the token to the request
  //         'Content-Type': 'application/json',
  //       },); // Replace with your actual API endpoint
  //     token = "";
  //
  //     print(token);
  //     print(token);
  //     print(token);
  //     print(token);
  //
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       if (responseData['success'] == true) {
  //         print(' successfully');
  //
  //         Navigator.of(context).pushReplacement(MaterialPageRoute(
  //           builder: (BuildContext context) => const SignIn(),
  //         ));
  //
  //         showSnackBar(context, 'Logout successfully');
  //
  //
  //         // Indicate successful deletion
  //       } else {
  //         print('Failed : ${responseData['message']}');
  //
  //         // Indicate deletion failure
  //       }
  //     } else {
  //       print('Failed : ${response.statusCode}');
  //       // Indicate API error
  //     }
  //   } catch (error) {
  //     print('Error  : $error');
  //     // Indicate network or other errors
  //   }
  // }



  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => Home(userId: widget.userId, token: widget.token),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: FutureBuilder<List<dynamic>>(
            future: Future.value(adminData), // Pass the adminData list directly
            builder: (context, snapshot) {
              if (isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final admin = snapshot.data![0];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('asset/icon/user.png'), // Placeholder image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
              Center(
              child: Text(
              'Email : ${admin['email']}',
              style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              ),
              ),
              ),

                    SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Role : ${admin['role']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                  ],
                );
              }
            },
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Implement logout functionality here


            token = "";

            showSnackBar(context, 'Logout successfully');
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => const SignIn(),
            ));




          },
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontSize: 28), // Adjust the font size as needed
          ),
          child: Text(
            'Logout',
            style: TextStyle(fontSize: 25), // Adjust the font size as needed
          ),
        ),
      ),

    );
  }
}
