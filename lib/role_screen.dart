
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/screens/auth/user/user_login.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 150.h,
            //  width: 360.w,
              child: Center(
                  child: Image.asset(
                'assets/logo.png',color:MyColors.blue
              )),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 20).w),
          Text(
            '',
            style: TextStyle(
                color: const Color.fromARGB(255, 1, 64, 116),
                fontWeight: FontWeight.w700,
                fontSize: 20.sp),
          ),
          SizedBox(
            height: 20.h,
          ),
          Container(
            height: 40.h,
            width: 230.w,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 64, 116),
                borderRadius: BorderRadius.circular(15).w),
            child: TextButton(
                onPressed: () async {
           
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserLogin(role: 'Admin')));
                },
                child: Title(
                    color: Colors.black,
                    child: Text(
                      'Admin',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 19.sp,
                        color: Colors.white,
                      ),
                    ))),
          ),
          SizedBox(
            height: 20.h,
          ),
           Container(
            height: 40.h,
            width: 230.w,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 64, 116),
                borderRadius: BorderRadius.circular(15).w),
            child: TextButton(
                onPressed: () async {
                 // final SharedPreferences prefs =
                  //     await SharedPreferences.getInstance();
                  // await prefs.setBool('rolescreen', true);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserLogin(role: 'Authority')));
                },
                child: Title(
                    color: Colors.black,
                    child: Text(
                      'Authority',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 19.sp,
                        color: Colors.white,
                      ),
                    ))),
          ),
          SizedBox(
            height: 20.h,
          ),
          Container(
            height: 40.h,
            width: 230.w,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 64, 116),
                borderRadius: BorderRadius.circular(15).w),
            child: TextButton(
                onPressed: () async {
             
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserLogin(role: 'Investigator')));
                },
                child: Title(
                    color: Colors.black,
                    child: Text(
                      'Investigator',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 19.sp,
                        color: Colors.white,
                      ),
                    ))),
          ),
             SizedBox(
            height: 20.h,
          ),
          Container(
            height: 40.h,
            width: 230.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 64, 116),
                borderRadius: BorderRadius.circular(15).w),
            child: TextButton(
                onPressed: () async {
              
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserLogin(role: 'User')));
                },
                child: Title(
                    color: Colors.black,
                    child: Text(
                      'Complainer',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 19.sp,
                        color: Colors.white,
                      ),
                    ))),
          ),
        ],
      ),
    );
  }
}
