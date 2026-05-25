import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/screens/admin/admin_notification.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
class SendNotification extends StatefulWidget {
  const SendNotification({super.key});

  @override
  State<SendNotification> createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {
 final _formKey = GlobalKey<FormState>();
  bool _categoryError = false;

  String? _validateCpliant(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Notification title';
    }
    return null;
  }

  String? _validateComplaintDetails(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Notification details';
    }
  }

  bool isLoading = false;
  List<String> imageUrls = [];
  bool _isChoosingFile = false;
  String? locationName;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _complaintLocationController =
      TextEditingController();
  String? _selectedCategory;
  String? Pstation;
  final TextEditingController _complaintDetailsController =
      TextEditingController();

  List<String> _complaintcat = [
    'Harassment',
    'General Complaint',
    'Corruption','Beating','Fraud'
  ];

  List<Map<String, dynamic>> _Stationcategories = [];
 // List<Map<String, dynamic>> _complaintcat = [];
  List<String> _province = ['Khyber Pakhtunkhwa', 'Punjab'];
  final TextEditingController childNameController = TextEditingController();
  final TextEditingController bFormNumberController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController fatherGuardianNameController =
      TextEditingController();
  final TextEditingController fatherCnicController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Random random = new Random();
  int? randomNumber;
  int rslt = 0;
  StreamSubscription<Position>? locationSubscription;
  double? latitude;
  double? longitude;
  Position? currentPosition;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<File> _selectedImages = [];
  DateTime today = DateTime.now();
  bool isChooseFileVisible() {
    return _selectedImages.isEmpty;
  }

  List tokenList = [];

  getTokenList(rec) async{
    print(contactList);
    tokenList = [];
    var contact;
          print('$rec////////////');

    if(rec=='Complainer'){
      for (var i = 0; i < contactList.length; i++) {
        if (contactList[i]['name']==complainer) {
          setState(() {
            contact=contactList[i]['contact'];
          });
          print('$contact////////////');
          
        }
        
      }
      
    await   FirebaseFirestore.instance
        .collection("tokens").doc(contact)
        .snapshots()
        .listen((event) {
      print(event.data());
      var doc = event.get('noti_token');
          tokenList.add(doc);


    //   for (int i = 0; i < event.docs.length; i++) {
    //   // if (doc[i]['authority'] == receiver) {
    //       tokenList.add(doc[i]['noti_token']);
    // //  }
    //   }
    });

    }else{
       FirebaseFirestore.instance
        .collection("Comlaint_tokens")
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
       if (doc[i]['authority'] == receiver) {
        
          tokenList.add(doc[i]['noti_token']);
          print('$tokenList////////////');

      }
      }
    });

    }
   

    

    setState(() {});
  }

  takeLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    latitude = position.latitude;
    longitude = position.longitude;
    setState(() {});
    print('Address: $latitude');
   
  
  }

 

  getrandomnmbr() {
    randomNumber = random.nextInt(100) + 2;
    print("${CusDateFormat.gettime(today)}" + "$randomNumber");
  }

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedImage = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedImage != null) {
  //     setState(() {
  //       _selectedImages.add(File(pickedImage.path));
  //     });
  //   }
  // }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    List<XFile> pickedImages = await picker
        .pickMultiImage(); // Use pickMultiImage instead of pickImage

    if (pickedImages != null && pickedImages.isNotEmpty) {
      for (var pickedImage in pickedImages) {
        setState(() {
          _selectedImages.add(File(pickedImage.path));
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitForm() {
    final subject = _subjectController.text;
    final complaintLocation = _complaintLocationController.text;
    final category = _selectedCategory;
    final selectedImage = _selectedImages;
  }

  String? username;
  String? role;
  String? image;
  // String? office;
  // String? department;
  getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    image = prefs.getString('image');
    //  office = prefs.getString('office');
    // department = prefs.getString('department');
    print(image);
    setState(() {});
    // print(getChannel());
  }

   Future<String> getAccessToken() async {
  print('Strt');
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
         "type": "service_account",
  "project_id": "compalintsystem",
  "private_key_id": "fbc5cd461175034fafd7fe361ec6db61a99cd735",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDiK4TU21CgVt6J\nUClBymRGeEqqEWbi8DoiBa1nPc+Y9z/MM7rzdKaI3pZAV3V6bdu3vuiwLzHi7Fdv\nM2zLtEGmGSUXAF9tL/+nQabB2t/kxqDhsim4Ku3kwRyXQ3krAhCwj9VCRL/4uITs\n2iMvXmlk/KWqVIAnGJE+JKUvrwUcdgMngnVb8TnzTktueeUVpVMevDyb4tYTyNi+\n3Cxeh3w2LIDhD+bKz1UPpXn2KWDXKYAgmOIAqH22Vk++WSJU5dyYucyt/qYnTYbT\nEsiD0tmIFuorT7/0YwS0j9m7o2udqTbCVgxqrZnplzxLFv2e5DvdO6LCjULRuPz1\n4WFcNlRbAgMBAAECggEAb/cTXzzjgT0AFgI1KnjDg49xhxfuU1KRtN4SphWXfCaK\n0tCZMIUDHKb0ww2I/v770s8T6oSysaBG+KoApieqiEvSbLymgStN6MM7hqSQSnV6\nl8DXnnDCLIjdWpTwmzX+hSnvbUsTrlHKnGaxHHYkvvXEHbqPZstmu9jwXdbLNPbZ\nAeNiUrWN5i9asqXu8pgZQPfg6MlnJcVz5PA/Qz+BjCsfdB5ByDAtmULMSHW4SE9c\nNdVsI3C/IHqAZpCOKpJ7N8Qox5pNYAwjm0fLnChYktWiLwPNwnRMLXB16ZGnKnn9\nid+01umEBcwN1LBYK7ty6bYqjy41mydce5piqQHjgQKBgQDxqe3Im2vWCVRAEBw0\n9wRJKkwXxsVI/u7Bckk455EyFewaHEdCS60gqXn64NMPdH3ZPK/+lRAdCT8OFGmx\nukkueboduSOiTsS9K1NHQ6A/WtGsRyra+Vl6466NP2rWLcQqflWw8boQZODWJfdC\nLTvPNW/h22J9NMna23LUyAWc6wKBgQDvlkpwa5661oZMn4lji78meoE8V0pu0edt\nupEWWEMK0KWPlZ3UU09bHUo5x2UFHY1pTaE6FTwBuk1xD8dRlddO8ZX6TAmHoWo9\nBOyNf0pk8CYdD79KPtkR3civer20711k3If1SQ2VlJ6CazTG/r5Owctneh0xq7ql\n+k+BeUuKUQKBgQC5gfwqNkR9NQQbeUJt1gDQOUvYJJllA207ygMzT29Bx1pKYNLC\nrVzk6bPdRaA/COliTRe8kaig4Wwp3rmT2LA8oOyhzHDyMw0LOarf1aW5fHnfiXH4\nTdjGYOipPLlCWDdxdzFIdwahdw6w1MwNXLPAyABum/3qpw8clcB8Xl8QqQKBgC2t\nus2KRz4aDornU9tt1mjwrFkjz2YnkPcjvevDsiyKsTYZ8Xh81cFqaS9w67q48rAk\nA9w+Fi3CJmeq+XZ9mgpMFysceiioxseRe8RSg42RF8MssGzoZJx6a3vBbA/mHylO\nvoEuh2+AYWQ+KlbSVNhRLIWzC4Pf2PsyKRxnUtaxAoGACN7OSyuk+qX2ddt9CXXR\nUtak0pPlGBnxM80I6VzY/2FeCFx0yJAH0AbR5PN76LX+oVX/1numWgKaAfhWxpw0\nF5DwdLVTykx9V1I1rbHOWcKvPY1Hso2GsvHGtjtuvfTkZc3NpVDeODF0Vzak8K6Z\n3bmJjr/ljLdsLUWxMtke7CE=\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-pjf6m@compalintsystem.iam.gserviceaccount.com",
  "client_id": "105894384221462923758",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-pjf6m%40compalintsystem.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
String? accessToken;

   Future<void> reportComplaint() async {
     accessToken=await getAccessToken();
   // getuserList();
    print(accessToken);
    isLoading = true;
    setState(() {});
    getrandomnmbr();
    print('hello');
   
    String responsee = "Sending....."; 
    String timeStamp = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();

    try {
      print('start');

     
    

      for (int i = 0; i < tokenList.length; i++) {
       final Map<String, dynamic> message = {
      "message": {
        "token": tokenList[i]
            ,
        "notification": {
          "title": _subjectController.text,
          "body":_complaintDetailsController.text
        },
        "android": {"priority": "HIGH"},
        "apns": {
          "headers": {"apns-priority": "10"},
        },
        'data': {'name': 'notification', 'id': 'notification'}
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
      await _firestore.collection('adminNotifications').doc().set({
        "id": "${CusDateFormat.gettime(today)}" + "$randomNumber",
        
        "notificationDetail": _complaintDetailsController.text,
       'title':_subjectController.text,
        "date": "${CusDateFormat.getDate(today)}",
        "read":false,
        'from':'$username(Admin)',
        'to':receiver=='Complainer'?complainer:receiver,
        'timeStamp':timeStamp
       
      });
      responsee = 'Submit Successfully';
      isLoading = false;
      setState(() {});
      Navigator.pop(context);
      MyNavigation.pushreplacement(context, AdminNotification());

      print('Notification sent successfully!');
    } else {
      print(
          'Failed to send notification: ${response.statusCode} ${response.body}');
          setState(() {
      isLoading = false;
            
          });
    }
      }
    } catch (err) {
      responsee = 'error';
      isLoading = false;
setState(() {
  
});
    }
  }

 

  Future<List<Map<String, dynamic>>> fetchData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('category').get();

    List<Map<String, dynamic>> data = [];

    querySnapshot.docs.forEach((doc) {
      data.add(doc.data() as Map<String, dynamic>);
    });

    return data;
  }
List contactList=[];
  getComplainer(rol) async {
    complainerList=[];
    contactList=[];
    print('hellooooooooooooooooooooooooooooooooo');
    final collectionReference =
        FirebaseFirestore.instance.collection('complaint').where('faculty',isEqualTo: '$rol');

    QuerySnapshot category = await collectionReference.get();

    for (var cat in category.docs) {
      if(complainerList.contains(cat['name'])){

      }else{
 complainerList.add(cat['name']);
      contactList.add({'name':cat['name'],'contact':cat['contact']});
      }
     


      print(cat['name']);
    }


    setState(() {});
  }

List complainerList=[];
String complainer='';

  

  @override
  void initState() {
    super.initState();
    takeLocation();
    getUid();
    // getcat();
    // fetchData().then((data) {
    //   setState(() {
    //     _complaintcat = data;
    //   });
    // });
    
    // getPoliceStation();
  }
 List receiverList=["Complainer","ADSA", "HOD", "Deen", "Registrar", "VC"];
  String receiver = '';
    String teacher = '';
String? _validaterole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please Select  role';
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 64, 114),
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
         
          },
          child: Text(
            'Send Notification',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: 10.h,
            ),
           Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(right: 270).w,
                        //   child: Text(
                        //     'Complaint:',
                        //     style: TextStyle(
                        //       fontSize: 14.sp,
                        //       fontWeight: FontWeight.bold,
                        //       color: Color.fromARGB(255, 2, 64, 114),
                        //     ),
                        //   ),
                        // ),
                          SizedBox(height: 15,),
                      Container(
                        margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
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
                          hint: Text("Select receiver"),
                          isExpanded: true,
                          items: receiverList.map((map) {
                            return DropdownMenuItem<String>(
                                value: map, child: Text(map));
                          }).toList(),
                          onChanged: (val) {
                            receiver = val.toString();
                            print(receiver);
                             if(teacher=='Complainer'){
                          
                            }else{
                              getTokenList('');
                            }

                            setState(() {});
                          },value: receiver.isEmpty?null:receiver,),
                    ),
                  ),
                 receiver=='Complainer' ? Container(
                  margin: EdgeInsets.all(8),
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
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
                                   if(teacher=='Teacher'){
                              getComplainer('Teacher');
                            }else{
                              getComplainer('User');
                            }

                                    setState(() {});
                                  }),
                            ),
                          ):Container(),
                  receiver=='Complainer'?Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
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
                          hint: Text("Select Complainer"),
                          isExpanded: true,
                          items: complainerList.map((map) {
                            return DropdownMenuItem<String>(
                                value: map, child: Text(map));
                          }).toList(),
                          onChanged: (val) {
                            complainer = val.toString();
                            print(complainer);

                            setState(() {});
                              getTokenList('Complainer');

                          },value: complainer.isEmpty?null:complainer,),
                    ),


                  ):Container(),
                        Padding(
                          padding: const EdgeInsets.all(8.0).w,
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: _subjectController,
                            decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              hintText: 'Notification title',
                              hintStyle: TextStyle(
                                fontSize: 12.sp,
                                color: Color.fromARGB(255, 2, 64, 114),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(15).w,
                              ),
                              fillColor: Colors.grey[300],
                            ),
                            validator: _validateCpliant,

                            // maxLength: 20,
                          ),
                        ),

                      
                      
                        SizedBox(
                          height: 5,
                        ),

                        Padding(
                          padding:  EdgeInsets.all(8.0).w,
                          child: SingleChildScrollView(
                            child: TextFormField(
                              maxLines: 5,
                              keyboardType: TextInputType.text,
                              controller: _complaintDetailsController,

                              decoration: InputDecoration(
                                hintText: 'Notification details...',
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: Color.fromARGB(255, 2, 64, 114),
                                ),
                                filled: true,
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15).w),
                                fillColor: Colors.grey[300],
                              ),
                              validator: _validateComplaintDetails,
                              //  maxLength: 6,
                            ),

                            // textAlign: TextAlign.left,
                          ),
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       vertical: 10, horizontal: 20),
                        //   child: Container(
                        //     height: 120,
                        //     width: 360,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(20),
                        //       color: Colors.grey[300],
                        //     ),
                        //     child: TextFormField(
                        //       cursorColor: Color.fromARGB(255, 2, 64, 114),
                        //       keyboardType: TextInputType.multiline,
                        //       maxLines: null,
                        //       controller: _complaintDetailsController,
                        //       decoration: InputDecoration(
                        //         border: InputBorder.none,
                        //         contentPadding: EdgeInsets.all(10),
                        //         hintText: 'Enter your complaint details',
                        //         hintStyle: TextStyle(
                        //           fontSize: 14,
                        //           color: Color.fromARGB(255, 2, 64, 114),
                        //         ),
                        //       ),
                        //       // textAlign: TextAlign.left,
                        //       validator: (value) {
                        //         if (value!.isEmpty) {
                        //           return 'Please enter complaint details';
                        //         }
                        //         return null;
                        //       },
                        //     ),
                        //   ),
                        // ),
                      
                      //  SizedBox(height: 10.h),
                     
                        SizedBox(height: 30.h),
                        isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                reportComplaint();
                               //  getuserList();
                                  }
                                },
                                child: Text('Submit'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 2, 64, 114),
                                  ),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                ),
                              ),
                      ],
                    ),
                  )
              
          ],
        ),
      ),
    );
  }

  textCont(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 290, top: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 2, 64, 114),
        ),
      ),
    );
  }

  tabCont(String text, Color tcolor, Color bgcolor, Color bdcolor) {
    return Container(
      alignment: Alignment.center,
      // height: 40,
      // width: 150,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          border: Border.all(color: bdcolor),
          color: bgcolor,
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              color: tcolor, fontWeight: FontWeight.w500, fontSize: 12),
        ),
      ),
    );
  }

  textfldCont(TextEditingController? controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextFormField(
        cursorColor: Color.fromARGB(255, 2, 64, 114),
        keyboardType: TextInputType.text,
        controller: _subjectController,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(bottom: 10, left: 10),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 2, 64, 114),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your complaint';
          }
          return null;
        },
        textAlign: TextAlign.left,
      ),
    );
  }
}