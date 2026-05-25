import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/role_screen.dart';
import 'package:complaintsystem/screens/authority/authority_complaint.dart';
import 'package:complaintsystem/screens/investigator/add_meeting.dart';
import 'package:complaintsystem/screens/investigator/anouncements.dart';
import 'package:complaintsystem/screens/investigator/investigator_complaints.dart';
import 'package:complaintsystem/screens/investigator/meetings.dart';
import 'package:complaintsystem/screens/users/profile.dart';
import 'package:complaintsystem/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
class InvestigatorHome extends StatefulWidget {
  const InvestigatorHome({super.key});

  @override
  State<InvestigatorHome> createState() => _InvestigatorHomeState();
}

class _InvestigatorHomeState extends State<InvestigatorHome> {
    final FirebaseAuth _auth = FirebaseAuth.instance;
  NotifcationHelper notifcationHelper = NotifcationHelper();
    Future<bool> handleLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return false;
  }

  return true;
}
  @override
  void initState() {
    super.initState();
    getUid();
  //  handleLocationPermission();
    notifcationHelper.requestNotificatinPermission();
    notifcationHelper.firebasemegs(context);
    notifcationHelper.terminatedandback(context);
  
  }

  String? username;
  String? role;
  String? office;
  String? authority;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    office = prefs.getString('office');
    authority = prefs.getString('authority');

    setState(() {});

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: MyColors.blue,
        centerTitle: false,
        title: GestureDetector(
          onTap: () {
        
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
          MyNavigation.push(context, InvestigatorComplaints());
              },
            ),

            ListTile(
              leading: Icon(
                Icons.meeting_room_outlined,
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              title:
                  Text('Meetings', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                MyNavigation.push(context, Meetings());
              },
              // onTap: () {
              //   getphoneList();
              // },
            ),
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

      body: SingleChildScrollView(
  child: Container(
    padding: EdgeInsets.all(15),
    child: Column(
      children: [
        TextWidget(alignment: Alignment.center,    text: '$role',
              textcolor: MyColors.blue,size: 22,letterspacing: 1.2,
              fontWeight: FontWeight.bold,),
        SizedBox(height: 20,),
     
           cardcont(text:'Complaints',icon: Icons.comment, onTab: () {
                 MyNavigation.push(context, InvestigatorComplaints()); }),
                cardcont(text:'Meetings',icon: Icons.merge_type, onTab: () {
                
                 MyNavigation.push(context, Meetings());
                  }),
            
      ],
    ),
  )

    ));
  }
   cardcont({text, icon, Function? onTab}) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          height: 90,
         width: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MyColors.blue,
                const Color.fromARGB(255, 72, 173, 236)
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: GestureDetector(
            onTap: () => onTab!(),
            child: Center(
              child: ListTile(
                leading: Icon(
                  icon,
                  color: Colors.white,
                ),
                title: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // trailing: Icon(
                //   Icons.arrow_forward_ios_outlined,
                //   color: Colors.white,
                // ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}