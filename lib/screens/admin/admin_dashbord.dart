import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/button_widget.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:complaintsystem/role_screen.dart';
import 'package:complaintsystem/screens/admin/admin_notification.dart';
import 'package:complaintsystem/screens/admin/category/add_category.dart';
import 'package:complaintsystem/screens/admin/category/department.dart';
import 'package:complaintsystem/screens/admin/category/offices.dart';
import 'package:complaintsystem/screens/admin/category/trained_dataList.dart';
import 'package:complaintsystem/screens/admin/send_notification.dart';

import 'package:complaintsystem/screens/admin/complainant.dart';
import 'package:complaintsystem/screens/admin/complaints.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';

import 'package:complaintsystem/screens/users/profile.dart';
import 'package:complaintsystem/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  final id;
  final name;

  AdminDashboard({Key? key, this.id, this.name}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  NotifcationHelper notifcationHelper = NotifcationHelper();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<Position>? locationSubscription;
  StreamSubscription<Position>? rideruserSubscription;
  late Map<Permission, PermissionStatus> statuses;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('location');
  DocumentReference? document;

  String? username;
  String? role;
  String? adminrole;
  String? policestation;
  String? phone;
  bool islcoation = false;
  double? latitude;
  double? longitude;
  double? ridlatitude;
  double? ridlongitude;

  getUid() async {
    SharedPreferences getPrefs = await SharedPreferences.getInstance();
    username = await getPrefs.getString('username');
    role = await getPrefs.getString('role');
    adminrole = await getPrefs.getString('adminrole');
    policestation = await getPrefs.getString('station');
    phone = await getPrefs.getString('phone');

    setState(() {});
    startLocationUpdates();
  }

  startLocationUpdates() {
    Permission.location.serviceStatus.isEnabled;
    Permission.location.request().then((PermissionStatus status) {
      if (status.isGranted) {
        getLocation();

        // });
      } else {
        print('Permission to access location denied.');
      }
    });
  }

  getLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        print("this is latitude $latitude");
        print("this is longitude $longitude");
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getUid();
    getFaculty();
    startLocationUpdates();
    islcoation = widget.name != null ? true : false;
    notifcationHelper.requestNotificatinPermission();
    notifcationHelper.firebasemegs(context);
    notifcationHelper.terminatedandback(context);
  }

  void signOut() async {
    // bool role;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // role = (await prefs.getBool('rolescreen'))!;
    // print(role);

    await _auth.signOut();
    // await GoogleSignIn().signOut();

    await FirebaseAuth.instance.signOut();
    await prefs.remove('username');
    await prefs.remove('phone');
   
    setState(() {});

    MyNavigation.pushRemove(context, RoleScreen());
  }

  List type = [
    "CS",
    "Agriculture",
    "Biotech",
  ];

  int indexx = 0;
  String selectval = '';
   getFaculty() async {
    facultyList = [];
    print('hellooooooooooooooooooooooooooooooooo');
    FirebaseFirestore.instance
        .collection("Offices")
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        print(doc[i]['name']);
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {
        facultyList.add(doc[i]['name']);
        // }
      }
      setState(() {});
    });
    print(facultyList);
    setState(() {});
  }

  List facultyList = [];
  String facultyL = '';
  @override
  Widget build(BuildContext context) {
    print('role nnn $role');
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 64, 114),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: GestureDetector(
          onTap: () {
            startLocationUpdates();
          },
          child: TextWidget(
            text: "${username}",
            textcolor: Colors.white,
            letterspacing: 1.0,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         canceltrack();
        //         // Navigator.of(context)
        //         //     .push(MaterialPageRoute(builder: (context) => Messages()));

        //         //  signOut();
        //       },
        //       icon: Icon(
        //         Icons.logout,
        //         color: Colors.white,
        //       ))
        // ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 80.h,
                      color: Colors.white,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Complaint App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            adminrole == 'rider'
                ? Container()
                : ListTile(
                    leading: Icon(Icons.comment),
                    title: Text(
                      'Complainant',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Complainant()),
                      );
                    },
                  ),
            role == 'Admin' || adminrole == 'superadmin'
                ? ListTile(
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
                            log: 'admin',
                          ));
                    },
                  )
                : Container(),
            ListTile(
              leading: Icon(
                Icons.notifications,
              ),
              title: Text(
                'Send Notifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminNotification()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add,
              ),
              title: Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCategory()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add,
              ),
              title: Text(
                'Department',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Department()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add,
              ),
              title: Text(
                'Faculty',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Offices()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.add,
              ),
              title: Text(
                'Trained data List',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainedDatalist()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
              ),
              title: Text(
                'LogOut',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                signOut();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0).w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  ButtonWidget(
                    width: 80,
                    height: 30,
                    bgcolor: indexx == 1 ? MyColors.blue : Colors.grey[400],
                    textcolor: indexx == 1 ? MyColors.white : Colors.black,
                    text: 'Student',size: 16,
                    onTab: () {
                      setState(() {
                        indexx = 1;
                        facultyL='';
                      
                      });
                    },
                  ),
                  ButtonWidget(
                     width: 80,
                    height: 30,
                    bgcolor:  indexx == 2 ? MyColors.blue : Colors.grey[400],
                    textcolor: indexx == 2 ? MyColors.white : Colors.black,
                    text: 'Faculty',size: 16,
                  
                    onTab: () {
                      setState(() {
                        indexx = 2;
                        selectval='';
                    
                      });
                    },
                  ),
                   ButtonWidget(
                     width: 70,
                    height: 30,
                    bgcolor:  indexx == 0 ? MyColors.blue : Colors.grey[400],
                    textcolor: indexx == 0 ? MyColors.white : Colors.black,
                    text: 'All',size: 16,
                  
                    onTab: () {
                      print(60.w);
                      setState(() {
                        indexx = 0;
                        selectval='';
                        facultyL='';
                      });
                    },
                  ),
                ],
              ),
                SizedBox(
                height: 10,
              ),
          indexx==1?    Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField(
                      menuMaxHeight: 300,

                      // underline: const SizedBox(),
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      hint: Text("Select department"),
                      isExpanded: true,
                      items: type.map((map) {
                        return DropdownMenuItem<String>(
                            value: map, child: Text(map));
                      }).toList(),
                      onChanged: (val) {
                      //  print(selectval);

                        setState(() {
                        selectval = val.toString();

                        });
                      },value: selectval.isEmpty ? null : selectval),
                ),
              ):indexx==2?Container(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField(
                                      menuMaxHeight: 300,

                                      // underline: const SizedBox(),
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
                                        border: InputBorder.none,
                                        errorBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                      ),
                                      hint: Text("Select dFaculty"),
                                      isExpanded: true,
                                      
                                      items: facultyList.map((map) {
                                        return DropdownMenuItem<String>(
                                            value: map, child: Text(map));
                                      }).toList(),
                                      onChanged: (val) {
                                       // print(facultyL);

                                        setState(() {
                                        facultyL = val.toString();

                                        });
                                      },value: facultyL.isEmpty ? null : facultyL
                                      ),
                                ),
                              ):Container(),
              SizedBox(
                height: 10.h,
              ),

              Container(
                margin: EdgeInsets.only(bottom: 20).w,
                decoration: BoxDecoration(
                    color: Color.fromARGB(220, 2, 64, 114),
                    borderRadius: BorderRadius.circular(10).w),
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 20).w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Complaint status',
                      textcolor: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        contain('Open', role,indexx, ontap:indexx==0?(){}: () {
                          MyNavigation.push(
                              context,
                              AllComplaints(
                                  type: 'Open', department:indexx==1? selectval:facultyL,indexx: indexx,));
                        }),
                        contain('In Process', role, indexx, ontap:indexx==0?(){}: () {
                          MyNavigation.push(
                              context,
                              AllComplaints(
                                type: 'In Process',
                                department: selectval,indexx: indexx
                              ));
                        }),
                        contain('Closed', role, indexx, ontap:indexx==0?(){}: () {
                          MyNavigation.push(
                              context,
                              AllComplaints(
                                type: 'Closed',
                                department: selectval,indexx: indexx
                              ));
                        }),
                      ],
                    ),
                  ],
                ),
              ),

              // Container(
              //   child: TextWidget(
              //     text: "User notifications",
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     MyNavigation.push(context, Messages());
              //   },
              //   child: TextWidget(
              //     text: "Chat",
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  contain(String label, role, station, {Function? ontap}) {
    print(station);
    print(selectval);

    return StreamBuilder<QuerySnapshot>(
      stream:station==1 && selectval!=''? FirebaseFirestore.instance
          .collection('complaint')
          .where('department', isEqualTo: selectval)
          .where('status', isEqualTo: label)
          .snapshots():station==2 && facultyL!=''?FirebaseFirestore.instance
          .collection('complaint')
          
         .where('faculty', isEqualTo: facultyL) .where('status', isEqualTo: label)
          .snapshots():station==0?FirebaseFirestore.instance
          .collection('complaint')
          .where('status', isEqualTo: label)
          .snapshots():FirebaseFirestore.instance
          .collection('complaint')
          .where('statuss', isEqualTo: label)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          String documentLength = documents.length.toString();

          return Card(
            elevation: 15,
            child: GestureDetector(
              onTap: () => ontap!(),
              child: Container(
                height: 60.h,
                width: 100.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10).w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: documentLength,
                      textcolor: Color.fromARGB(255, 2, 64, 114),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    TextWidget(
                      text: label,
                      letterspacing: 1.0,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Text('no data');
      },
    );
  }
}
