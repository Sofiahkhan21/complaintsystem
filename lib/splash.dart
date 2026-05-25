import 'dart:async';
import 'package:complaintsystem/role_screen.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/screens/auth/user/user_login.dart';
import 'package:complaintsystem/screens/authority/authority_home.dart';
import 'package:complaintsystem/screens/investigator/investigator_home.dart';
import 'package:complaintsystem/screens/teacher/teacher_home.dart';
import 'package:complaintsystem/screens/users/complaint_dashbord.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getUid();
    Timer(Duration(seconds: 4), () {
      if (username == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => RoleScreen()

              // MaterialPageRoute(builder: (context) => RoleScreen()
              // MaterialPageRoute(builder: (context) => UserLogin(isSwitched: false)

              // MaterialPageRoute(builder: (context) => RoleScreen()
              // builder: (context) => Login(),
              ),
        );
      } else if (role == 'Admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminDashboard(),
          ),
        );
      } else if (role == 'User') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Complaint(),
          ),
        );
      } else if (role == 'Investigator') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => InvestigatorHome(),
          ),
        );
      }
      else if (role == 'Teacher') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TeacherHome(),
          ),
        );
      }
      else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AuthorityHome(),
          ),
        );
      }
    });
  }

  String? username;
  String? role;
  getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.sizeOf(context).height,
        
       // width: double.infinity,
       
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 120,
               decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/logo.png'), fit: BoxFit.contain)),

            ),
            SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CircularProgressIndicator(color: Colors.black,),
            )
          ],
        ),
      ),
    );
  }
}
