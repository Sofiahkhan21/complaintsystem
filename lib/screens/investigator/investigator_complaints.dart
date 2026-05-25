import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:complaintsystem/screens/investigator/remarks_dailog.dart';
import 'package:complaintsystem/screens/investigator/view_attach.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvestigatorComplaints extends StatefulWidget {
  const InvestigatorComplaints({super.key});

  @override
  State<InvestigatorComplaints> createState() => _InvestigatorComplaintsState();
}

class _InvestigatorComplaintsState extends State<InvestigatorComplaints> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var remarkController = TextEditingController();

  String? selected;
  String? adminrole;
  String? username;
  String? authority;
  String? phone;

  List<String> Statuses = [
    'Open',
    'In Process',
    'Closed',
  ];
  void Movedoc(String docname, docid, DocumentSnapshot document) {
    setState(() {});
  }

  getdata() async {
    SharedPreferences getPrefs = await SharedPreferences.getInstance();

    phone = await getPrefs.getString('phone');
    username = await getPrefs.getString('username');
    authority = await getPrefs.getString('role');
    print('$authority####@@authority');

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    getAuthority();
    // getuser();
  }

  List authoList = [];
  String selectval = '';
  Future<void> reportComplaint(title, deatail) async {
    String response = "Sending.....";
    await Provider.of<ComplaintProvider>(context, listen: false)
        .reportComplaint(
            body: deatail,
            id: 'investigator',
            title: '$title',
            userList: userList);

    setState(() {});
  }

  List userList = [];
  getuserList(id, title, detail, assignto) async {
    userList = [];
    FirebaseFirestore.instance
        .collection("complaint_token")
        .where('role', isEqualTo: "Authority")
        .where('authority', isEqualTo: assignto)
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {
        userList.add(doc[i]['noti_token']);
        // }
      }
    });
    await _firestore
        .collection('complaint')
        .doc(id)
        .update({'final': true, 'investigatorRemark': remarkController.text});
    setState(() {});
    reportComplaint(title, detail);
  }

  getAuthority() async {
    assignList = [];
    print('hellooooooooooooooooooooooooooooooooo');
    FirebaseFirestore.instance
        .collection("Offices")
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        print(doc[i]['name']);
        if (doc[i]['name'] != authority) {
          assignList.add(doc[i]['name']);
        }
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {

        // }
      }
      setState(() {});
    });
    print(authoList);
    setState(() {});
  }

  List assignList = [];
  String assignval = '';
  sendAssignList(id, title, detail) async {
    userList = [];
    var forwd;
    if (assignval == 'HOD') {
      setState(() {
        forwd = 'HOD';
      });
    }
    if (assignval == 'ADSA') {
      setState(() {
        forwd = 'ADSA';
      });
    }
    if (assignval == 'Registerar') {
      setState(() {
        forwd = 'Registerar';
      });
    }
    if (assignval == 'VC') {
      setState(() {
        forwd = 'VC';
      });
    }
    if (assignval == 'Deen') {
      setState(() {
        forwd = 'Deen';
      });
    }
    if (assignval == 'Investigator') {
      setState(() {
        forwd = 'Investigator';
      });
    }

    Map<String, dynamic> assignList = {
      'sender': authority,
      'receiver': assignval,
    };
    print('$forwd ////////////////////');
    await _firestore.collection('complaint').doc(id).update({
      'forword': true,
      'assignList': FieldValue.arrayUnion([assignList]),
      'assignto': 'assigned',
      'forwordTo': '$assignval',
      '$forwd': true,
      'assign$assignval': authority,
      'forword$assignval': assignval
    });
    print('send');
    setState(() {});
    FirebaseFirestore.instance
        .collection("complaint_token")
        .where('role', isEqualTo: "Authority")
        .where('authority', isEqualTo: assignval)
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {
        userList.add(doc[i]['noti_token']);
        // }
      }
    });

    setState(() {});
    reportComplaint(title, detail);
  }

  List mainList = [];
  TextEditingController searchController = TextEditingController();
  List filterList = [];
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    print(username);
    var provider = Provider.of<ComplaintProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 64, 114),
          title: Text(
            'Complaints',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('complaint')
              .orderBy('priorityValue', descending: true)
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
                        print('$authority mmmmmmmmmmmmmmmmmmm');
                        var sender;
                        var receiver;
                        for (var i = 0;
                            i < (document['assignList'] as List).length;
                            i++) {
                          var item = document['assignList'][i];
                          print('$authority >>>>>>>>>>>>>');

                          if (item['sender'] == "Investigator") {
                            receiver = item['receiver'];

                            //  print('$receiver >>>>>>>>>>>>>');
                          }
                          if (item['receiver'] == "Investigator") {
                            print('${item['sender']} ////////////////');
                            sender = item['sender'];
                          }
                        }

                        return document['$authority'] == true
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10)
                                    .w,
                                child: Card(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20).w,
                                                topRight: Radius.circular(20).w,
                                                bottomLeft:
                                                    Radius.circular(15).w,
                                                bottomRight:
                                                    Radius.circular(15))
                                            .w),
                                    padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 20)
                                        .w,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextWidget(
                                                  text: 'Status: ',
                                                  size: 18,
                                                  fontWeight: FontWeight.bold,
                                                  textcolor: Colors.black,
                                                ),
                                                Container(
                                                  height: 35.h,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                                20)
                                                            .w,
                                                    //  color: Colors.grey[200],
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                          horizontal: 5)
                                                      .w,
                                                  child: DropdownButton<String>(
                                                    onChanged: (String?
                                                        newValue) async {
                                                      setState(() {
                                                        selected = newValue!;
                                                      });
                                                      print(selected);

                                                      await _firestore
                                                          .collection(
                                                              'complaint')
                                                          .doc(docId)
                                                          .update({
                                                        "status": selected,
                                                        // "id": document["id"],
                                                        // "subject": document['subject'],
                                                        // "category": document['category'],
                                                        // "complaintDetail":
                                                        //     document['complaintDetail'],
                                                        // "attachment": document['attachment'],
                                                        // "contact": document['contact'],
                                                        // "date": document['date'],
                                                        // "name": document['name'],
                                                        // "address": document['address'],

                                                        // 'office': document['office'],
                                                        // 'department': document['department']
                                                      });

                                                      provider.getdata();
                                                    },
                                                    items: Statuses.map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                      (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      },
                                                    ).toList(),
                                                    icon: Icon(
                                                        Icons.arrow_drop_down),
                                                    hint: Text(
                                                      document['status']
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: document['status']
                                                                      .toString() ==
                                                                  'Open'
                                                              ? Colors.green
                                                              : document['status']
                                                                          .toString() ==
                                                                      'In Process'
                                                                  ? Colors
                                                                      .orange
                                                                  : Colors.red),
                                                    ),
                                                    underline: Container(),
                                                  ),
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

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextWidget(
                                              text: document['subject'],
                                              fontWeight: FontWeight.bold,
                                              size: 17,
                                              textcolor: Colors.black,
                                            ),
                                            Container(
                                              width: 100,

                                              //  margin: EdgeInsets.all(8),
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 3),
                                              decoration: BoxDecoration(
                                                color: receiver != null
                                                    ? MyColors.blue
                                                    : MyColors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: receiver != null
                                                  ? TextWidget(
                                                      text: 'Forworded',
                                                      textcolor: MyColors.grey,
                                                    )
                                                  : DropdownButtonHideUnderline(
                                                      child:
                                                          DropdownButtonFormField(
                                                              menuMaxHeight:
                                                                  300,

                                                              // underline: const SizedBox(),
                                                              decoration:
                                                                  const InputDecoration(
                                                                alignLabelWithHint:
                                                                    true,
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                errorBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.transparent),
                                                                ),
                                                              ),
                                                              hint: Text(
                                                                  "Forword to .."),
                                                              isExpanded: true,
                                                              items: assignList
                                                                  .map((map) {
                                                                return DropdownMenuItem<
                                                                        String>(
                                                                    value: map,
                                                                    child: Text(
                                                                        map));
                                                              }).toList(),
                                                              onChanged:
                                                                  (val) async {
                                                                assignval = val
                                                                    .toString();
                                                                print(
                                                                    assignval);

                                                                sendAssignList(
                                                                    docId,
                                                                    document[
                                                                        'subject'],
                                                                    document[
                                                                        'complaintDetail']);
                                                                setState(() {});
                                                              }),
                                                    ),
                                            ),
                                          ],
                                        ),
                                        // Row(
                                        //   mainAxisAlignment: MainAxisAlignment.start,
                                        //   children: [
                                        //     Icon(
                                        //       Icons.location_on_outlined,
                                        //       color: Colors.red,
                                        //     ),
                                        //     TextWidget(
                                        //       text: document['address'],
                                        //       textcolor: Colors.black,
                                        //     ),
                                        //   ],
                                        // ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 7).w,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // TextWidget(
                                              //   text: document['name'],
                                              //   fontWeight: FontWeight.bold,
                                              //   size: 17,
                                              //   textcolor: Colors.black,
                                              // ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              TextWidget(
                                                text: document['date'],
                                                textcolor: Colors.black,
                                              ),
                                              SizedBox(
                                                height: 5.h,
                                              ),
                                              // TextWidget(
                                              //   text: 'ID: ${document['id']}',
                                              //   textcolor: Colors.black,
                                              // ),

                                              // SizedBox(
                                              //   height: 5.h,
                                              // ),
                                              //  TextWidget(
                                              //         text: 'Contact: ${document['contact']}',
                                              //       ),
                                              //       SizedBox(
                                              //         height: 5,
                                              //       ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'Complaint Type: ',
                                                    fontWeight: FontWeight.w500,
                                                    textcolor: Colors.black,
                                                  ),
                                                  TextWidget(
                                                    text: document['category'],
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
                                                    text: document['faculty'] ==
                                                            'User'
                                                        ? 'Department: '
                                                        : 'Faculty: ',
                                                    fontWeight: FontWeight.w500,
                                                    textcolor: Colors.black,
                                                  ),
                                                  TextWidget(
                                                    text: document['faculty'] ==
                                                            'User'
                                                        ? document['department']
                                                        : document['faculty'],
                                                    textcolor: Colors.black,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height:
                                                    document['forword'] ? 5 : 0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: 'From: ',
                                                    fontWeight: FontWeight.w500,
                                                    textcolor: Colors.black,
                                                  ),
                                                  TextWidget(
                                                    text: sender,
                                                    //  authority == 'ADSA' &&
                                                    //         document['faculty'] ==
                                                    //             'User'
                                                    //     ? 'Student'
                                                    //     : '${document['assignto']}' ==
                                                    //                 ''
                                                    //         ? '${document['sender']}'
                                                    //         : '${document['assign$authority']}',
                                                    textcolor: Colors.black,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height:
                                                    receiver != null ? 5 : 0,
                                              ),
                                              // sender==authority
                                              //     ?
                                              receiver != null
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
                                                          text: '$receiver',
                                                          textcolor:
                                                              Colors.black,
                                                        ),
                                                      ],
                                                    )
                                                  : Container(
                                                      width: 0,
                                                    ),
                                              // SizedBox(
                                              //   height: document['forword'] ? 5 : 0,
                                              // ),
                                              // document['forword']
                                              //     ? Row(
                                              //         mainAxisAlignment:
                                              //             MainAxisAlignment.start,
                                              //         children: [
                                              //           TextWidget(
                                              //             text: 'Remark: ',
                                              //             fontWeight: FontWeight.w500,
                                              //             textcolor: Colors.black,
                                              //           ),
                                              //           TextWidget(
                                              //             text:
                                              //                 '${document['teamRemark']}(you)',
                                              //             textcolor: Colors.black,
                                              //           ),
                                              //         ],
                                              //       )
                                              //     : Container(
                                              //         width: 0,
                                              //       ),
                                              SizedBox(
                                                height:
                                                    document['final'] ? 5 : 0,
                                              ),
                                              document['final']
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Remark: ',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          textcolor: Colors.red,
                                                        ),
                                                        TextWidget(
                                                          text:
                                                              '${document['investigatorRemark']}(Investigator)',
                                                          textcolor: Colors.red,
                                                        ),
                                                      ],
                                                    )
                                                  : Container(
                                                      width: 0,
                                                    ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                color: Colors.white,
                                                child: Theme(
                                                  data: ThemeData(
                                                      dividerColor:
                                                          Colors.transparent),
                                                  child: ExpansionTile(
                                                    tilePadding:
                                                        EdgeInsets.zero,
                                                    childrenPadding:
                                                        EdgeInsets.zero,
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text:
                                                              'Compalint Detail',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ],
                                                    ),
                                                    children: [
                                                      Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(document[
                                                            'complaintDetail']),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(
                                          height: 5.h,
                                        ),

                                        Container(
                                          color: Colors.white,
                                          child: Theme(
                                            data: ThemeData(
                                                dividerColor:
                                                    Colors.transparent),
                                            child: ExpansionTile(
                                              tilePadding: EdgeInsets.zero,
                                              childrenPadding: EdgeInsets.zero,
                                              title: Row(
                                                children: [
                                                  Icon(Icons.attachment),
                                                  SizedBox(
                                                    width: 5.w,
                                                  ),
                                                  TextWidget(
                                                    text: 'View Attachment',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ],
                                              ),
                                              children: [
                                                (document['attachment'] as List)
                                                        .isEmpty
                                                    ? Center(
                                                        child: Text(
                                                            "No images found"))
                                                    : Container(
                                                        width: double.maxFinite,
                                                        height: 160.h,
                                                        child: GridView.builder(
                                                          gridDelegate:
                                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 3,
                                                            mainAxisSpacing: 8,
                                                          ),
                                                          itemCount: (document[
                                                                      'attachment']
                                                                  as List)
                                                              .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            final imageUrl =
                                                                document[
                                                                        'attachment']
                                                                    [index];
                                                            return GestureDetector(
                                                              onTap: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .push(
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            PhotoView(
                                                                      imageProvider:
                                                                          NetworkImage(
                                                                              imageUrl),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child:
                                                                  Image.network(
                                                                imageUrl,
                                                                loadingBuilder: (BuildContext
                                                                        context,
                                                                    Widget
                                                                        child,
                                                                    ImageChunkEvent?
                                                                        loadingProgress) {
                                                                  if (loadingProgress ==
                                                                      null) {
                                                                    return child;
                                                                  } else {
                                                                    return Center(
                                                                      child: CircularProgressIndicator(
                                                                          // value: loadingProgress
                                                                          //             .expectedTotalBytes !=
                                                                          //         null
                                                                          //     ? loadingProgress
                                                                          //             .cumulativeBytesLoaded /
                                                                          //         loadingProgress
                                                                          //             .expectedTotalBytes!
                                                                          //     : null,
                                                                          ),
                                                                    );
                                                                  }
                                                                },
                                                                errorBuilder:
                                                                    (context,
                                                                        error,
                                                                        stackTrace) {
                                                                  return Center(
                                                                    child: Icon(
                                                                        Icons
                                                                            .error),
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        (document['meetingList'] as List)
                                                .isEmpty
                                            ? Container()
                                            : Container(
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
                                                    tilePadding:
                                                        EdgeInsets.zero,
                                                    childrenPadding:
                                                        EdgeInsets.zero,
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget(
                                                          text: 'Meeting',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ],
                                                    ),
                                                    children: [
                                                      Container(
                                                        height: 100,
                                                        child: ListView.builder(
                                                          //scrollDirection: Axis.horizontal,
                                                          itemCount: (document[
                                                                      'meetingList']
                                                                  as List)
                                                              .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            var data = document[
                                                                    'meetingList']
                                                                [index];
                                                            return Container(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  TextWidget(
                                                                    text:
                                                                        'TITLE: ${data['title']}',
                                                                    size: 17,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      TextWidget(
                                                                        text:
                                                                            'Date: ${data['meetingDate']}',
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      TextWidget(
                                                                        text:
                                                                            '${data['MeetingTime']}',
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  TextWidget(
                                                                    text:
                                                                        'Detail: ${data['meetingDetail']}',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
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
                                                    text: 'View Remarks',
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
                                                                              return authority != 'ADSA' && item2['target'] == 'Student'
                                                                                  ? Container()
                                                                                  : Container(
                                                                                      margin: EdgeInsets.only(top: 15),
                                                                                      child: Row(
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Container(
                                                                                                padding: EdgeInsets.all(3),
                                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: MyColors.lightblue),
                                                                                                height: 35,
                                                                                                width: 50,
                                                                                                alignment: Alignment.center,
                                                                                                child: TextWidget(
                                                                                                  text: '${item2['name']}' == username
                                                                                                      ? 'you'
                                                                                                      : '${item2['authority']}' == ""
                                                                                                          ? '${item2['name']}'
                                                                                                          : '${item2['authority']}',
                                                                                                  textoverflow: TextOverflow.ellipsis,
                                                                                                  size: 12,
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                width: 10,
                                                                                              ),
                                                                                              Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: MediaQuery.of(context).size.width - 165,
                                                                                                    child: Text('${item2['feedback']}'),
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
                                                                return RemarksDailog(
                                                                  docid: docId,
                                                                  id: document[
                                                                      'id'],
                                                                  username:
                                                                      username,
                                                                  authority:
                                                                      authority,
                                                                  role:
                                                                      'Investigator',
                                                                  phone: phone,target:document['faculty']
                                                                );
                                                              });
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            width: 90,
                                                            color:
                                                                MyColors.blue,
                                                            child: TextWidget(
                                                              text:
                                                                  'Add Remark',
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
                              )
                            : Container();
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
