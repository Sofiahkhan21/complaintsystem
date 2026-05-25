import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/screens/auth/user/user_login.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';

import 'package:complaintsystem/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  final role;

  const SignUpPage({required this.role, Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _regController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();


  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool loading = false;
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    return null;
  }

  String? _validatephone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Phone number';
    }
    return null;
  }

   String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    } else if (!value.contains('@')) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  String? _validatedepartment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Select  department';
    }
    return null;
  }
    String? _validaterole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Select  role';
    }
    return null;
  }

  String? _validatefaculty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a faculty';
    }
    return null;
  }

  String? _validatereg(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a Reg No';
    }
    return null;
  }

  String? token;
  void storename() async {
    print(token);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (widget.role == 'Admin') {
      _firestore
          .collection('admin')
          .doc(phoneController.text)
          .get()
          .then((value) async {
        print(
            '${value['username'] + value['phone'] + value['email']} + loginnnnnnnn');
        await prefs.setString('username', value['username']);
        await prefs.setString('phone', value['phone']);
        await prefs.setString('email', value['email']);
        await prefs.setString('token', token.toString());

        // _firestore
        //     .collection('tokens')
        //     .doc(value['username'])
        //     .set({'noti_token': token});
        MyNavigation.pushreplacement(context, AdminDashboard());
        setState(() {});
      });
    } else {
      _firestore
          .collection('Users')
          .doc(phoneController.text)
          .get()
          .then((value) {
        print('${value['username'] + value['phone'] + value['email']}');
        prefs.setString('username', value['username']);
        prefs.setString('phone', value['phone']);
        prefs.setString('email', value['email']);
        prefs.setString('token', token.toString());
        print(token);
        MyNavigation.pushreplacement(
            context,
            UserLogin(
              role: widget.role,
            ));
        setState(() {});
      });
    }
  }

  void storerole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('role', widget.role);
  }

  signup() async {
    FocusManager.instance.primaryFocus!.unfocus();
    setState(() {
      loading = true;
    });
    String response = 'some error occured';
    print(response);
    var snapShot;

    snapShot = await _firestore
        .collection('credentials')
        .doc(emailController.text)
        .get();

    if (!snapShot.exists) {
      print("not exist");
      try {
        print('register');
        UserCredential result = await _auth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: _passwordController.text);
        User? user = result.user;
        print('user');
        print(user!.uid);
        print('///////////////////');

        _firestore.collection('credentials').doc(phoneController.text).set({
          'email': emailController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
          'phone': phoneController.text,
          'image': '',
          'uid': user.uid,
          'department': selectval,
          'regNo': _regController.text,
          'role':teacher=='Teacher'?'Teacher': widget.role,
          'authority': autghority
        });
        response = 'Account Created Successfully';
        String? token = await messaging.getToken();

        setState(() {
          loading = false;
        });
        MyNavigation.pushreplacement(context, UserLogin(role: widget.role));
      } catch (err) {
        final regex = RegExp(r"\[.*?\]");
        final filteredErrorMessage = err.toString().replaceAll(regex, '');
        print(err);
        response = filteredErrorMessage;
        setState(() {
          loading = false;
        });
      }
    } else {
      response = 'Username already exist';
    }
    setState(() {
      loading = false;
    });

    return response;
  }

  // bool isSwitched = false;

  // void toggleSwitch(bool value) {
  //   if (isSwitched == false) {
  //     setState(() {
  //       isSwitched = true;

  //       print(isSwitched);
  //     });
  //   } else {
  //     setState(() {
  //       isSwitched = false;

  //       print(isSwitched);
  //     });
  //   }
  // }

  bool isHiddenPassword = true;
  List type = [];
  getdepartment() async {
    type = [];
    print('hellooooooooooooooooooooooooooooooooo');
    FirebaseFirestore.instance
        .collection("department")
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        print(doc[i]['name']);
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {
        type.add(doc[i]['name']);
        // }
      }
      setState(() {});
    });
    print(type);
    setState(() {});
  }

  String selectval = '';
  String teacher = '';

  // List roleList = ["ADSA", "HOD", "Deen", "Registrar", "VC"];
  String roleval = 'CS';
  getuser() async {
    authoList = [];
    print('hellooooooooooooooooooooooooooooooooo');
    FirebaseFirestore.instance
        .collection("Offices")
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        print(doc[i]['name']);
        if (doc[i]['name'] != 'Investigator') {
          authoList.add(doc[i]['name']);
        }
      }
      setState(() {});
    });
    print(authoList);
    setState(() {});
  }

  List authoList = [];
  String autghority = '';
  @override
  void initState() {
    super.initState();
    getuser();
    getdepartment();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0).w,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 15.h,
              ),
              Center(
                child: Container(
                    height: 130.h,
                    // width: 180.w,
                    child: Image.asset(
                      'assets/logo.png',
                      color: MyColors.blue,
                    )),
              ),

              SizedBox(
                height: 30.h,
              ),
              TextWidget(
                text: 'Create Your Account',
                size: 16.sp,
                fontWeight: FontWeight.bold,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 25.h,
              ),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10).w),
                        filled: true,
                        isDense: true,
                        prefixIcon: Icon(
                          Icons.person,
                        ),
                        fillColor: Colors.grey[200],
                      ),
                      validator: _validateUsername,
                      // maxLength: 20,
                    ),

                    SizedBox(height: widget.role == 'User' ? 15.h : 0),
                     widget.role == 'User'
                        ? Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField(
                                  menuMaxHeight: 300,
                                  validator: _validaterole,
                                  // underline: const SizedBox(),
                                  decoration: const InputDecoration(
                                    alignLabelWithHint: true,
                                    border: InputBorder.none,
                                    errorBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                  ),
                                  hint: Text("Select role"),
                                  isExpanded: true,
                                  items: ['Teacher','Student'].map((map) {
                                    return DropdownMenuItem<String>(
                                        value: map, child: Text(map));
                                  }).toList(),
                                  onChanged: (val) {
                                    teacher = val.toString();
                                    print(teacher);

                                    setState(() {});
                                  }),
                            ),
                          ):Container(),
                           SizedBox(height: widget.role == 'User' ? 15.h : 0),
                    widget.role == 'User' && teacher=='Student'
                        ? TextFormField(
                            keyboardType: TextInputType.text,
                            controller: _regController,
                            decoration: InputDecoration(
                              labelText: 'Reg. No',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10).w),
                              filled: true,
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.account_tree_outlined,
                              ),
                              fillColor: Colors.grey[200],
                            ),
                            validator: _validatereg,
                          )
                        : Container(),
                    SizedBox(height: 15.h),

                    TextFormField(
                      keyboardType: TextInputType.phone,
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone No.',
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10).w),
                        filled: true,
                        isDense: true,
                        prefixIcon: Icon(
                          Icons.phone,
                        ),
                        fillColor: Colors.grey[200],
                      ),
                      validator: _validatephone,
                    ),
                    SizedBox(height: 15.h),

                    TextFormField(
                            keyboardType: TextInputType.text,
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10).w),
                              filled: true,
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.account_tree_outlined,
                              ),
                              fillColor: Colors.grey[200],
                            ),
                            validator: _validateEmail,
                          ),
                    SizedBox(height: 15.h),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _passwordController,
                      obscureText: isHiddenPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10).w),
                        suffixIcon: InkWell(
                            onTap: _togglePasswordView,
                            child: isHiddenPassword
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off)),
                        filled: true,
                        isDense: true,
                        prefixIcon: Icon(Icons.lock),
                        fillColor: Colors.grey[200],
                      ),
                      validator: _validatePassword,
                      // maxLength: 6,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    widget.role == 'User'
                        ? Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField(
                                  menuMaxHeight: 300,
                                  validator: _validatedepartment,
                                  // underline: const SizedBox(),
                                  decoration: const InputDecoration(
                                    alignLabelWithHint: true,
                                    border: InputBorder.none,
                                    errorBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                  ),
                                  hint: Text("Select department"),
                                  isExpanded: true,
                                  items: type.map((map) {
                                    return DropdownMenuItem<String>(
                                        value: map, child: Text(map));
                                  }).toList(),
                                  onChanged: (val) {
                                    selectval = val.toString();
                                    print(selectval);

                                    setState(() {});
                                  }),
                            ),
                          )
                        : widget.role == 'Authority'
                            ? Container(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField(
                                      menuMaxHeight: 300,
                                      validator: _validatefaculty,
                                      // underline: const SizedBox(),
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
                                        border: InputBorder.none,
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                      ),
                                      hint: Text("Select Faculty"),
                                      isExpanded: true,
                                      items: authoList.map((map) {
                                        return DropdownMenuItem<String>(
                                            value: map, child: Text(map));
                                      }).toList(),
                                      onChanged: (val) {
                                        autghority = val.toString();
                                        print(autghority);

                                        setState(() {});
                                      }),
                                ),
                              )
                            : Container(),
                    //         SizedBox(height: 15,),
                    //     Container(
                    //   padding: const EdgeInsets.only(left: 10, right: 10),
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey[200],
                    //      borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: DropdownButtonHideUnderline(
                    //     child: DropdownButtonFormField(
                    //         menuMaxHeight: 300,

                    //         // underline: const SizedBox(),
                    //         decoration: const InputDecoration(
                    //           alignLabelWithHint: true,
                    //           border: InputBorder.none,
                    //           errorBorder: UnderlineInputBorder(
                    //             borderSide: BorderSide(color: Colors.transparent),
                    //           ),
                    //         ),
                    //         hint: Text("Select Office"),
                    //         isExpanded: true,
                    //         items: roleList.map((map) {
                    //           return DropdownMenuItem<String>(
                    //               value: map, child: Text(map));
                    //         }).toList(),
                    //         onChanged: (val) {
                    //           roleval = val.toString();
                    //           print(roleval);

                    //           setState(() {});
                    //         }),
                    //   ),
                    // ),
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
                    //       activeColor: Colors.green,
                    //       activeTrackColor: Colors.grey[200],
                    //       inactiveThumbColor: Colors.grey,
                    //       inactiveTrackColor: Colors.grey[200],
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 20.h),
                    Container(
                      height: 40.h,
                      width: 300.w,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 1, 49, 88),
                        borderRadius: BorderRadius.circular(15).w,
                      ),
                      child: TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            FocusManager.instance.primaryFocus!.unfocus();

                            String res = await signup();
                            print(res);
                            if (context.mounted &&
                                res == 'Account Created Successfully') {
                              showSnackBar(
                                  res, context, Color.fromARGB(255, 1, 49, 88));
                              storerole();
                              storename();
                            } else {
                              showSnackBar(res, context, Colors.red);
                            }
                          }
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 1, 49, 88),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    text: 'Already have account? ',
                    fontWeight: FontWeight.bold,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color.fromARGB(255, 2, 64, 114)))),
                    child: GestureDetector(
                      onTap: () {
                        MyNavigation.pushRemove(
                            context,
                            UserLogin(
                              role: widget.role,
                            ));
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp,
                            color: Color.fromARGB(255, 1, 49, 88)),
                      ),
                    ),
                  ),
                ],
              )
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 120),
              //   child: Text(
              //     'Or Sign Up With',
              //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              //   ),
              // ),
              // SizedBox(
              //   height: 20,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Card(
              //       child: Container(
              //         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              //         height: 60,
              //         width: 60,
              //         child: Image.asset(
              //           'assets/google.png',
              //         ),
              //       ),
              //     ),
              //     Card(
              //       child: Container(
              //         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              //         height: 60,
              //         width: 60,
              //         child: Image.asset(
              //           'assets/facebook.png',
              //         ),
              //       ),
              //     ),
              //     Card(
              //       child: Container(
              //         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              //         height: 60,
              //         width: 60,
              //         child: Image.asset(
              //           'assets/twitter.png',
              //         ),
              //       ),
              //     )
              //   ],
              // ),
            ]),
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
// // ignore_for_file: prefer_const_constructors

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:complaint_app/components/navigation.dart';
// import 'package:complaint_app/components/text_widget.dart';
// import 'package:complaint_app/login.dart';
// import 'package:complaint_app/utils.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class SignUpPage extends StatefulWidget {
//   const SignUpPage({Key? key}) : super(key: key);

