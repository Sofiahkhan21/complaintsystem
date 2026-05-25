import 'package:flutter/material.dart';

class DropdowmWidget extends StatelessWidget {
  final Color? bordercolor;
  final String? hinttext;
  final Function? onchanged;
  final List? list;
  final String? dropdowntext;
  final BoxBorder? border;
  final BorderRadius? borderradius;

  const DropdowmWidget(
      {Key? key,
      this.bordercolor,
      this.hinttext,
      this.list,
      this.onchanged,
      this.dropdowntext,
      this.border,

      this.borderradius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          borderRadius: borderradius,
          border: border,
        ),
        child: DropdownButtonFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          menuMaxHeight: 300,
          decoration: InputDecoration(
              border: InputBorder.none,
              filled: false,
              hintStyle: TextStyle(color: bordercolor),
              hintText: '$hinttext',
              
              fillColor: Colors.white),
          onChanged: (value) => onchanged!(value),
          items: list
              ?.map((valueTitle) => DropdownMenuItem(
                  value: valueTitle,
                  child: Text("${valueTitle[dropdowntext]}")))
              .toList(),
        ));
  }
}
