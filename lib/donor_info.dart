import 'dart:convert';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DonorInfoPage extends StatefulWidget {
  
  @override
  State<DonorInfoPage> createState() => _DonorInfoPageState();
}

class _DonorInfoPageState extends State<DonorInfoPage> {
  bool isMaleActive = true;
  DateTime? selectedDate;
  String bloodGroupValue = 'Select Blood Group';
  String factorValue = 'Select Your city';

  void toggleGender(bool isMale) {
    setState(() {
      isMaleActive = isMale;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _registerUser() async {
  final String name = nameController.text;
  final String email = emailController.text;
  final String phoneNumber = phoneNumberController.text;
  final String password = passwordController.text;
  final String confirmPassword = confirmPasswordController.text;
  final String gender = isMaleActive ? 'Male' : 'Female';
  final String city = cityController.text;
  final String address = addressController.text;
  final String bloodGroup = bloodGroupValue;

  // Validation checks
  if (password != confirmPassword) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration failed'),
          content: Text('Password and confirm password do not match.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    return;
  }
    setState(() {
      _isLoading = true;
      
    });
   final response = await http.post(
    Uri.parse('https://elifesaver.online/includes/registerDonor.inc.php'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'name': name,
      'gender': gender,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'phone': phoneNumber,
      'address': address,
      'city': city,
      'blood_group': bloodGroup,
    },
  );
   setState(() {
      _isLoading = false;
      
    });
   final jsonData = jsonDecode(response.body);
  
    final userType = jsonData['type'];
    final user = jsonData['user'];
    final userName = user[userType + '_name'];
    final int userId = user['id'];
    final btsnumber = user['bts_number'];
    final phonenumber = user['phone'];
    final City = user['city'];
    final  Address = user['address'];
    final Email = user['email'];
    final Password = user['password'];
     SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('registered', true);
      prefs.setInt('userId', userId);
      prefs.setString('userName', userName);
      prefs.setString('userType', userType);
      prefs.setString('phoneNumber', phonenumber);
      prefs.setString('address', Address);
      prefs.setString('city', City);
      prefs.setString('password', Password);
      prefs.setString('btsNumber', btsnumber);
      prefs.setString('email', Email);

    print(user);
    print(jsonData);
  // Check if the response is successful
    // Remove HTML tags from the response body
    final cleanedResponseBody = response.body.replaceAll(RegExp(r'<[^>]*>'), '');
    print(jsonData['success']);
     
    try {
      // Parse the cleaned response body as JSON
      final jsonData = jsonDecode(cleanedResponseBody);

      if (jsonData['success'] == true) {
        // Registration successful
        // Navigate to the dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard(userId: userId, userName: userName, userType: userType, phoneNumber: phonenumber, address: Address, city: City, password: Password, btsNumber: btsnumber, email: Email, bloodGroup: bloodGroup, gender:gender)),
        );
      } else if(jsonData['success'] == false){
        // Registration failed, display the error message
        String errorMessage = jsonData['error'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registration failed'),
              content: Text(''),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Error occurred while decoding JSON or accessing data
      print('Error decoding JSON or accessing data: $e');
    }
  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Donor Information', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/blood_appeal.png',
                  height: 150.0,
                ),
              ),
              SizedBox(height: 16),
              Container(
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
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Name',
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              // Email TextField
              SizedBox(height: 16),
              Container(
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
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              // Password TextField
              
              // Phone Number TextField
              SizedBox(height: 16),
              Container(
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
                child: TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              // City TextField
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(6),
                width:325,
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
  child: DropdownButton<String>(
    value: factorValue,
    iconSize: 24,
    elevation: 16,
    underline: Container(
          height: 2,
          color: Colors.white,
        ),
    onChanged: (String? newValue) {
      setState(() {
        factorValue = newValue!;
        print(factorValue);
      });
    },
    items: <String>[
      'Select Your city',
      'Bamenda',
      'Limbe',
      'Buea',
      'Bafoussam'
    ].map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
        
      );
    }).toList(),
  ),
),
              // Address TextField
              SizedBox(height: 16),
              Container(
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
                child: TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'Address',
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    'Gender',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => toggleGender(true),
                    child: CircleAvatar(
                      backgroundColor: isMaleActive ? Colors.red : Colors.grey,
                      radius: 10,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Male',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => toggleGender(false),
                    child: CircleAvatar(
                      backgroundColor: !isMaleActive ? Colors.red : Colors.grey,
                      radius: 10,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Female',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.all(8),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      selectedDate == null
                          ? Text(
                              'Date of Birth',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Text(
                              '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: TextStyle(fontSize: 16),
                            ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: 350,
                padding: EdgeInsets.all(8),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: bloodGroupValue,
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(
          height: 2,
          color: Colors.white,
        ),
                      onChanged: (String? newValue) {
                        setState(() {
                          bloodGroupValue = newValue!;
                        });
                      },
                      items: <String>[
                        'Select Blood Group',
                        'A+',
                        'B+',
                        'O+',
                        'AB+',
                        'A-',
                        'B-',
                        'O-',
                        'AB-',
                        'None'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
               Container(
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
              child: TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    child: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.red,
                    ),
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
            ),
            SizedBox(height: 16),
            Container(
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
              child: TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    child: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.red,
                    ),
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
              ),
            ),
            SizedBox(height: 16,),
              Container(
                child: _isLoading
      ? Center(
          child: CircularProgressIndicator(
            strokeWidth: 0.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            value: 50,
          ),
        )
      : Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: () async {
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
                     if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNumberController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Fields Required'),
            content: Text('Please fill in all the fields.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );}
      else if (passwordController.text != confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Password Mismatch'),
            content: Text('Password and Confirm Password do not match.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      ;
    }
      else {
       await _registerUser(); 
      }
    }
                   ,
                  child: Text(
                    'Finish',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          )],
          ),
        ),
      ),
    );
  }
}



    

    
  
