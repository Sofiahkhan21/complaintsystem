import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/role_screen.dart';
import 'package:complaintsystem/screens/authority/authority_complaint.dart';
import 'package:complaintsystem/screens/authority/meetings_detail.dart';
import 'package:complaintsystem/screens/authority/my_complaint.dart';
import 'package:complaintsystem/screens/users/criminal_complaint.dart';
import 'package:complaintsystem/screens/users/notifications.dart';
import 'package:complaintsystem/screens/users/profile.dart';
import 'package:complaintsystem/screens/users/reminder_notification.dart';
import 'package:complaintsystem/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthorityHome extends StatefulWidget {
  final role;
  const AuthorityHome({super.key,this.role});

  @override
  State<AuthorityHome> createState() => _AuthorityHomeState();
}

class _AuthorityHomeState extends State<AuthorityHome> {
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
    getuserList();
    getcomplaintList();
     getunreadNote();
   // handleLocationPermission();
    notifcationHelper.requestNotificatinPermission();
    notifcationHelper.firebasemegs(context);
    notifcationHelper.terminatedandback(context);
  
  }

  String? username;
  String? role;
  String? office;
  String? department;
  String ? authority;
  String ? phone;


final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    office = prefs.getString('office');
    department = prefs.getString('department');
    authority=prefs.getString('authority');
    phone=prefs.getString('phone');


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
  /////
  getcomplaintList() async {
    print("${CusDateFormat.reminderdate(DateTime.now())}");
    final collectionReference = FirebaseFirestore.instance
        .collection('complaint')
        .where('sender', isEqualTo: 'Student');

    QuerySnapshot personsSnapshot = await collectionReference.get();

    List<Map<String, dynamic>> distancesAndPersons = [];

    for (var personDocument in personsSnapshot.docs) {
      Map<String, dynamic> personData =
          personDocument.data() as Map<String, dynamic>;
      print(personDocument.id);
      print(personData['id']);
      print(personData['status']);
      print(personData['reminderDate']);

      if ("${CusDateFormat.getdday(DateTime.now())}" ==
              personData['reminderDate'] &&
          personData['remind'] == false) {
        sendReminder(personData, personDocument.id);
      }
    }
  }

  Future<String> getAccessToken() async {
    print('Strt');
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "compalintsystem",
          "private_key_id": "fbc5cd461175034fafd7fe361ec6db61a99cd735",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDiK4TU21CgVt6J\nUClBymRGeEqqEWbi8DoiBa1nPc+Y9z/MM7rzdKaI3pZAV3V6bdu3vuiwLzHi7Fdv\nM2zLtEGmGSUXAF9tL/+nQabB2t/kxqDhsim4Ku3kwRyXQ3krAhCwj9VCRL/4uITs\n2iMvXmlk/KWqVIAnGJE+JKUvrwUcdgMngnVb8TnzTktueeUVpVMevDyb4tYTyNi+\n3Cxeh3w2LIDhD+bKz1UPpXn2KWDXKYAgmOIAqH22Vk++WSJU5dyYucyt/qYnTYbT\nEsiD0tmIFuorT7/0YwS0j9m7o2udqTbCVgxqrZnplzxLFv2e5DvdO6LCjULRuPz1\n4WFcNlRbAgMBAAECggEAb/cTXzzjgT0AFgI1KnjDg49xhxfuU1KRtN4SphWXfCaK\n0tCZMIUDHKb0ww2I/v770s8T6oSysaBG+KoApieqiEvSbLymgStN6MM7hqSQSnV6\nl8DXnnDCLIjdWpTwmzX+hSnvbUsTrlHKnGaxHHYkvvXEHbqPZstmu9jwXdbLNPbZ\nAeNiUrWN5i9asqXu8pgZQPfg6MlnJcVz5PA/Qz+BjCsfdB5ByDAtmULMSHW4SE9c\nNdVsI3C/IHqAZpCOKpJ7N8Qox5pNYAwjm0fLnChYktWiLwPNwnRMLXB16ZGnKnn9\nid+01umEBcwN1LBYK7ty6bYqjy41mydce5piqQHjgQKBgQDxqe3Im2vWCVRAEBw0\n9wRJKkwXxsVI/u7Bckk455EyFewaHEdCS60gqXn64NMPdH3ZPK/+lRAdCT8OFGmx\nukkueboduSOiTsS9K1NHQ6A/WtGsRyra+Vl6466NP2rWLcQqflWw8boQZODWJfdC\nLTvPNW/h22J9NMna23LUyAWc6wKBgQDvlkpwa5661oZMn4lji78meoE8V0pu0edt\nupEWWEMK0KWPlZ3UU09bHUo5x2UFHY1pTaE6FTwBuk1xD8dRlddO8ZX6TAmHoWo9\nBOyNf0pk8CYdD79KPtkR3civer20711k3If1SQ2VlJ6CazTG/r5Owctneh0xq7ql\n+k+BeUuKUQKBgQC5gfwqNkR9NQQbeUJt1gDQOUvYJJllA207ygMzT29Bx1pKYNLC\nrVzk6bPdRaA/COliTRe8kaig4Wwp3rmT2LA8oOyhzHDyMw0LOarf1aW5fHnfiXH4\nTdjGYOipPLlCWDdxdzFIdwahdw6w1MwNXLPAyABum/3qpw8clcB8Xl8QqQKBgC2t\nus2KRz4aDornU9tt1mjwrFkjz2YnkPcjvevDsiyKsTYZ8Xh81cFqaS9w67q48rAk\nA9w+Fi3CJmeq+XZ9mgpMFysceiioxseRe8RSg42RF8MssGzoZJx6a3vBbA/mHylO\nvoEuh2+AYWQ+KlbSVNhRLIWzC4Pf2PsyKRxnUtaxAoGACN7OSyuk+qX2ddt9CXXR\nUtak0pPlGBnxM80I6VzY/2FeCFx0yJAH0AbR5PN76LX+oVX/1numWgKaAfhWxpw0\nF5DwdLVTykx9V1I1rbHOWcKvPY1Hso2GsvHGtjtuvfTkZc3NpVDeODF0Vzak8K6Z\n3bmJjr/ljLdsLUWxMtke7CE=\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-pjf6m@compalintsystem.iam.gserviceaccount.com",
          "client_id": "105894384221462923758",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-pjf6m%40compalintsystem.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }

  String? accessToken;
  sendReminder(title, id) async {
    print('${title['complaintDetail']}  complaint');

    accessToken = await getAccessToken();
    print('$token ...........................');
    final Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {
          "title": "${title['category']} Reminder",
          "body": 'Complaint ${title['complaintDetail']} not solve yet.'
        },
        "android": {"priority": "HIGH"},
        "apns": {
          "headers": {"apns-priority": "10"},
        },
        'data': {'name': 'reminder', 'id': '2131'}
      },
    };

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/compalintsystem/messages:send'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully!');

      await _firestore.collection('reminder').doc().set({
        "id": "${title['id']}",
        "subject": '${title['subject']}',
        "category": '${title['category']}',
        "complaintDetail": '${title['complaintDetail']}',
        "attachment": '${title['attachment']}',
        "contact": '${title['contact']}',
        "date": '${title['date']}',
        "name": '${title['name']}',
        "address": '${title['address']}',
        "status": '${title['status']}',
        "image": '${title['image']}',
        "priority": '${title['priority']}',
        "reason": "",
        "read": false,
        "department": '${title['department']}',
        "reminderDate": '${title['reminderDate']}'
      });

      await _firestore.collection('complaint').doc(id).update({
        "remind": true,
      });
    } else {
      print(
          'Failed to send notification: ${response.statusCode} ${response.body}');
    }
  }
    var token;

  getuserList() {
    print(phone);
    FirebaseFirestore.instance
        .collection("Comlaint_tokens")
        .doc('$authority')
        .get()
        .then((value) async {
      print(value['noti_token']);
      token = value['noti_token'];
    });
print('$token TOKENNNNNNN');
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    print(authority);
    return Scaffold(
       appBar: AppBar(
        backgroundColor: MyColors.blue,
        centerTitle: false,
        title: GestureDetector(
          onTap: () {
        getuserList();
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
         authority=='VC'?Container():   ListTile(
              leading: Icon(
                Icons.announcement,
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              title: Text(
                'My Complaint',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                MyNavigation.push(context, MyComplaint());
              },
            ),

            ListTile(
              leading: Icon(
                Icons.history,
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              title:
                  Text('Notification', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                MyNavigation.push(context, Notifications(username: authority,));
              },
              // onTap: () {
              //   getphoneList();
              // },
            ),
              ListTile(
                leading: Icon(
                  Icons.history,
                  color: Color.fromARGB(255, 2, 64, 114),
                ),
                title: Text('Reminder',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                onTap: () {
                  MyNavigation.push(context, ReminderNotification());
                },
                trailing: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: remlength == 0 ? Colors.transparent : Colors.red,
                      shape: BoxShape.circle),
                  child: remlength == 0 || remlength==null
                      ? Text('')
                      : TextWidget(
                          text: '$remlength',
                          textcolor: Colors.white,
                        ),
                )),
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
                Icons.meeting_room_outlined,
                color: Color.fromARGB(255, 2, 64, 114),
              ),
              title:
                  Text('Meetings', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
              MyNavigation.push(context, MeetingsDetail());
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
body: SingleChildScrollView(
  child: Container(
    padding: EdgeInsets.all(15),
    child: Column(
      children: [
        TextWidget(alignment: Alignment.center,    text: '$authority',
              textcolor: MyColors.blue,size: 22,letterspacing: 1.2,
              fontWeight: FontWeight.bold,),
        SizedBox(height: 20,),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
           cardcont(text:'Complaints',icon: Icons.comment, onTab: () {
                 MyNavigation.push(context, AuthorityComplaint()); }),
              authority=='VC'?Container():    cardcont(text:'Add Complaints',icon: Icons.add, onTab: () {
                    print('$authority  nnnnnnnnnnnnnnnwwwwwwwwwwwwwn');
                 MyNavigation.push(context, CriminalComplaint(role: '$authority',));
                  }),

        // ],)
        
            //  Container(
            //   alignment: Alignment.topLeft,
            //    child: GestureDetector(
            //     onTap: () {
            //       MyNavigation.push(context, AuthorityComplaint());
            //     },
            //      child: Card(
                  
            //       child: Container(
            //         margin: EdgeInsets.all(15),
            //         child: Column(
            //         children: [
            //         Icon(
            //           Icons.comment,
            //           color: Color.fromARGB(255, 2, 64, 114),
                      
            //         ), Text(
            //           'Complaints',
            //           style: TextStyle(fontWeight: FontWeight.bold),
            //         ),
            //         ],
            //                        ),
            //       ),
                
            //                  ),
            //    ),
            //  ),
      ],
    ),
  )

),
    );
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