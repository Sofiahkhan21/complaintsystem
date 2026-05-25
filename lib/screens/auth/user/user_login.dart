import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/role_screen.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/screens/auth/forgot_password.dart';
import 'package:complaintsystem/screens/auth/user/user_signup.dart';
import 'package:complaintsystem/screens/authority/authority_home.dart';
import 'package:complaintsystem/screens/investigator/investigator_home.dart';
import 'package:complaintsystem/screens/teacher/teacher_home.dart';
import 'package:complaintsystem/screens/users/complaint_dashbord.dart';

import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';

import 'package:complaintsystem/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';

class UserLogin extends StatefulWidget {
  final  role;

  const UserLogin({required this.role, Key? key}) : super(key: key);

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  bool loading = false;
  String? getemail;
  String? name;
  String? token;
  // void storename() async {
  //   print(token);
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (widget.role=='Admin') {
  //     _firestore
  //         .collection('admin')
  //         .doc(phoneController.text)
  //         .get()
  //         .then((value) async {
  //       print(
  //           '${value['username'] + value['phone'] + value['email']} + loginnnnnnnn');
  //       await prefs.setString('username', value['username']);
  //       await prefs.setString('phone', value['phone']);
  //       await prefs.setString('email', value['email']);
  //       await prefs.setString('token', token.toString());

  //       _firestore
  //           .collection('tokens')
  //           .doc(value['username'])
  //           .set({'noti_token': token});
  //       MyNavigation.pushreplacement(context, AdminDashboard());
  //       setState(() {});
  //     });
  //   } else {
  //     _firestore
  //         .collection('Users')
  //         .doc(phoneController.text)
  //         .get()
  //         .then((value) {
  //       print('${value['username'] + value['phone'] + value['email']}');
  //       prefs.setString('username', value['username']);
  //       prefs.setString('phone', value['phone']);
  //       prefs.setString('email', value['email']);
  //       prefs.setString('token', token.toString());
  //       print(token);
  //       //  MyNavigation.pushreplacement(context, HarassementPage());
  //       setState(() {});
  //     });
  //   }
  // }

 

  login() async {
    setState(() {
      loading = true;
    });
     final SharedPreferences prefs = await SharedPreferences.getInstance();
     final snapShot;
      snapShot =
          await _firestore.collection('credentials').doc(phoneController.text).get();
          if (snapShot.exists) {
             await _firestore
            .collection('credentials')
            .doc(phoneController.text)
            .get()
            .then((value) {
          getemail = value['email'];
        });
          }

    try {
      print("${widget.role} >>>>>>>>>>>>>>>>>>");
      await _auth.signInWithEmailAndPassword(
          email: '$getemail'.trim(),
          password: _passwordController.text.trim());
     
         String? token = await messaging.getToken();
         _firestore
            .collection('tokens')
            .doc(phoneController.text.trim())
            .set({'noti_token': token});
       await  _firestore
          .collection('credentials')
          .doc(phoneController.text.trim())
          .get()
          .then((value) {
        print('${value['username'] + value['phone'] + value['email']}');
        prefs.setString('username', value['username']);
        prefs.setString('role','${ value['role']}');
        prefs.setString('phone','${value['phone']}');
        prefs.setString('email','${value['email']}' );
        prefs.setString('uid','${value['uid']}' );
        prefs.setString('authority','${value['authority']}' );


         prefs.setString('regNo','${value['regNo']}' );
         prefs.setString('department','${value['department']}'  );
      prefs.setString('token','${token}');
            
            if(widget.role=='Authority'){
               _firestore
            .collection('Comlaint_tokens')
            .doc(value['authority'])
            .set({'noti_token': token.toString(),"phone":value['phone'],'role': value['role'],'uid': value['uid'],'authority': value['authority']});

            }
             
        print("token");
        print(value['role']);
        loading=false;
           setState(() {});
           if(widget.role=='Admin' && value['role']=='Admin'){
             
       MyNavigation.pushreplacement(context, AdminDashboard());


           }else if(widget.role=='User' && value['role']=='User'){
        MyNavigation.pushreplacement(context, Complaint());


           }else if(widget.role=='Authority' && value['role']=='Authority'){
        MyNavigation.pushreplacement(context, AuthorityHome());


           }else if(widget.role=='Investigator' && value['role']=='Investigator'){
        MyNavigation.pushreplacement(context, InvestigatorHome());


           }else if(widget.role=='User' && value['role']=='Teacher'){
        MyNavigation.pushreplacement(context, TeacherHome());


           }
           else{
             showSnackBar( 'Not Found in ${widget.role} List',context, MyColors.red);
            
           }
    
      });

      
        
  
    } catch (err) {
    
      final regex = RegExp(r"\[.*?\]");
      final filteredErrorMessage = err.toString().replaceAll(regex, '');
      print(err);
     setState(() {
        loading = false;
      });
      //  res= filteredErrorMessage;
      showSnackBar(filteredErrorMessage, context, Colors.red);
    }
  }

  bool isSwitched = false;

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;

        print(isSwitched);
      });
    } else {
      setState(() {
        isSwitched = false;

        print(isSwitched);
      });
    }
  }

  @override
  void initState() {
    super.initState();
  // gettoken();
  }

  // @override
  // void dispose() {
  //   _passwordController.clear();
  //   phoneController.clear();
  // }

  bool isHiddenPassword = true;
  Future<void> sendPasswordResetOtp(String email) async {
    print(email);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset OTP sent to $email');
    } catch (e) {
      print('Error sending password reset OTP: $e');
      // Handle the error
    }
  }

  Future<void> confirmPasswordReset(
      String resetCode, String newPassword) async {
    try {
      await FirebaseAuth.instance.verifyPasswordResetCode(resetCode);
      // The reset code is valid, proceed to set the new password
      await FirebaseAuth.instance.confirmPasswordReset(
        code: resetCode,
        newPassword: newPassword,
      );
      print('Password reset successful');
    } catch (e) {
      print('Error confirming password reset: $e');
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0).w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Center(
                  child: Container(
                    height: 130.h,
                    width: 200.w,
                    child: Image.asset('assets/logo.png',color:MyColors.blue),
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                Text(
                  'Login to your Account',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone No.',
                          filled: true,
                          isDense: true,
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15).w,
                          ),
                          fillColor: Colors
                              .grey[200], // Set the fill color to transparent
                        ),
                        validator: _validateUsername,
                        // maxLength: 20,
                      ),
                      SizedBox(height: 20.h),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordController,
                        obscureText: isHiddenPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: InkWell(
                              onTap: _togglePasswordView,
                              child: isHiddenPassword
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off)),
                          filled: true,
                          isDense: true,
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(15).w),
                          fillColor: Colors
                              .grey[200], // Set the fill color to transparent
                        ),
                        validator: _validatePassword,
                      ),
                      // Row(
                      //   children: [
                      //     const TextWidget(
                      //       textcolor: Colors.black,
                      //       text: 'Admin ',
                      //       size: 18,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //     Switch(
                      //       onChanged: toggleSwitch,
                      //       value: isSwitched,
                      //       activeColor: Colors.blue,
                      //       activeTrackColor: Colors.grey[200],
                      //       inactiveThumbColor: Colors.grey,
                      //       inactiveTrackColor: Colors.grey[200],
                      //     ),
                      //   ],
                      // ),
                      SizedBox(height: 10.h),

                      GestureDetector(
                        onTap: () {
                          MyNavigation.push(context, ForgotPassword());
                          //sendPasswordResetOtp('khadijaxtreme103@gmail.com');
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('Forgot Password?')),
                      ),
                      SizedBox(height: 20.h),

                      loading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 1, 49, 88),
                              ),
                            )
                          : Container(
                              height: 40.h,
                              width: 300.w,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 2, 64, 114),
                                borderRadius: BorderRadius.circular(15).w,
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    FocusManager.instance.primaryFocus!
                                        .unfocus();
                                    login();
                                  }
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                     // SizedBox(height: 20.h),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10).w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text(
                            //   'Or Sign In With',
                            //   style: TextStyle(
                            //       fontSize: 15.sp, fontWeight: FontWeight.bold),
                            // ),
                            // SizedBox(width: 20.w),
                            // GestureDetector(
                            //   onTap: () {},
                            //   child: Card(
                            //     child: Container(
                            //       // padding: EdgeInsets.symmetric(
                            //       //     vertical: 10, horizontal: 15),
                            //       height: 30.h,
                            //       width: 30.w,
                            //       child: Image.asset(
                            //         'assets/google.png',
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // Card(
                            //   child: Container(
                            //     padding: EdgeInsets.symmetric(
                            //         vertical: 10, horizontal: 15),
                            //     height: 60,
                            //     width: 60,
                            //     child: Image.asset(
                            //       'assets/facebook.png',
                            //     ),
                            //   ),
                            // ),
                            // Card(
                            //   child: Container(
                            //     padding: EdgeInsets.symmetric(
                            //         vertical: 10, horizontal: 15),
                            //     height: 60,
                            //     width: 60,
                            //     child: Image.asset(
                            //       'assets/twitter.png',
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an Account ?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage(
                                          role: widget.role,
                                        )),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 2, 64, 114),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _togglePasswordView() {
    if (isHiddenPassword == true) {
      isHiddenPassword = false;
    } else {
      isHiddenPassword = true;
    }
    setState(() {});
  }
}
