
import 'package:complaintsystem/components/my_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(_passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password reset successful.'),
        ));
        Navigator.popUntil(context, (route) => route.isFirst); // Back to login or home
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter your new password.'),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _resetPassword();
              },
              child: Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}

// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreen();
// }

// class _ResetPasswordScreen extends State<ResetPasswordScreen> {
//   TextEditingController newPasswordController = TextEditingController();
//   TextEditingController confirmPasswordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text('RESET PASSWORD'), iconTheme: IconThemeData(color: Colors.white),
//           backgroundColor: MyColors.blue,
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
//               child: Text(
//                 'CHANGE YOUR PASSWORD',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     fontSize: 20),
//               ),
//             ),
//             Text(
//               'ENTER YOUR NEW AND CONFIRM PASSWORD',
//               style: TextStyle(color: Colors.black54),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(13.0),
//               child: Container(
//                 color: Colors.grey[300],
//                 child: TextFormField(
//                   controller: newPasswordController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                       hintStyle: TextStyle(color: Colors.black26),
//                       border: InputBorder.none,
//                       hintText: 'New Password',
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10)),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(13.0),
//               child: Container(
//                 color: Colors.grey[300],
//                 child: TextFormField(
//                   controller: confirmPasswordController,
//                   keyboardType: TextInputType.emailAddress,
//                   textAlign: TextAlign.start,
//                   decoration: InputDecoration(
//                       hintStyle: TextStyle(color: Colors.black26),
//                       border: InputBorder.none,
//                       hintText: 'Confirm Password',
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10)),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Container(
//               height: 50,
//               width: 350,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(5),
//                 color: MyColors.red,
//               ),
//               child: Center(
//                   child: GestureDetector(
//                 onTap: () {
//                   // if(newPasswordController.text==pro.confirmPasswordController.text){
//                   //   pro.resetpasswordapi(context);
//           //         }else{
//           //            showSnackBar(context, 'Password not matched', MyColors.red,
//           // textcolor: MyColors.white);
//           //         }
//                 },
//                 child: Text(
//                   'CHANGE',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               )),
//             ),
//           ],
//         ));
//   }
// }
