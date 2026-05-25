import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/date_picker_widget.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/screens/investigator/meetings.dart';
import 'package:complaintsystem/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddMeeting extends StatefulWidget {
  const AddMeeting({super.key});

  @override
  State<AddMeeting> createState() => _AddMeetingState();
}

class _AddMeetingState extends State<AddMeeting> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var detailsController=TextEditingController();

  DateTime? selectedDateTime;
  String dateTime = '';
  bool isLoading=false;
  var titleController = TextEditingController();
  // Method to pick date and time
  Future<void> _pickDateTime() async {
    // Pick date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return; // If date picker is canceled

    // Pick time after picking date
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return; // If time picker is canceled

    // Combine date and time into a single DateTime object
    DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      selectedDateTime = finalDateTime;
      dateTime = '${DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)}';
    });
    print(selectedDateTime);
    print('$finalDateTime ????????????');
  }

  List roleList = ["ADSA", "HOD", "Deen", "Registrar", "VC"];
  List chooseList = [];
  addMett() async {
    if(titleController.text.isEmpty || detailsController.text.isEmpty|| selectDate==null || startingTime==null
    || endTime==null || chooseList.isEmpty){
      showSnackBar('Fill All the Required Fields', context, Colors.red);
    }else{
           setState(() {
      isLoading=true;
    });
      try {
     
     String timeStamp = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
    await _firestore.collection('meetings').doc().set({
   
      "title": titleController.text,
      "date": "${CusDateFormat.getdday(DateTime.now())}",
      'meetingDate':'${CusDateFormat.getdday(selectDate!)}',
      'MeetingTime':'${startingTime!.format(context)}  to  ${endTime!.format(context)}',
      'collaborator':chooseList,
      'meetingDetail':detailsController.text,
      'read':false,
      'timeStamp':timeStamp


    });
     setState(() {
      isLoading=false;
    });
    Navigator.pop(context);
    MyNavigation.pushreplacement(context, Meetings());
        
      } catch (e) {
      showSnackBar('$e', context, Colors.red);

        
      }
    }
  
  }
   String? _validateComplaintDetails(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your Meeting details';
    }
  }
  DateTime? selectDate;
  String fromTime='';
  String toTime='';

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: TextWidget(text: 'Add Meeting',textcolor: Colors.white,)),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 15,horizontal: 5),
          child: Card(
            child: Column(
             // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: titleController,
                    decoration: InputDecoration(
                      filled: true,
                      isDense: true,
                      hintText: 'Meeting title',
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        color: Color.fromARGB(255, 2, 64, 114),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.grey[300],
                    ),
                    //  validator: _validateCpliant,
                    
                    // maxLength: 20,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                  Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: DatePickerWidget(
                              text: selectDate == null
                                  ? 'Set Meeting date'
                                  : '${CusDateFormat.getdday(selectDate!)}',
                              pickedDate: (date) => setState(() {
                                    selectDate = date;
                                  }),
                              border: Border.all(),
                              borderradius: BorderRadius.circular(15)),
                        ),
                Row(
                  children: [
                    Container(
                        alignment: Alignment.center,

                      margin: EdgeInsets.only(left: 25),
                      child: TextWidget(text: 'Time:',size: 16,fontWeight: FontWeight.bold,textcolor: MyColors.blue,)),
                    Container(
                      height: 50,
                      width: 100,
                      alignment: Alignment.center,

                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          startTime();
                        },
                        child:  TextWidget(
                        text: startingTime == null ? ' From' : startingTime!.format(context),
                      ),
                      ),
                    ),
                    TextWidget(text: 'to',size: 14,fontWeight: FontWeight.normal,textcolor: MyColors.black,),
                     Container(
                      height: 50,
                      width: 100,

                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          endedTime();
                        },
                        child:  TextWidget(
                        text: endTime == null ? 'To' : endTime!.format(context),
                      ),
                      ),
                    ),
                  ],
                ),
                 Padding(
                          padding:  EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: SingleChildScrollView(
                            child: TextFormField(
                              maxLines: 5,
                              keyboardType: TextInputType.text,
                              controller: detailsController,

                              decoration: InputDecoration(
                                hintText: 'Meeting details...',
                                hintStyle: TextStyle(
                                  fontSize: 12.sp,
                                  color: Color.fromARGB(255, 2, 64, 114),
                                ),
                                filled: true,
                                isDense: true,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(15).w),
                                fillColor: Colors.grey[300],
                              ),
                              validator: _validateComplaintDetails,
                              //  maxLength: 6,
                            ),

                            // textAlign: TextAlign.left,
                          ),
                        ),
                  SizedBox(
                        height: 2.h,
                      ),
                Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
             padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      TextWidget(
                        text: 'Select Collaborator',size: 16,fontWeight: FontWeight.w500,textcolor: MyColors.blue,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: roleList
                            .map((header) => GestureDetector(
                                  onTap: () {
                                    if (chooseList.contains(header)) {
                                      chooseList.remove(header);
                                    } else {
                                      chooseList.add(header);
                                    }
                                    print(chooseList);
                    
                                    // var list=item['unit'];
                                    // if(prodCollection.containsKey(val[header])){
                                    //   prodCollection.remove(val[header]);
                                    // }else{
                                    //   prodCollection.addAll(val[header]);
                                    // }
                    
                                    setState(() {});
                                    // print(list);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: chooseList.contains(header)
                                                    ? MyColors.blue
                                                    : Colors.transparent,
                                                border:
                                                    Border.all(color: Colors.grey),
                                                //  borderRadius: BorderRadius.circular(10),
                                                shape: BoxShape.circle),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Container(
                                            child: TextWidget(
                                              text: header,
                                              size: 11.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                 SizedBox(height: 30.h),
                            isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () {
                                      addMett();
                                    
                                    },
                                    child: Text('Submit'),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Color.fromARGB(255, 2, 64, 114),
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                    ),
                                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 TimeOfDay? startingTime;
 TimeOfDay? endTime;


  // Method to show the time picker dialog
  Future<void> startTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != startingTime) {
      setState(() {
        startingTime = picked;
        fromTime=startingTime!.format(context);
      });
    }
  }
   Future<void> endedTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;
        toTime=endTime!.format(context);
      });
    }
  }
  sizeCont({onTab, text, color}) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onTab(),
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.grey),
                //  borderRadius: BorderRadius.circular(10),
                shape: BoxShape.circle),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Container(
          child: TextWidget(
            text: text,
            size: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