//   @override
//   State<SignUpPage> createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   bool isHiddenPassword = true;
//   bool loading = false;
//   String? _validateUsername(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter a username';
//     }
//     return null;
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter an email address';
//     } else if (!value.contains('@')) {
//       return 'Invalid email format';
//     }
//     return null;
//   }

//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter a password';
//     }
//     return null;
//   }

//   signup() async {
//     FocusManager.instance.primaryFocus!.unfocus();
//     setState(() {
//       loading = true;
//     });
//     String response = 'some error occured';
//     print(response);
//     final snapShot = await _firestore
//         .collection('Users')
//         .doc(_usernameController.text)
//         .get();

//     if (!snapShot.exists) {
//       print("not exist");
//       try {
//         print('register');
//         await _auth.createUserWithEmailAndPassword(
//             email: _emailController.text, password: _passwordController.text);
//             if(isSwitched){
//            _firestore.collection('admin').doc(_usernameController.text).set({
//           'email': _emailController.text,
//           'username': _usernameController.text,
//           'password': _passwordController.text,
//         });
//         response = 'Account Created Successfully';
//         String? token = await messaging.getToken();

//         _firestore
//             .collection('tokens')
//             .doc(_usernameController.text)
//             .set({'noti_token': token});

//             }else{
//                _firestore.collection('Users').doc(_usernameController.text).set({
//           'email': _emailController.text,
//           'username': _usernameController.text,
//           'password': _passwordController.text,
//         });
//         response = 'Account Created Successfully';

