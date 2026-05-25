import 'package:flutter/material.dart';

class CardText extends StatelessWidget {
  final String? text;
  final double? size;
  final FontWeight? fontWeight;
  final Color? textcolor;
  final double? width;
  final BoxBorder? border;
  const CardText({Key? key,this.size, this.text, this.fontWeight, this.textcolor,this.width,this.border}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      //margin: EdgeInsets.only(top: 5),
     padding: EdgeInsets.only(left: 10,right: 10,top: 7,bottom: 7),
      decoration: BoxDecoration(
      
        // color: MyColors.white,
        border: border,
       
      ),
      child: Text(
        
        '$text',maxLines: 1,
        style:
            TextStyle(color: textcolor, fontSize: size, fontWeight: fontWeight),
      ),
    );
  }
}