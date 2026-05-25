import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final Color? bordercolor;
  final TextInputType? keyboardtype;
  final TextEditingController? controller;
  final String? hinttext;
  final Color? hintcolor;
  final double? height;
  final double? width;
  final Color? bgcolor;
  final BoxBorder? border;
  final BorderRadius? borderradius;
  final Function(String)? onChanged;
  final IconData? prefixicon;
  final IconData? suffixicon;
  final Color? precolor;
  final Color? sufcolor;
  final bool? secure;
  final Function? validator;
  final Function? sufixFunction;
  final InputBorder? inputBorder;
  final Color? textcolor;
  final int maxLines;
  final bool? read;

  const TextFieldWidget(
      {Key? key,
      this.bgcolor,
      this.border,
      this.bordercolor = Colors.transparent,
      this.borderradius,
      this.controller,
      this.height,
      this.hintcolor,
      this.hinttext,
      this.keyboardtype,
      this.width,
      this.onChanged,
      this.precolor,
      this.prefixicon,
      this.sufcolor,
      this.suffixicon,
      this.secure = false,
      this.validator,
      this.sufixFunction,
      this.inputBorder,
      this.textcolor,
      this.read,
      this.maxLines = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderradius,
      ),
      child: TextFormField(
        readOnly: read!,
        autocorrect: false,
        maxLines: maxLines,
        enableSuggestions: false,
        obscureText: secure!,
        keyboardType: keyboardtype,
        controller: controller,
        style: TextStyle(color: textcolor),
        validator: (value) => validator!(value),
        cursorColor: Colors.black,
        obscuringCharacter: '*',
        decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2)),
          // prefixIcon: Icon(
          //   prefixicon,
          //   color: precolor,
          // ),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2)),

          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2)),

          suffixIcon: GestureDetector(
            onTap: () => sufixFunction!(),
            child: Icon(
              suffixicon,
              color: sufcolor,
            ),
          ),
          isDense: true,
          counterText: "",
          contentPadding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
          hintText: '$hinttext',
          hintStyle: TextStyle(color: hintcolor, fontSize: 15),
        ),
        onChanged: (value) {
          onChanged!(value);
        },
      ),
    );
  }
}
