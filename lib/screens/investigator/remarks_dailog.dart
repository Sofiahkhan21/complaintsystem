import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/date_picker_widget.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class RemarksDailog extends StatefulWidget {
  final username;
  final role;
  final phone;
  final authority;
  final id;
  final docid;
  final target;

  const RemarksDailog({
    super.key,
    this.authority,
    this.id,
    this.phone,
    this.role,
    this.username,this.docid,this.target
  });

  @override
  State<RemarksDailog> createState() => _RemarksDailogState();
}

class _RemarksDailogState extends State<RemarksDailog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var remarkController = TextEditingController();
  bool loading = false;
  List meetingList = [];
  addFeedback() async {
    print(widget.docid);
    meetingList = [];
    // if(remarkController.text.isEmpty){
    //   showSnackBar('Enter Remark', context, Colors.red);

    // }
    // if(meeting==true){
    //    if(titleController.text.isEmpty || detailsController.text.isEmpty|| selectDate==null || startingTime==null
    // || endTime==null || chooseList.isEmpty){
    //   showSnackBar('Fill All the Required Fields', context, Colors.red);
    // }

    // }
    if (meeting == true) {
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      meetingList.add({
        "title": titleController.text,
        "date": "${CusDateFormat.getDate(DateTime.now())}",
        'meetingDate': '${CusDateFormat.getdday(selectDate!)}',
        'MeetingTime':
            '${startingTime!.format(context)} to ${endTime!.format(context)}',
        'collaborator': chooseList,
        'meetingDetail': detailsController.text,
        'read': false,
        'timeStamp': timeStamp,
        'docid':widget.docid
      });
      await _firestore.collection('complaint').doc(widget.docid).update({
     
      'meetingList': meetingList,
      
    });
    await _firestore.collection('meetings').doc().set({
   
      "title": titleController.text,
      "date": "${CusDateFormat.getdday(DateTime.now())}",
      'meetingDate':'${CusDateFormat.getdday(selectDate!)}',
      'MeetingTime':'${startingTime!.format(context)} to ${endTime!.format(context)}',
      'collaborator':chooseList,
      'meetingDetail':detailsController.text,
      'read':false,
      'timeStamp':timeStamp


    });
    }

    try {
      setState(() {
        loading = true;
      });
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      for (var pickedFile in _selectedImages) {
        final file = File(pickedFile.path);
        final storageRef =
            FirebaseStorage.instance.ref().child('doc/${file.path}');
        await storageRef.putFile(file);

        // Get the download URL of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }
      await _firestore.collection('feedback').doc().set({
        "id": widget.id,
        "complaintId": widget.id,
        "feedback": remarkController.text,
        "date": "${CusDateFormat.getDate(DateTime.now())}",
        "name": widget.username,
        "role": widget.role,
        "phone": widget.phone,
        "authority": widget.authority,
        "attachment": imageUrls,
        'timeStamp': timeStamp,
        'target':widget.target=='Teacher'?'Teacher': target,
        'meeting': meetingList
      });

      setState(() {
        loading = false;
        meeting = false;
        meetingList.clear();
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        loading = false;
        meeting = false;
      });
      showSnackBar('$e', context, Colors.red);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    List<XFile> pickedImages = await picker
        .pickMultiImage(); // Use pickMultiImage instead of pickImage

    if (pickedImages != null && pickedImages.isNotEmpty) {
      for (var pickedImage in pickedImages) {
        setState(() {
          _selectedImages.add(File(pickedImage.path));
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  List<File> _selectedImages = [];
  List<String> imageUrls = [];
  DateTime today = DateTime.now();
  bool isChooseFileVisible() {
    return _selectedImages.isEmpty;
  }

  bool _isChoosingFile = false;
  List targetList = ['Student', 'Authority'];
  String target = '';
  ////

  var detailsController = TextEditingController();

  DateTime? selectedDateTime;
  String dateTime = '';
  bool isLoading = false;
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
    if (titleController.text.isEmpty ||
        detailsController.text.isEmpty ||
        selectDate == null ||
        startingTime == null ||
        endTime == null ||
        chooseList.isEmpty) {
      showSnackBar('Fill All the Required Fields', context, Colors.red);
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
        await _firestore.collection('meetings').doc().set({
          "title": titleController.text,
          "date": "${CusDateFormat.getDate(DateTime.now())}",
          'meetingDate': '${CusDateFormat.getdday(selectDate!)}',
          'MeetingTime':
              '${startingTime!.format(context)}  to  ${endTime!.format(context)}',
          'collaborator': chooseList,
          'meetingDetail': detailsController.text,
          'read': false,
          'timeStamp': timeStamp
        });
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
        // MyNavigation.pushreplacement(context, Meetings());
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
  String fromTime = '';
  String toTime = '';
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
        fromTime = startingTime!.format(context);
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
        toTime = endTime!.format(context);
      });
    }
  }

  bool meeting = false;
  @override
  Widget build(BuildContext context) {
    print('${widget.authority}lllllllllllllllllll');
    return AlertDialog(
      title: Text('Remark'),
      content: Padding(
        padding: const EdgeInsets.all(1.0).w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              widget.authority == 'ADSA'
                  ? Container(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField(
                            menuMaxHeight: 300,

                            // underline: const SizedBox(),
                            decoration: const InputDecoration(
                              alignLabelWithHint: true,
                              border: InputBorder.none,
                              errorBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                            ),
                            hint: Text(
                              "Feedback to ..",
                              style:
                                  TextStyle(color: MyColors.blue, fontSize: 12),
                            ),
                            isExpanded: true,
                            items: targetList.map((map) {
                              return DropdownMenuItem<String>(
                                  value: map, child: Text(map));
                            }).toList(),
                            onChanged: (val) async {
                              target = val.toString();
                              print(target);

                              setState(() {});
                            }),
                      ),
                    )
                  : Container(),
              SizedBox(height: widget.authority == 'ADSA' ? 10 : 0),
              TextFormField(
                maxLines: 3,
                keyboardType: TextInputType.text,
                controller: remarkController,

                decoration: InputDecoration(
                  hintText: 'Remark details...',
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
                // validator: _validateComplaintDetails,
                //  maxLength: 6,
              ),
              SizedBox(
                height: 10,
              ),
              if (isChooseFileVisible())
                Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: TextButton(
                    onPressed: _isChoosingFile ? null : _pickImage,
                    child: Container(
                      height: 35,
                      // width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(255, 2, 64, 114),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8).w,
                        child: Row(
                          children: [
                            Icon(
                              Icons.file_upload,
                              color: Colors.white,
                            ),
                            Text(
                              'Choose File',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Visibility(
                visible: _selectedImages.isNotEmpty,
                child: Wrap(
                  children: [
                    for (int index = 0; index < _selectedImages.length; index++)
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Image.file(
                              _selectedImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                _removeImage(index);
                              },
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: Colors.grey[200],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              widget.authority == 'Investigator' && meeting == true
                  ? Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
                              pickedDate: (date) {
                                FocusManager.instance.primaryFocus!.unfocus();

                                setState(() {
                                  selectDate = date;
                                });
                              },
                              border: Border.all(),
                              borderradius: BorderRadius.circular(15)),
                        ),
                        Row(
                          children: [
                            // Container(
                            //     alignment: Alignment.center,

                            //   margin: EdgeInsets.only(left: 25),
                            //   child: TextWidget(text: 'Time:',size: 16,fontWeight: FontWeight.bold,textcolor: MyColors.blue,)),
                            Container(
                              height: 45,
                              width: 95,
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                  startTime();
                                },
                                child: TextWidget(
                                  text: startingTime == null
                                      ? ' From'
                                      : startingTime!.format(context),
                                ),
                              ),
                            ),
                            TextWidget(
                              text: 'to',
                              size: 14,
                              fontWeight: FontWeight.normal,
                              textcolor: MyColors.black,
                            ),
                            Container(
                              height: 45,
                              width: 95,
                              alignment: Alignment.center,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  FocusManager.instance.primaryFocus!.unfocus();
                                  endedTime();
                                },
                                child: TextWidget(
                                  text: endTime == null
                                      ? 'To'
                                      : endTime!.format(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
                        Container(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  meeting = false;
                                });
                              },
                              child: Container(
                                  color: MyColors.blue,
                                  padding: EdgeInsets.only(left: 7, right: 7),
                                  margin: EdgeInsets.only(right: 10, top: 20),
                                  child: TextWidget(
                                    text: 'Close',
                                    textcolor: MyColors.grey,
                                  ))),
                        ),
                        SizedBox(
                          height: 2.h,
                        ),
                      ],
                    )
                  : Container(),
              widget.authority == 'Investigator' && meeting == false
                  ? Container(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              meeting = true;
                            });
                          },
                          child: Container(
                              margin: EdgeInsets.only(right: 10, top: 20),
                              child: TextWidget(
                                text: 'Add Meeting',
                              ))),
                    )
                  : Container()
            ],
          ),

          // textAlign: TextAlign.left,
        ),
      ),
      actions: [
        TextButton(
          style:
              ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: TextWidget(
            text: 'Cancle',
            textcolor: Colors.white,
          ),
        ),
        loading
            ? CircularProgressIndicator(
                color: MyColors.blue,
              )
            : TextButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.amber)),
                onPressed: () async {
                  // getuserList(  docId,
                  //   document['subject'],
                  //   document[
                  //       'complaintDetail']);

                  addFeedback();
                },
                child: TextWidget(
                  text: 'Send',
                  textcolor: Colors.white,
                ),
              ),
      ],
    );
  }
}
