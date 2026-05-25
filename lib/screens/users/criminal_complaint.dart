// ignore_for_file: prefer_const_constructors, sort_child_properties_last, unused_field, prefer_final_fields, unused_local_variable, prefer_const_literals_to_create_immutables, unnecessary_null_comparison, unused_element

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/date_picker_widget.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:complaintsystem/screens/authority/authority_home.dart';
import 'package:complaintsystem/screens/users/complaint_confirm.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class CriminalComplaint extends StatefulWidget {
  final role;
  const CriminalComplaint({super.key, this.role});

  @override
  State<CriminalComplaint> createState() => _CriminalComplaint();
}

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

class _CriminalComplaint extends State<CriminalComplaint> {
  final _formKey = GlobalKey<FormState>();
  bool _categoryError = false;

  String? _validateCpliant(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your complaint title';
    }
    return null;
  }

  String? _validateComplaintDetails(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Complaint details';
    }
  }

  bool isLoading = false;
  List<String> imageUrls = [];
  bool _isChoosingFile = false;
  String? locationName;
  final TextEditingController _subjectController = TextEditingController();
  var categoryController = TextEditingController();
  final TextEditingController _complaintLocationController =
      TextEditingController();
  String? selectedCategory;
  String? Pstation;
  final TextEditingController _complaintDetailsController =
      TextEditingController();

  List<String> _complaintcat = [
    // 'Harassment',
    // 'General Complaint',
    // 'Corruption',
    // 'Beating',
    // 'Fraud'
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

  List userList = [];
  List priorityList = ["High", "Medium", "Low"];
  String roleval = 'CS';
  getuserList(authority) {
    print('${widget.role} ////////////////');
    userList = [];
    FirebaseFirestore.instance
        .collection("Comlaint_tokens")
        .where('role', isEqualTo: "Authority")
        .where('authority', isEqualTo: authority)
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        print(doc[i]['role']);
        print(doc[i]['authority']);

        userList.add(doc[i]['noti_token']);

        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {

        // }
      }
      setState(() {});
    });

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
    getAddress();
  }

  void getAddress() async {
    locationName = await getAddressFromLatLng(latitude!, longitude!);
    setState(() {});
    print('Address: $locationName');
  }

  Future<String?> getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = '${placemark.subLocality} ${placemark.locality}';
        return address;
      } else {
        return 'No address found';
      }
    } catch (e) {
      print('Error: $e');
      return 'Error getting address';
    }
  }

  _determinePosition() async {
    print('object');
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await takeLocation();
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
    final category = selectedCategory;
    final selectedImage = _selectedImages;
  }

  String? username;
  String? role;
  String? image;
  String? subrole;
  String? phone;
  DateTime? selectDate;

  // String? office;
  // String? department;
  getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    image = prefs.getString('image');
    subrole = prefs.getString('authority');
    phone = prefs.getString('phone');
    selectval = prefs.getString('department');

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
  List sendList = [];
  List<Map<String, dynamic>> meetingList = [];

  Future<void> reportComplaint() async {
    sendList = [];
    if(autghority==''){
    setState(() {
      autghority='ADSA';
    });

    }
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    print('${widget.role}');
    isLoading = true;
    setState(() {});
    getrandomnmbr();
    print('hello');
    for (var pickedFile in _selectedImages) {
      final file = File(pickedFile.path);
      final storageRef =
          FirebaseStorage.instance.ref().child('images/${file.path}');
      await storageRef.putFile(file);

      // Get the download URL of the uploaded image
      final imageUrl = await storageRef.getDownloadURL();
      imageUrls.add(imageUrl);
    }
    String response = "Sending.....";
    String forwd = '';
    Map<String, dynamic> assignList = {
      'sender': widget.role == 'User' ? "Student" : widget.role,
      'receiver': autghority,
    };
    sendList.add(assignList);

    await Provider.of<ComplaintProvider>(context, listen: false)
        .reportComplaint(
            body: _complaintDetailsController.text,
            id: 'new',
            bodyMap: {
              "id": "${CusDateFormat.gettime(today)}" + "$randomNumber",
              "subject": _subjectController.text,
              "category": other || selectedCategory == null
                  ? matchCat
                  : selectedCategory,
              "complaintDetail": _complaintDetailsController.text,
              "attachment": imageUrls,
              "contact": phone,
              "date": "${CusDateFormat.getDate(today)}",
              "name": username,
              "address": addressController.text,
              "status": "Open",
              "image": image,
              "priority": priority,
              // repeatedElement=='Harassment'
              //     ? 'High'
              //     :  repeatedElement=='Grade Disputes'
              //         ? 'Medium'
              //         :  repeatedElement=='Admission Process'
              //             ? 'Low'
              //             : 'Medium',
              "priorityValue": priority == 'High'
                  ? 3
                  : priority == 'Medium'
                      ? 2
                      : 1,
              'faculty': widget.role,
              "timeStamp": timeStamp,
              "reason": "",
              "assignto": "",
              "assign": true,
              "remind": false,
              'teamRemark': '',
              "forword": false,
              'forwordTo': '',
              "final": false,
              "ADSA":
                  autghority == 'ADSA' ? true : false,
              "HOD": autghority == 'HOD' ? true : false,
              "Deen": autghority == 'Deen' ? true : false,
              "Registerar": autghority == 'Registerar' ? true : false,
              "VC": autghority == 'VC' ? true : false,
              'Investigator': false,
              "forwordADSA": "",
              "forwordHOD": "",
              "forwordDeen": "",
              "forwordRegisterar": "",
              "forwordVC": "",
              "assignADSA": autghority == 'ADSA' ? 'ADSA' : '',
              "assignHOD": autghority == 'HOD' ? 'HOD' : '',
              "assignDeen": autghority == 'Deen' ? 'Deen' : '',
              "assignRegisterar":
                  autghority == 'Registerar' ? 'Registerar' : '',
              "assignVC": autghority == 'VC' ? 'VC' : '',
              'sender': widget.role == 'User' ? "Student" : widget.role,
              "authority": autghority,
              "department": selectval,
              "reminderDate": '${CusDateFormat.getdday(selectDate!)}',
              'assignList': sendList,
              'meetingList': meetingList
            },
            title: '$matchCat',
            userList: userList);
    //       if(other==true){
    //           await _firestore.collection('category').doc(categoryController.text).set({
    // "categoryName": categoryController.text,});

    //       }
    isLoading = false;
    setState(() {
      other = false;
    });

    MyNavigation.pushreplacement(
        context,
        ComplaintConfirmationPage(
          role: widget.role == 'Teacher' ? 'Teacher' : role,
        ));
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

  getcat() async {
    _complaintcat = [];
    print('hellooooooooooooooooooooooooooooooooo');
    FirebaseFirestore.instance
        .collection("category")
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        print(doc[i]['categoryName']);
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {
        _complaintcat.add(doc[i]['categoryName']);
        // }
      }
      setState(() {});
    });
    print(_complaintcat);
    setState(() {});
  }

  getAIdata() async {
    AIDataList = [];
    print('hellooooooooooooooooooooooooooooooooo');
    FirebaseFirestore.instance.collection("AIData").snapshots().listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        print(doc[i]['name']);
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {
        AIDataList.add(doc[i]['name']);
        // }
      }
      setState(() {});
    });
    print(AIDataList);
    setState(() {});
  }

  bool other = false;
  @override
  void initState() {
    super.initState();

    getUid();
    getcat();
    getdepartment();
    getAIdata();
    getuser();
    if (role == 'User') {
      getuserList('ADSA');
    }
    _determinePosition();
  }

  List type = [];
  startLocationUpdates() {
    Permission.location.serviceStatus.isEnabled;
    Permission.location.request().then((PermissionStatus status) {
      if (status.isGranted) {
        takeLocation();

        // });
      } else {
        print('Permission to access location denied.');
      }
    });
  }

  String? selectval;
  String priority = 'High';

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
        if (doc[i]['name'] != widget.role) {
          authoList.add(doc[i]['name']);
        }
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {

        // }
      }
      setState(() {});
    });
    print(authoList);
    setState(() {});
  }

  List authoList = [];
  String autghority = '';
  String? repeatedElement;
  List<String> AIDataList = [];
  List<String> AllList = [
    'behavior',
    'reporting',
    'investigation',
    'confidentiality',
    'support',
    'policy',
    'participation',
    'clubs',
    'organizations',
    'sports',
    'events',
    'funding',
    'support',
    'application',
    'eligibility',
    'documentation',
    'submission',
    'deadline',
    'review',
    'interview'
  ];
  gettp(detail) {
    //List<String> lowercaseList = ['Harrasment', 'Corrupt', 'Killer', 'state'];
    List<String> keywords =
        AllList.map((element) => element.toLowerCase()).toList();

    String paragraph = detail;
    List<String> wordsArray = paragraph.toLowerCase().split(' ');
    List<String> cleanedWordsArray = wordsArray.map((word) {
      return word.replaceAll(RegExp(r'[.,]'), '');
    }).toList();

    List<String> common3Elements =
        keywords.toSet().intersection(cleanedWordsArray.toSet()).toList();
    print(common3Elements);
    List<String> commonElements =
        keywords.toSet().intersection(cleanedWordsArray.toSet()).toList();
    print(commonElements);
    if (commonElements.isEmpty) {
      if (selectedCategory == null) {
        repeatedElement = 'General Complaint';
      } else {
        repeatedElement = selectedCategory;
      }
    } else {
      String comVal = commonElements[0];
      print(harassmentList);

      if (harassmentList.contains(commonElements[0])) {
        print('$comVal ???????????');

        repeatedElement = 'Harassment';
        print('$repeatedElement //////////////////');
      } else if (gradeList.contains(comVal)) {
        repeatedElement = 'Grade Disputes';
      } else if (addmissionList.contains(comVal)) {
        repeatedElement = 'Admission Process';
      } else {
        if (selectedCategory!.isEmpty) {
          repeatedElement = 'General Complaint';
        } else {
          repeatedElement = selectedCategory;
        }
        // repeatedElement=null;
      }
    }

    // List<String> repeated2Elements = commonElements.where((element) {
    //   int count = cleanedWordsArray.where((e) => e == element).length;
    //   return count > 1;
    // }).toList();

    // if (repeated2Elements.isNotEmpty) {
    //   setState(() {
    //     repeatedElement = repeated2Elements[0];
    //   });
    // } else
    //  if (common3Elements.isNotEmpty) {
    //   setState(() {
    //     repeatedElement = common3Elements[0];
    //   });
    // } else {
    //   repeatedElement = null;
    //   setState(() {});
    // }
    // if (repeatedElement!.isNotEmpty) {
    //   setState(() {
    //     other = false;
    //   });
    //}

//print('$repeatedElement ?>?>?>?.>>>>');
  }

  comparelist(String paragraph) {
    print(paragraph);
    List<String> paragraphWords = paragraph.toLowerCase().split(RegExp(r"\W+"));
    print(paragraphWords);
    List<String> wordsArray = paragraph.toLowerCase().split(' ');
    List<String> cleanedWordsArray = wordsArray.map((word) {
      return word.replaceAll(RegExp(r'[.,]'), '');
    }).toList();
    List<String> commonWords =
        AllList.where((word) => paragraphWords.contains(word)).toList();

    print("Common words: $commonWords");
  }

  List<String> harassmentList = [
    'behavior',
    'reporting',
    'investigation',
    'confidentiality',
    'support',
    'policy'
  ];
  List<String> gradeList = [
    'participation',
    'clubs',
    'organizations',
    'sports',
    'events',
    'funding'
  ];
  List<String> addmissionList = [
    'application',
    'eligibility',
    'documentation',
    'submission',
    'deadline',
    'review',
    'interview'
  ];
  String? matchCat;
  bool match = false;
  getKeywords(keyword) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var request = http.Request('POST',
          Uri.parse('https://school.xtremessoft.com/home/MatchKeywords'));
      request.body = json.encode({
        "keywords": "$keyword",
      });
      request.headers.addAll(headers);

      http.StreamedResponse streamResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        print('???????????????????');
        var decode = json.decode(response.body);
        // if(decode['IsFound']==false){

        // }else{
        setState(() {
          matchCat = decode['Category'];
          priority = decode['priority'];
        });
        // }

        print('$matchCat >>>>');
        print(priority);
        print('Deleted');
        // print(decode);
      }
    } catch (e) {}
  }

  List admissionCat = ['ADSA', 'HOD'];

  List teacherCat = ['VC', 'HOD'];

  @override
  Widget build(BuildContext context) {
    var pro = Provider.of<ComplaintProvider>(context, listen: false);
    print(role);
    print('${widget.role}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 64, 114),
        centerTitle: true,
        title: GestureDetector(
          onTap: () async {
            print(_complaintDetailsController.text);
          },
          child: Text(
            'Complaints',
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
                  SizedBox(
                    height: 15,
                  ),
                  role == 'Authority' || role == 'Teacher'
                      ? Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField(
                                menuMaxHeight: 300,

                                // underline: const SizedBox(),
                                decoration: const InputDecoration(
                                  alignLabelWithHint: true,
                                  border: InputBorder.none,
                                  errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                hint: Text(
                                  "Select Faculty",
                                  style: TextStyle(
                                      color: MyColors.blue, fontSize: 12.sp),
                                ),
                                isExpanded: true,
                                items: authoList.map((map) {
                                  return DropdownMenuItem<String>(
                                      value: map, child: Text(map));
                                }).toList(),
                                onChanged: (val) {
                                  autghority = val.toString();
                                  print(autghority);

                                  getuserList(autghority);

                                  setState(() {});
                                }),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField(
                                menuMaxHeight: 300,

                                // underline: const SizedBox(),
                                decoration: const InputDecoration(
                                  alignLabelWithHint: true,
                                  border: InputBorder.none,
                                  errorBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                hint: Text(
                                  "Select department",
                                  style: TextStyle(
                                      color: MyColors.blue, fontSize: 12.sp),
                                ),
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
                        ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: _subjectController,
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        hintText: 'Enter your complaint title',
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: Color.fromARGB(255, 2, 64, 114),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.grey[300],
                      ),
                      validator: _validateCpliant,

                      // maxLength: 20,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
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
                          hint: Text(
                            "Select your category",
                            style: TextStyle(
                                color: MyColors.blue, fontSize: 12.sp),
                          ),
                          isExpanded: true,
                          value: selectedCategory,
                          items: _complaintcat.map((map) {
                            return DropdownMenuItem<String>(
                                value: map, child: Text(map));
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCategory = val;
                            });
                            print(selectedCategory);
                            setState(() {
                              autghority='';
                            });
                            if (val == "other") {
                              setState(() {
                                other = true;
                              });
                            } else {
                              if (selectedCategory == 'Harassment') {
                                setState(() {
                                  priority = 'High';
                                });
                              }
                              if (selectedCategory == 'Grade Disputes' ||
                                  selectedCategory == 'Corruption') {
                                setState(() {
                                  priority = 'Medium';
                                });
                              }
                              if (selectedCategory == 'Admission Process') {
                                setState(() {
                                  priority = 'Low';
                                });
                              }
                              setState(() {
                                other = false;
                              });
                              print(priority);
                            }
                          }),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
              role == 'Authority' || role == 'Teacher' ? Container():selectedCategory==null?Container():      Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            hint: 
                              autghority==''?  Text(
                                    'Select Faculty',
                                
                                  ):Text('$autghority'),
                               
                            isExpanded: true,
                            iconSize: 24.0,
                        // value: autghority.toString(),
                            items: selectedCategory=='About Teacher'
                                ? ['VC','HOD'].map(
                                    (val) {
                                      return DropdownMenuItem<String>(
                                        value: val,
                                        child: Text(val),
                                      );
                                    },
                                  ).toList()
                               
                                    : ['ADSA','HOD'].map(
                                        (val) {
                                          return DropdownMenuItem<String>(
                                            value: val,
                                            child: Text(val),
                                          );
                                        },
                                      ).toList(),
                            onChanged: (val) {
                              setState(
                                () {
                                  autghority = val.toString();
                                },
                              );
                            },
                          ),
                        )
                  ),
                  SizedBox(
                    height:role == 'Authority' || role == 'Teacher'?0: 10,
                  ),
                  '$selectedCategory'.trim() == 'other'.trim()
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: categoryController,
                            decoration: InputDecoration(
                              filled: true,
                              isDense: true,
                              hintText: 'Enter your Category Type',
                              hintStyle: TextStyle(
                                fontSize: 12.sp,
                                color: Color.fromARGB(255, 2, 64, 114),
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              fillColor: Colors.grey[300],
                            ),
                            onChanged: (value) {
                              getKeywords(value);
                            },
                            // validator: _validateCpliant,

                            // maxLength: 20,
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: addressController,
                      decoration: InputDecoration(
                        filled: true,
                        isDense: true,
                        hintText: 'Enter Address',
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: Color.fromARGB(255, 2, 64, 114),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.grey[300],
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter Address';
                        }
                        return null;
                      },

                      // maxLength: 20,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: SingleChildScrollView(
                      child: TextFormField(
                        onChanged: (value) {
                          if (other == true || selectedCategory == null) {
                            getKeywords(value);
                          }
                        },
                        maxLines: 5,
                        keyboardType: TextInputType.text,
                        controller: _complaintDetailsController,

                        decoration: InputDecoration(
                          hintText: 'Enter your complaint details...',
                          hintStyle: TextStyle(
                            fontSize: 12.sp,
                            color: Color.fromARGB(255, 2, 64, 114),
                          ),
                          filled: true,
                          isDense: true,
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10)),
                          fillColor: Colors.grey[300],
                        ),
                        validator: _validateComplaintDetails,
                        //  maxLength: 6,
                      ),

                      // textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    child: DatePickerWidget(
                        text: selectDate == null
                            ? 'Set Reminder date'
                            : '${CusDateFormat.getdday(selectDate!)}',
                        pickedDate: (date) => setState(() {
                              selectDate = date;
                            }),
                        border: Border.all(),
                        borderradius: BorderRadius.circular(15)),
                  ),
                  SizedBox(height: 15.h),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 240).w,
                        child: Text(
                          'ATTACHMENTS',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 2, 64, 114),
                          ),
                        ),
                      ),
                      if (isChooseFileVisible())
                        Padding(
                          padding: const EdgeInsets.only(right: 250),
                          child: TextButton(
                            onPressed: _isChoosingFile ? null : _pickImage,
                            child: Container(
                              height: 40,
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(255, 2, 64, 114),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8).w,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.file_upload,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'Choose File',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Visibility(
                    visible: _selectedImages.isNotEmpty,
                    child: Wrap(
                      children: [
                        for (int index = 0;
                            index < _selectedImages.length;
                            index++)
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    _removeImage(index);
                                  },
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.grey[200],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus!.unfocus();
                            if (_formKey.currentState!.validate()) {
                              reportComplaint();
                              // getuserList();
                            }
                          },
                          child: Text('Submit'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 2, 64, 114),
                            ),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
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
