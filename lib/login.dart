import 'dart:convert';
import 'package:flutter/material.dart';
import 'donor_info.dart';
import 'package:http/http.dart' as http;
import 'patient_dashboard.dart';
import 'dashboard.dart';
import 'doctor_dashboard.dart';
import 'patient_registeration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class LoginPage extends StatefulWidget {
late String userName;
 late int userId;
 late String userType;
  @override
  
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false; // New variable to track loading state
  bool _showLoadingDialog = false;
  Future<void> _authenticate(String email, String password) async {
    setState(() {
      _isLoading = true;
      _showLoadingDialog = true;
    });
    

    final response = await http.post(
      Uri.parse('https://elifesaver.online/includes/login.inc.php'),
      body: {
        'email': email,
        'password': password,
      },
    );

    setState(() {
      _isLoading = false; 
      _showLoadingDialog = false;// Hide progress indicator
    });

    final jsonData = jsonDecode(response.body);
    if (jsonData['success'] == true) {
      final userType = jsonData['type'];
      final user = jsonData['user'];
      final userName = user[userType + '_name'];
      final int userId = user['id'];
      final btsNumber = user['bts_number'];
      final phoneNumber = user['phone'];
      final city = user['city'];
      final address = user['address'];
      final email = user['email'];
      final password = user['password'];
      final bloodGroup = user['blood_group'];
      final gender = user['gender'];
      print(user);
      print(userType);
      // Authentication was successful
      if (userType == 'patient') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDashboard(
              userId: userId,
              userName: userName,
              userType: userType,
            ),
          ),
        );
      } else if (userType == 'donor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(
              userId: userId,
              userName: userName,
              userType: userType,
              phoneNumber: phoneNumber,
              address: address,
              city: city,
              password: password,
              btsNumber: btsNumber,
              email: email,
              bloodGroup: bloodGroup,
              gender:gender,
            ),
          ),
        );
      } 
    }
    else if (jsonData['success'] == false) {
       if (jsonData['error']== 'Wrong Password'){ // Authentication failed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login failed'),
              content: Text('Invalid email or password'),
              actions: [
                TextButton(
                  onPressed: () { Navigator.pop(context);
                  Navigator.pop(context);},
                  child: Text('OK'),
                ),
              ],
            );
          },
        );}
        else {
          showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login failed'),
              content: Text('Fill all the fields'),
              actions: [
                TextButton(
                  onPressed: () { Navigator.pop(context);
                  Navigator.pop(context);},
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        }

      }
      
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 45,),
              Center(
              child: GestureDetector(
                 onTap: () {
                        
                      },
                child: Image.asset(
                  'assets/e_life_saver.png',
                  height: 120.0,
                 
                ),
              ),
            ),
              Row(
                children: [
                  
            SizedBox(height: 8,),
                  Text(
                    'Login',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              ),
              Row(
                children: [
                  Text(
                    'Welcome back, login to continue',
                    textAlign: TextAlign.left,
                  ),
                ]
              ),
              SizedBox(height: 20,),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Container(
                    padding: EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                hintText: 'Password',
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 150),
                    child: GestureDetector(
                      onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DoctorScanPage()),
                              );
                            },
                      child: Text(
                        'Forgot your password?',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Container(
  child: Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: false, // Prevent dialog dismissal on tap outside
                builder: (BuildContext context) {
                  return Dialog(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SpinKitCircle(
                            color: Colors.red,
                            size: 50.0,
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Loading...',
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              /* Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              ); */
              _authenticate(
                _emailController.text,
                _passwordController.text,
              );
            },
            child: Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
),
          SizedBox(
                    height: 180,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                      ),
                      SizedBox(width: 0.1,),
      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PatientRegisterPage()),
                              );
                            },
                            child: Text(
                              'request for blood',
                              style: TextStyle(color:Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
        // After successful login, navigate to the DonorDashboard and pass the userId and userType
        Navigator.push(
          context,
          MaterialPageRoute(
        builder: (context) => DonorInfoPage(),
          ),
        );
      
                            },
                            child: Text(
                              'become a donor',
                              style: TextStyle(color:Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

