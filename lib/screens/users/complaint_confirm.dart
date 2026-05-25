// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/screens/authority/authority_home.dart';
import 'package:complaintsystem/screens/teacher/teacher_home.dart';
import 'package:complaintsystem/screens/users/complaint_dashbord.dart';
import 'package:flutter/material.dart';

class ComplaintConfirmationPage extends StatelessWidget {
  final role;
  const ComplaintConfirmationPage({super.key,this.role});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 2, 64, 114),
        centerTitle: true,
        title: Text(
          'Complaint Confirmation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        //iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Color.fromARGB(255, 2, 64, 114),
              size: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Your complaint has been submitted successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // if (role == 'User') {
                //   MyNavigation.pushreplacement(context, Complaint());
                // }if (role == 'Teacher') {
                //   MyNavigation.pushreplacement(context, TeacherHome());
                // }
                //  else {
                //   MyNavigation.pushreplacement(context, AuthorityHome());
                // }
              },
              child: Text('Go Back'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 2, 64, 114),
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
