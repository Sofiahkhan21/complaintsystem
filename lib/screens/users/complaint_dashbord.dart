// import 'package:flutter/material.dart';

// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:complaintsystem/role_screen.dart';
import 'package:complaintsystem/screens/admin/complainant.dart';
import 'package:complaintsystem/screens/auth/user/user_login.dart';
import 'package:complaintsystem/screens/users/criminal_complaint.dart';
import 'package:complaintsystem/screens/users/missing_child.dart';
import 'package:complaintsystem/screens/users/notifications.dart';
import 'package:complaintsystem/screens/users/profile.dart';
import 'package:complaintsystem/screens/users/reminder_notification.dart';
import 'package:complaintsystem/screens/users/report_missing_childs.dart';
import 'package:complaintsystem/screens/users/user_complaints.dart';
import 'package:complaintsystem/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Complaint extends StatefulWidget {
  const Complaint({super.key});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  NotifcationHelper notifcationHelper = NotifcationHelper();
  SharedPreferences? getPrefs;
  final List<ComplaintCategory> categories = [
    ComplaintCategory(
      name: 'Add Complaint',
      icon: Icons.block,
    ),
    ComplaintCategory(
      name: 'view Complaints',
      icon: Icons.security,
    ),
    // ComplaintCategory(
    //   name: 'Report Missing Childs',
    //   icon: Icons.person_search,
    // ),
    // ComplaintCategory(
    //   name: 'Missing Childs',
    //   icon: Icons.family_restroom,
    // ),
    // ComplaintCategory(
    //   name: 'Drug Complaints',
    //   icon: Icons.local_pharmacy,
    // ),
    // ComplaintCategory(
    //   name: 'Cybercrimes',
    //   icon: Icons.sentiment_very_dissatisfied,
    // ),
  ];


  @override
  void initState() {
    super.initState();
    getunreadNote();
    getUid();

    notifcationHelper.requestNotificatinPermission();
    notifcationHelper.firebasemegs(context);
    notifcationHelper.terminatedandback(context);
   // getcomplaintList();
  }

  String? username;
  String? role;
  String? office;
  String? phone;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    office = prefs.getString('office');
    phone = prefs.getString('phone');

    setState(() {});
    getuserList();
  }

  void signOut() async {
    // bool role;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await FirebaseAuth.instance.signOut();
    await prefs.remove('username');
    await prefs.remove('phone');
   
    MyNavigation.pushRemove(
      context,
      RoleScreen(),
    );
  }

  

  var token;

  getuserList() {
    print(phone);
    FirebaseFirestore.instance
        .collection("tokens")
        .doc(phone)
        .get()
        .then((value) async {
      print(value['noti_token']);
      token = value['noti_token'];
    });

    setState(() {});
  }

  var remlength;
  List countList = [];
  getunreadNote() async {
    countList = [];
    // await _firestore.collection('reminder').where('name',isEqualTo: username).where('read',isEqualTo: false).get();

    final collectionReference = await FirebaseFirestore.instance
        .collection('reminder')
        .where('contact', isEqualTo: phone)
        .where('read', isEqualTo: false);

    QuerySnapshot personsSnapshot = await collectionReference.get();
    for (var i = 0; i < personsSnapshot.docs.length; i++) {
     
      if (personsSnapshot.docs[i]['contact'] == phone) {
      countList.add(personsSnapshot.docs[i]);
      }
    }

   remlength = countList.length;
    setState(() {});



   
    setState(() {});
    print(remlength);
  }

  @override
  Widget build(BuildContext context) {
    print(role);
    print(username);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue,
        centerTitle: false,
        title: GestureDetector(
          onTap: () {
         

            /// getcomplaintList();
            // notifcationHelper.scheduleNotification(0, 'Reminder', DateTime.now());
          },
          child: Container(
            child: TextWidget(
              text: '$username',
              textcolor: MyColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextWidget(
            text: '${CusDateFormat.getdday(DateTime.now())}',
            textcolor: MyColors.white,
            size: 13,
          ),
          SizedBox(
            width: 15,
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      // backgroundColor: Colors.green[100],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              child: Center(
                child: Text(
                  'Complaint App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.announcement,
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              title: Text(
                'Complaint',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                MyNavigation.push(context, UserComplaint());
              },
            ),
            ListTile(
              leading: Icon(
                Icons.notifications,
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              title: Text('Notifications',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                MyNavigation.push(
                    context,
                    Notifications(
                      username: username,
                    ));
              },
            ),
            // ListTile(
            //     leading: Icon(
            //       Icons.history,
            //       color: Color.fromARGB(255, 2, 64, 114),
            //     ),
            //     title: Text('Reminder',
            //         style: TextStyle(
            //             fontWeight: FontWeight.bold, color: Colors.black)),
            //     onTap: () {
            //       MyNavigation.push(context, ReminderNotification());
            //     },
            //     trailing: Container(
            //       padding: EdgeInsets.all(5),
            //       decoration: BoxDecoration(
            //           color: remlength == 0 ? Colors.transparent : Colors.red,
            //           shape: BoxShape.circle),
            //       child: remlength == 0 || remlength==null
            //           ? Text('')
            //           : TextWidget(
            //               text: '$remlength',
            //               textcolor: Colors.white,
            //             ),
            //     )),
            ListTile(
              leading: Icon(
                Icons.person,
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              title: Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                MyNavigation.push(
                    context,
                    UserProfile(
                      log: 'Users',
                    ));
              },
            ),
            // ListTile(
            //   title: Text('Reminder Notification'),
            //   onTap: () {MyNavigation.push(context, ReminderNotification());},
            // ),
            // ListTile(
            //   title: Text('live Call'),
            //   onTap: () {},
            // ),
            // ListTile(
            //   title: Text('Add Complaint'),
            //   onTap: () {},
            // ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              title:
                  Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                signOut();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            //  color: Color.fromARGB(255, 2, 64, 114),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Card(
                        elevation: 3.0,
                        child: InkWell(
                          onTap: () {
                            if (index == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CriminalComplaint(
                                    role: 'User',
                                  ),
                                ),
                              );
                            } else if (index == 1) {
                              MyNavigation.push(context, UserComplaint());
                            } else {
                              print('Selected category: ${category.name}');
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category.icon,
                                size: 40.0,
                                color: MyColors.blue,
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // ElevatedButton(
              //   onPressed: () {
              //     signOut();
              //   },
              //   child: Text('Logout'),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

class ComplaintCategory {
  final String name;
  final IconData icon;

  ComplaintCategory({required this.name, required this.icon});
}
