import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/utils.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
final log;
  const UserProfile({super.key,this.log});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseStorage firestorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  File? _selectedImageFile;

  bool isHiddenPassword = true;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  bool loading = false;

  String? phone;
  String? fileName;
  String? downloadimage;
  String? image;
  bool updateload = false;

  void getname() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
print(widget.log);
    setState(() {
      phone = prefs.getString('phone');
    });
    getDataFromFirestore();
  }

  void getDataFromFirestore() async {
   print('${widget.log}');
    await _firestore.collection('credentials').doc(phone).get().then((value) {
      usernameController.text = value['username'];
      emailController.text = value['email'];
      phoneController.text = value['phone'];
      image = value['image'];
    });
    setState(() {});
  }

  void update() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    updateload = true;
    setState(() {});
    if (_selectedImageFile != null) {
      Reference ref = firestorage.ref(fileName);
      await ref.putFile(_selectedImageFile!);

      downloadimage = await ref.getDownloadURL();
    }
    await FirebaseFirestore.instance.collection('credentials').doc(phone).update({
      'email': emailController.text,
      'username': usernameController.text,
      'password': '',
      'phone': phoneController.text,
      'image': downloadimage
    });
    prefs.setString('image', downloadimage.toString());
    updateload = false;
      showSnackBar('Profile updated', context, MyColors.blue);

    setState(() {});
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImageFile = File(pickedImage.path);
        fileName = pickedImage.path;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getname();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 2, 64, 114),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 30,
            ),
            Center(
              child: Stack(
                children: [
                  Container(
                    height: 130,
                    width: 130,
                    child: image != null && fileName == null
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(image.toString()),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.grey[300],
                            //backgroundColor: Color.fromARGB(255, 2, 64, 114),
                            backgroundImage: _selectedImageFile != null
                                ? FileImage(_selectedImageFile!)
                                : null,
                            child: fileName == null
                                ? Image.asset(
                                    'assets/avatar.jpeg',
                                    //height: 300,
                                  )
                                : null,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 10,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Center(
            //   child: Stack(
            //     children: [
            //       Container(
            //         height: 130,
            //         width: 130,
            //         child: CircleAvatar(
            //           //backgroundColor: Color.fromARGB(255, 2, 64, 114),
            //           backgroundImage: _selectedImageFile != null
            //               ? FileImage(_selectedImageFile!)
            //               : null,
            //         ),
            //       ),
            //       Positioned(
            //         bottom: 10,
            //         right: 20,
            //         child: GestureDetector(
            //           onTap: _pickImage,
            //           child: Container(
            //             // height: 30,
            //             // width: 35,
            //             // color: Colors.white,
            //             child: Icon(
            //               Icons.camera_alt,
            //               color: Color.fromARGB(255, 2, 64, 114),
            //               size: 25,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: 20,
            ),

            SizedBox(
              height: 25,
            ),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.person,
                      ),
                      fillColor: Colors.grey[200],
                    ),

                    // maxLength: 20,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.email,
                      ),
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone No.',
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.phone,
                      ),
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 24),
                  updateload
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            update();
                          },
                          child: TextWidget(
                            text: 'Update',
                            letterspacing: 1.0,
                          ))
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
