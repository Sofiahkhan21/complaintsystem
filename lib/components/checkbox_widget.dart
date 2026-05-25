import 'package:flutter/material.dart';
class CheckboxWidget extends StatelessWidget {
  final bool? ischecked;
  final Color? bordercolor;
  final Function(bool)? onTab;
  final Color? iconcolor;

  const CheckboxWidget({Key? key,this.bordercolor,this.ischecked,this.iconcolor,this.onTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTab!(ischecked!),
      child: Stack(alignment: Alignment.center, children: [
        Container(
          margin: EdgeInsets.only(right: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(
                  color: bordercolor!)),
          height: 25,
          width: 20,
        ),
        Container(
          height: 30,
          width: 25,
        ),
        if (ischecked!)
          Icon(
            Icons.check,
            color: iconcolor,
          )
      ]),
    );
  }
}