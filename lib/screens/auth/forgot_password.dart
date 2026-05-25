
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/components/validation_cont.dart';
import 'package:complaintsystem/screens/auth/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController phoneController = TextEditingController();

  bool eml = false;
  String? getemail;

  TextEditingController forgotemail = TextEditingController();
 forgotpass() async{
  final snapShot;
      snapShot =
          await _firestore.collection('credentials').doc(phoneController.text).get();
          if (snapShot.exists) {
             await _firestore
            .collection('credentials')
            .doc(phoneController.text)
            .get()
            .then((value) {
          getemail = value['email'];
        });
          }
          try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: getemail!);
      print('Password reset OTP sent to $getemail');
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: MyColors.blue,
          content: TextWidget(text:'Check your email $getemail',textcolor: MyColors.white,),
        ));
        
      Navigator.pop(context);
     // MyNavigation.pushreplacement(context,OtpVerificationScreen() );
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$e'),
        ));
      print('Error sending password reset OTP: $e');
      // Handle the error
    }
   }
   String _verificationId = '';

  Future<void> _sendOTP() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+923457483103",
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification for some devices
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.message}'),
        ));
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('OTP Sent!'),
        ));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpVerificationScreen(verificationId: _verificationId)),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.blue, iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                child: Text(
                  'FORGOT PASSWORD ?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                      fontSize: 20),
                ),
              ),
              Text(
               // pro.code
                    // ? 'Enter Verification Code'
                    // : 
                    'ENTER YOUR Phone No. TO RESET YOUR PASSWORD',
                style: TextStyle(color: Colors.black38),
              ),
              SizedBox(
                height: 20,
              ),
           Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: Container(
                        color: Colors.grey[300],
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller:phoneController,
                          onChanged: (value) {
                            setState(() {
                              eml = false;
                            });
                          },
                          decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.black26),
                              border: InputBorder.none,
                              hintText: ' Phone No. ',
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10)),
                        ),
                      ),
                    ),
              eml ? ValidationContainer() : Container(),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 50,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: MyColors.blue,
                ),
                child: Center(
                    child: GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus!.unfocus();
                    if (phoneController.text.isEmpty) {
                      setState(() {
                        eml = true;
                      });
                    } else {
                      forgotpass();
                      
                    } 
                  },
                  child: Text(
                    'REGISTER YOUR PASSWORD',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
              ),
            ],
          ),
        ));
  }

  bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$',
    );
    return emailRegExp.hasMatch(email);
  }
}
