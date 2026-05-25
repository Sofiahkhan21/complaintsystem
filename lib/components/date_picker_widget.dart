import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';
class DatePickerWidget extends StatelessWidget {
 final BoxBorder? border;
  final BorderRadius? borderradius; final String? text; final Function(DateTime)? pickedDate;
  const DatePickerWidget({Key? key,this.border,this.pickedDate,this.text,this.borderradius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
    
      padding: EdgeInsets.only(left: 20, right: 20),
      height: 50,
      decoration: BoxDecoration(
          borderRadius: borderradius,
          color: Colors.grey[300],
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            //child: Text('day-mon-year'),
            child: TextWidget(text:text!,textcolor: MyColors.blue,),
          ),
          InkWell(
            onTap: () async {
              DateTime? date = await showDatePicker(
                  context: context,
                  fieldHintText: 'day-mon-year',
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025));
              if (date != null) {
                pickedDate!(date);

                print(date);
              }
            },
            child: Container(
              child: Icon(Icons.alarm,color: MyColors.blue,),
            ),
          )
        ],
      ),
    );
  }
}