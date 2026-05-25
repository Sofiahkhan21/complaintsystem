import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/navigation.dart';

import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:complaintsystem/screens/investigator/view_attach.dart';
import 'package:complaintsystem/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserComplaint extends StatefulWidget {
  const UserComplaint({
    super.key,
  });

  @override
  State<UserComplaint> createState() => _UserComplaintState();
}

class _UserComplaintState extends State<UserComplaint> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var feedbackcontroller = TextEditingController();
  NotifcationHelper notifcationHelper = NotifcationHelper();

  String? selected;
  String? selectedhint;

  String? username;
  String? role;
  String? phone;

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    phone = prefs.getString('phone');
    print(phone);

    setState(() {});
    // print(getChannel());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    feedbackcontroller.clear();
  }

  addFeedback(cId, fid) async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('feedback').doc().set({
      "id": "$cId",
      "complaintId": cId,
      "feedback": feedbackcontroller.text,
      "date": "${CusDateFormat.getDate(DateTime.now())}",
      "name": username,
      "role": role == 'User' ? "Student" : role,
      "phone": phone,
      "authority": "",
      'target': 'Student',
       "attachment": [],
        'timeStamp': timeStamp,
       
        'meeting': []
      
    });
    Navigator.pop(context);
  }

  List mainList = [];
  TextEditingController searchController = TextEditingController();
  List filterList = [];
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ComplaintProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 64, 114),
          title: GestureDetector(
            onTap: () {
              final now = DateTime.now();
              final yesterday = now.subtract(const Duration(days: 15));
              final yesday = DateTime.now().add(const Duration(days: 15));

              print(yesterday);
              print(
                  '${CusDateFormat.getDate(DateTime.now().add(const Duration(days: 15)))}');
            },
            child: Text(
              'My complaints',
              style: TextStyle(color: Colors.white),
            ),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('complaint')
              .where('name', isEqualTo: username)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                  child: TextWidget(
                text: 'No Data Found',
                size: 18,
              ));
            }
            mainList = snapshot.data!.docs;
            print(mainList.length);
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    // height: 50,
                    child: Container(
                      height: 45,
                      padding: EdgeInsets.only(
                          left: 5, top: 4, bottom: 4, right: 20),
                      decoration: BoxDecoration(
                          //  borderRadius: BorderRadius.circular(10),
                          border:
                              Border(bottom: BorderSide(color: Colors.black))),
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: TextFormField(
                        cursorColor: Colors.black,
                        controller: searchController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search here .........',
                            hintStyle: TextStyle(color: MyColors.blue),
                            suffixIcon: GestureDetector(
                                onTap: isSearching
                                    ? () {
                                        searchController.clear();
                                        setState(() {
                                          isSearching = false;
                                        });
                                      }
                                    : () {
                                        setState(() {
                                          isSearching = true;
                                          filterList.clear();
                                        });
                                        List filtered = mainList
                                            .where((item) =>
                                                '${item['name']}'
                                                    .toLowerCase()
                                                    .contains(searchController
                                                        .text
                                                        .toLowerCase()) ||
                                                '${item['id']}'
                                                    .toLowerCase()
                                                    .contains(searchController
                                                        .text
                                                        .toLowerCase()) ||
                                                '${item['category']}'
                                                    .toLowerCase()
                                                    .contains(searchController.text
                                                        .toLowerCase()) ||
                                                '${item['status']}'
                                                    .toLowerCase()
                                                    .contains(searchController.text
                                                        .toLowerCase()) ||
                                                '${item['priority']}'
                                                    .toLowerCase()
                                                    .contains(searchController.text.toLowerCase()))
                                            .toList();
                                        print(
                                            '{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{');
                                        print(filtered);
                                        setState(() {
                                          filterList = filtered;
                                        });
                                        print(filterList.length);
                                      },
                                child: Icon(
                                  isSearching ? Icons.close : Icons.search,
                                  size: 30,
                                  color: MyColors.blue,
                                ))),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 170,
                    child: ListView.builder(
                      itemCount:
                          isSearching ? filterList.length : mainList.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot id = snapshot.data!.docs[index];
                        String docId = id.id;
                        DocumentSnapshot document =
                            isSearching ? filterList[index] : mainList[index];
                        // Use the document data to populate your ListView items
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget(
                                                  text: 'Status: ',
                                                  size: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                TextWidget(
                                                  text: document['status'],
                                                  textcolor: document[
                                                              'status'] ==
                                                          'Open'
                                                      ? Colors.green
                                                      : document['status'] ==
                                                              'Is Process'
                                                          ? Colors.orange
                                                          : Colors.red,
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'Priority:',
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  TextWidget(
                                                    text: document['priority'],
                                                    size: 15,
                                                    fontWeight: FontWeight.bold,
                                                    textcolor: document[
                                                                'priority'] ==
                                                            'High'
                                                        ? Colors.red
                                                        : document['priority'] ==
                                                                'Medium'
                                                            ? Colors.green
                                                            : Colors.orange,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Container(
                                        //     padding: EdgeInsets.all(2),
                                        //     decoration: BoxDecoration(
                                        //         color: Colors.orange,
                                        //         borderRadius: BorderRadius.circular(10)),
                                        //     child: TextWidget(
                                        //       text: 'Status: Open',
                                        //       textcolor: Colors.white,
                                        //     )),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget(
                                              text: document['subject'],
                                              fontWeight: FontWeight.bold,
                                              size: 17,
                                            ),
                                            // TextButton(
                                            //     onPressed: () {
                                            //       showDialog(
                                            //           context: context,
                                            //           builder: (BuildContext context) {
                                            //             return AlertDialog(
                                            //               title: Text('Reminder'),
                                            //               content: Text(
                                            //                   document['complaintDetail']),
                                            //               actions: [
                                            //                 TextButton(
                                            //                   onPressed: () {
                                            //                     notifcationHelper.scheduleReminder();
                                            //                     Navigator.of(context).pop();
                                            //                   },
                                            //                   child: Text('Close'),
                                            //                 ),
                                            //               ],
                                            //             );
                                            //           });
                                            //     },
                                            //     child: TextWidget(
                                            //       text: 'set Reminder',
                                            //       textcolor: Colors.blue,
                                            //     ))
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.red,
                                            ),
                                            TextWidget(
                                              text: document['address'],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 7),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text: document['name'],
                                                fontWeight: FontWeight.bold,
                                                size: 17,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              TextWidget(
                                                text: document['date'],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              TextWidget(
                                                text: 'ID: ${document['id']}',
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              TextWidget(
                                                text:
                                                    'Contact: ${document['contact']}',
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'Complaint Type: ',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  TextWidget(
                                                    text: document['category'],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'Department: ',
                                                    fontWeight: FontWeight.w500,
                                                    textcolor: Colors.black,
                                                  ),
                                                  TextWidget(
                                                    text:
                                                        document['department'],
                                                    textcolor: Colors.black,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'Assign To: ',
                                                    fontWeight: FontWeight.w500,
                                                    textcolor: Colors.black,
                                                  ),
                                                  TextWidget(
                                                    text:
                                                        '${document['authority']}(Authority)',
                                                    textcolor: Colors.black,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height:
                                                    document['forword'] ? 5 : 0,
                                              ),
                                              document['forword']
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Forword To: ',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          textcolor:
                                                              Colors.black,
                                                        ),
                                                        TextWidget(
                                                          text:
                                                              '${document['forwordTo']}',
                                                          textcolor:
                                                              Colors.black,
                                                        ),
                                                      ],
                                                    )
                                                  : Container(
                                                      width: 0,
                                                    ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          child: (document['attachment']
                                                      as List)
                                                  .isEmpty
                                              ? Container()
                                              : GestureDetector(
                                                  onTap: () {
                                                    MyNavigation.push(
                                                        context,
                                                        ViewAttach(
                                                          attachList: document[
                                                              'attachment'],
                                                        ));
                                                  },
                                                  child: Row(
                                                    children: [
                                                      TextWidget(
                                                        text: 'View Attachment',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          // MyNavigation.push(
                                                          //     context,
                                                          //     ViewAttach(
                                                          //       attachList: document[
                                                          //           'attachment'],
                                                          //     ));
                                                        },
                                                        child: Icon(
                                                          Icons.attachment,
                                                          color: MyColors.blue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 5, right: 5),
                                          color: Colors.white,
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Theme(
                                            data: ThemeData(
                                                dividerColor:
                                                    Colors.transparent),
                                            child: ExpansionTile(
                                              tilePadding: EdgeInsets.zero,
                                              childrenPadding: EdgeInsets.zero,
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'Compalint Detail',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                              children: [
                                                Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(document[
                                                      'complaintDetail']),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 5, right: 5),
                                          color: Colors.white,
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Theme(
                                            data: ThemeData(
                                                dividerColor:
                                                    Colors.transparent),
                                            child: ExpansionTile(
                                              tilePadding: EdgeInsets.zero,
                                              childrenPadding: EdgeInsets.zero,
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'Status Track',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                              children: [
                                                Container(
                                                  height: 40,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        (document['assignList']
                                                                as List)
                                                            .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var data =
                                                          document['assignList']
                                                              [index];
                                                      return Container(
                                                        child: 
                                                        data['sender'] ==
                                                                'Student'
                                                            ? Row(
                                                                children: [
                                                                  TextWidget(
                                                                    text:
                                                                        'ADSA',
                                                                    size: 15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                  // Icon(Icons.arrow_forward,size: 20,),
                                                                  // SizedBox(width: 5,),
                                                                ],
                                                              )
                                                            : 
                                                            Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward,
                                                                    size: 20,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  TextWidget(
                                                                    text:
                                                                        '${data['receiver']}',
                                                                    size: 15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ],
                                                              ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 5, right: 5),
                                          color: Colors.white,
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: Theme(
                                            data: ThemeData(
                                                dividerColor:
                                                    Colors.transparent),
                                            child: ExpansionTile(
                                              tilePadding: EdgeInsets.zero,
                                              childrenPadding: EdgeInsets.zero,
                                              title: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'View Feedback',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                              children: [
                                                Container(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: snapshot.data!
                                                                .docs.isEmpty
                                                            ? 60
                                                            : 200,
                                                        child: StreamBuilder(
                                                          stream: _firestore
                                                              .collection(
                                                                  'feedback')
                                                              .where(
                                                                  'complaintId',
                                                                  isEqualTo:
                                                                      document[
                                                                          'id'])
                                                              .where('target',
                                                                  isEqualTo:
                                                                      'Student')
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return snapshot
                                                                      .data!
                                                                      .docs
                                                                      .isEmpty
                                                                  ? Container(
                                                                      height: 0,
                                                                    )
                                                                  : ListView
                                                                      .builder(
                                                                          itemCount: snapshot
                                                                              .data!
                                                                              .docs
                                                                              .length,
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            var item2 =
                                                                                snapshot.data!.docs[index];
                                                                            if (item2['complaintId'] ==
                                                                                document['id']) {
                                                                              return Container(
                                                                                margin: EdgeInsets.only(top: 15),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Container(
                                                                                          alignment: Alignment.center,
                                                                                          padding: EdgeInsets.all(3),
                                                                                          decoration: BoxDecoration(shape: BoxShape.circle, color: MyColors.lightblue),
                                                                                          height: 35,
                                                                                          width: 55,
                                                                                          child: TextWidget(text: '${item2['name']}' == username ? 'you' : '${item2['authority']}', size: 12, textoverflow: TextOverflow.ellipsis),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: 10,
                                                                                        ),
                                                                                        Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Container(
                                                                                              width: MediaQuery.of(context).size.width - 165,
                                                                                              child: Text(
                                                                                                '${item2['feedback']}',
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 5,
                                                                                            ),
                                                                                            Container(
                                                                                              alignment: Alignment.bottomRight,
                                                                                              child: TextWidget(
                                                                                                text: '${item2['date']}',
                                                                                                textcolor: MyColors.blue,
                                                                                                size: 12,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    Container(
                                                                                      child: (item2['attachment'] as List).isEmpty
                                                                                          ? Container()
                                                                                          : GestureDetector(
                                                                                              onTap: () {
                                                                                                MyNavigation.push(
                                                                                                    context,
                                                                                                    ViewAttach(
                                                                                                      attachList: item2['attachment'],
                                                                                                    ));
                                                                                              },
                                                                                              child: Icon(
                                                                                                Icons.file_copy_outlined,
                                                                                                color: MyColors.blue,
                                                                                              ),
                                                                                            ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              return Container(
                                                                                height: 0,
                                                                              );
                                                                            }
                                                                          });
                                                            } else {
                                                              return Center(
                                                                  child:
                                                                      CircularProgressIndicator());
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  // title: Text('Feedback'),
                                                                  content:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                            8.0)
                                                                        .w,
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          TextFormField(
                                                                        maxLines:
                                                                            3,
                                                                        keyboardType:
                                                                            TextInputType.text,
                                                                        controller:
                                                                            feedbackcontroller,

                                                                        decoration:
                                                                            InputDecoration(
                                                                          hintText:
                                                                              'Feedback...',
                                                                          hintStyle:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                12.sp,
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                2,
                                                                                64,
                                                                                114),
                                                                          ),
                                                                          filled:
                                                                              true,
                                                                          isDense:
                                                                              true,
                                                                          border: OutlineInputBorder(
                                                                              borderSide: BorderSide.none,
                                                                              borderRadius: BorderRadius.circular(15).w),
                                                                          fillColor:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        // validator: _validateComplaintDetails,
                                                                        //  maxLength: 6,
                                                                      ),

                                                                      // textAlign: TextAlign.left,
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: Text(
                                                                          'Close'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        addFeedback(
                                                                            document['id'],
                                                                            index);
                                                                      },
                                                                      child: Text(
                                                                          'Add'),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            width: 100,
                                                            color:
                                                                MyColors.blue,
                                                            child: TextWidget(
                                                              text:
                                                                  'Add Feedback',
                                                              size: 13,
                                                              textcolor:
                                                                  MyColors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ));
  }
}
