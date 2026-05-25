
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/screens/auth/password_reset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';
class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;

  OtpVerificationScreen({required this.verificationId});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _verifyOtpAndResetPassword() async {
    try {
      final code = _otpController.text.trim();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      await _auth.signInWithCredential(credential);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter OTP sent to your phone.'),
            SizedBox(height: 16),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _verifyOtpAndResetPassword();
              },
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

// TextEditingController pinEditingController = TextEditingController();

// class OneTimePassowrd extends StatefulWidget {
//   const OneTimePassowrd({super.key});

//   @override
//   State<OneTimePassowrd> createState() => _OneTimePassowrdState();
// }

// class _OneTimePassowrdState extends State<OneTimePassowrd> {
//   final _pinFocusNode = FocusNode();
//     TextEditingController pinEditingController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
    

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//       backgroundColor: MyColors.blue, iconTheme: IconThemeData(color: Colors.white),
//         title: TextWidget(text:'OTP Confirmation',textcolor: Colors.white,),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
          
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               'Varification',
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black54,
//                   fontSize: 20),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               'Enter the  OPT send to your phone number',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black54,
//               ),
//             ),
//             SizedBox(
//               height: 15,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                 left: 25,
//               ),
//               child: Pinput(
//                 controller: pinEditingController,
//                 length: 6,
//                 showCursor: true,
//                 defaultPinTheme: PinTheme(
//                     height: 50,
//                     width: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: MyColors.blue),
//                     ),
//                     textStyle:
//                         TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
//               ),
//             ),
//             SizedBox(
//               height: 30,
//             ),
//             Container(
//                 height: 50,
//                 width: 150,
//                 color: MyColors.blue,
//                 child: TextButton(
//                     onPressed: () {
//                       verifycodeapi(context);
//                     },
//                     child: Text(
//                       'VERIFY',
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                     ))),
//             SizedBox(
//               height: 20,
//             ),
//             Text(
//               "didn't receive any code ?",
//               style: TextStyle(fontSize: 20, color: Colors.black38),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Container(
//               height: 50,
//               width: 250,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 color: MyColors.blue,
//               ),
//               child: TextButton(
//                 onPressed: () {
//                  // pro.forgotapi(context);
//                 },
//                 child: Text(
//                   'Resend the new code..',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