//             }

//       } catch (err) {
//         response = 'Email is already used in another account';
//       }
//     } else {
//       response = 'Username already exist';
//     }
//     setState(() {
//       loading = false;
//     });

//     return response;
//   }

//   bool isSwitched = false;

//   void toggleSwitch(bool value) {
//     if (isSwitched == false) {
//       setState(() {
//         isSwitched = true;

//         print(isSwitched);
//       });
//     } else {
//       setState(() {
//         isSwitched = false;

//         print(isSwitched);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.green[400],
//         title: Text(
//           'Sign Up',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Form(
//             key: _formKey,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: InputDecoration(
//                       labelText: 'Username',
//                       filled: true,
//                       isDense: true,
//                       prefixIcon: Icon(
//                         Icons.person,
//                       ),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15))),
//                   validator: _validateUsername,
//                   maxLength: 15,
//                 ),
//                 SizedBox(height: 10),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: InputDecoration(
//                       labelText: 'Email',
//                       filled: true,
//                       isDense: true,
//                       prefixIcon: Icon(
//                         Icons.email,
//                       ),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15))),
//                   validator: _validateEmail,
//                 ),
//                 SizedBox(height: 24),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: isHiddenPassword,
//                   decoration: InputDecoration(

//                       labelText: 'Password',
//                       suffixIcon: InkWell(
//                           onTap: _togglePasswordView,
//                           child: isHiddenPassword
//                               ? Icon(Icons.visibility)
//                               : Icon(Icons.visibility_off)),
//                       filled: true,
//                       isDense: true,
//                       prefixIcon: Icon(Icons.lock),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15))),
//                   validator: _validatePassword,
//                   maxLength: 6,
//                 ),
//                 SizedBox(height: 20),
//                 Row(
//                   children: [
//                     const TextWidget(
//                       textcolor: Colors.black,
//                       text: 'Admin ',
//                       size: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     Switch(
//                       onChanged: toggleSwitch,
//                       value: isSwitched,
//                       activeColor: Colors.green,
//                       activeTrackColor: Colors.grey[200],
//                       inactiveThumbColor: Colors.grey,
//                       inactiveTrackColor: Colors.grey[200],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 40),
//                 Container(
//                   height: 40,
//                   width: 100,
//                   decoration: BoxDecoration(
//                       color: Colors.green[400],
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.grey.withOpacity(0.8),
//                             spreadRadius: 3,
//                             blurRadius: 5)
//                       ]),
//                   child: TextButton(
//                     onPressed: () async {
//                       print('wwwwww');
//                       // if (_formKey.currentState!.validate()) {
//                       //   // Validation passed, you can proceed with sign-up logic.
//                       //   print('Username: ${_usernameController.text}');
//                       //   print('Email: ${_emailController.text}');
//                       //   print('Password: ${_passwordController.text}');
//                       // } else {
//                       String res = await signup();
//                       print(res);
//                       if (context.mounted &&
//                           res == 'Account Created Successfully') {
//                         showSnackBar(res, context,Colors.green);
//                         MyNavigation.pushreplacement(context, const Login());
//                       } else {
//                         showSnackBar(res, context,Colors.red);
//                       }
//                       // }
//                     },
//                     child: Text(
//                       'Sign Up',
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: 15,
//                 ),
//                 loading
//                     ? Center(
//                         child: CircularProgressIndicator(
//                           color: Colors.green,
//                         ),
//                       )
//                     : Container()
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _togglePasswordView() {
//     if (isHiddenPassword == true) {
//       isHiddenPassword = false;
//     } else {
//       isHiddenPassword = true;
//     }
//     setState(() {});
//   }
// }
