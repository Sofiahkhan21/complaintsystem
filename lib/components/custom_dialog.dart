import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Function? onTab;
  final String? text;
  final String? action;
  const CustomDialog({Key? key, this.onTab, this.action, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        //title: Text('data'),
        content: Text(
          text!,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          InkWell(
              onTap: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel')),
          TextButton(
              onPressed: () => onTab!(),
              child: Text(
                action!,
                style: TextStyle(),
              )),
        ],
      ),
    );
  }

  actionIcon(IconData) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      child: Icon(
        IconData,
        color: Colors.black,
        size: 25,
      ),
    );
  }
}
