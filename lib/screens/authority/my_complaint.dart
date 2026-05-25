import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MyComplaint extends StatefulWidget {
  const MyComplaint({super.key});

  @override
  State<MyComplaint> createState() => _MyComplaintState();
}

class _MyComplaintState extends State<MyComplaint> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var remarkController = TextEditingController();

  String? selected;
  String? adminrole;
  String? username;
  String? phone;

  String? authority;
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

    adminrole = await getPrefs.getString('role');
    username = await getPrefs.getString('username');
    authority = await getPrefs.getString('authority');
    phone = await getPrefs.getString('phone');

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    getuser();
    getAuthority() ;
  }

  getuser() async {
    authoList = [];

    final collectionReference = FirebaseFirestore.instance
        .collection('credentials')
        .where('role', isEqualTo: 'Investigator');

    QuerySnapshot personsSnapshot = await collectionReference.get();

    for (var personDocument in personsSnapshot.docs) {
      Map<String, dynamic> personData =
          personDocument.data() as Map<String, dynamic>;
      authoList.add(personData['username']);
    }

    print(authoList);
  }

  List authoList = [];
  String selectval = '';
  Future<void> reportComplaint(title, deatail) async {
    String response = "Sending.....";
    await Provider.of<ComplaintProvider>(context, listen: false)
        .reportComplaint(
            body: deatail,
            id: 'authority',
            title: '$title',
            userList: userList);

    setState(() {});
  }

  List userList = [];
  getuserList(id, title, detail) async {
    userList = [];
    FirebaseFirestore.instance
        .collection("Comlaint_tokens")
        .where('role', isEqualTo: "Investigator")
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
    await _firestore.collection('complaint').doc(id).update({
      'forword': true,
      'forwordTo': selectval,
      'teamRemark': remarkController.text
    });
    setState(() {});
    reportComplaint(title, detail);
  }
 addFeedback(cId, fid) async {
    await _firestore.collection('feedback').doc().set({
      "id": "$cId",
      "complaintId": cId,
      "feedback": remarkController.text,
      "date": "${CusDateFormat.getDate(DateTime.now())}",
      "name": username,
      "role": "Authority",
      "phone": phone,
      "authority":authority
    });
    Navigator.pop(context);
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
        if(doc[i]['name']!=authority){
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
    await _firestore.collection('complaint').doc(id).update({
      'forword': true,
      'forwordTo': assignval,
    
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
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ComplaintProvider>(context, listen: false);
    print(authority);
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

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot id = snapshot.data!.docs[index];
                String docId = id.id;
                DocumentSnapshot document = snapshot.data!.docs[index];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10)
                          .w,
                  child: Card(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20).w,
                                  topRight: Radius.circular(20).w,
                                  bottomLeft: Radius.circular(15).w,
                                  bottomRight: Radius.circular(15))
                              .w),
                      padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20)
                          .w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  Text(
                                        document['status'].toString(),
                                        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,
                                            color:
                                                document['status'].toString() ==
                                                        'Open'
                                                    ? Colors.green
                                                    : document['status']
                                                                .toString() ==
                                                            'In Process'
                                                        ? Colors.orange
                                                        : Colors.red),
                                      ),
                            
                                ],
                              ),
                             Container(
                              margin: EdgeInsets.only(right: 10),
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
                                            textcolor: document['priority'] ==
                                                    'High'
                                                ? Colors.red
                                                : document['priority'] == 'Medium'
                                                    ? Colors.green
                                                    : Colors.orange,
                                          ),
                                        ],
                                      ),
                             ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: document['subject'],
                                fontWeight: FontWeight.bold,
                                size: 17,
                                textcolor: Colors.black,
                              ),
                          // Container(
                          //             width: 100,
                                  
                          //             //  margin: EdgeInsets.all(8),
                          //             padding: const EdgeInsets.only(
                          //                 left: 10, right: 3),
                          //             decoration: BoxDecoration(
                          //               color:document['forword']? MyColors.blue:MyColors.grey,
                          //               borderRadius: BorderRadius.circular(8),
                          //             ),
                          //             child:
                          //              document['forword']
                          //                 ? TextWidget(
                          //                     text: 'Forworded',textcolor: MyColors.grey,
                          //                   )
                          //                 :
                          //                  DropdownButtonHideUnderline(
                          //                     child: DropdownButtonFormField(
                          //                         menuMaxHeight: 300,

                          //                         // underline: const SizedBox(),
                          //                         decoration:
                          //                             const InputDecoration(
                          //                           alignLabelWithHint: true,
                          //                           border: InputBorder.none,
                          //                           errorBorder:
                          //                               UnderlineInputBorder(
                          //                             borderSide: BorderSide(
                          //                                 color: Colors
                          //                                     .transparent),
                          //                           ),
                          //                         ),
                          //                         hint: Text("Forword to .."),
                          //                         isExpanded: true,
                          //                         items: assignList.map((map) {
                          //                           return DropdownMenuItem<
                          //                                   String>(
                          //                               value: map,
                          //                               child: Text(map));
                          //                         }).toList(),
                          //                         onChanged: (val) async {
                          //                           assignval = val.toString();
                          //                           print(assignval);

                                             

                          //                           sendAssignList(
                          //                               docId,
                          //                               document['subject'],
                          //                               document[
                          //                                   'complaintDetail']);
                          //                                          setState(() {});
                          //                         }),
                          //                   ),
                          //           ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Colors.red,
                              ),
                              TextWidget(
                                text: document['address'],
                                textcolor: Colors.black,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 7).w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: document['name'],
                                  fontWeight: FontWeight.bold,
                                  size: 17,
                                  textcolor: Colors.black,
                                ),
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
                                TextWidget(
                                  text: 'ID: ${document['id']}',
                                  textcolor: Colors.black,
                                ),
                                SizedBox(
                                  height: 5.h,
                                ),
                                 TextWidget(
                                        text: 'Contact: ${document['contact']}',
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: document['faculty']=='User'? 'Department: ':'Faculty: ',
                                      fontWeight: FontWeight.w500,
                                      textcolor: Colors.black,
                                    ),
                                    TextWidget(
                                      text:document['faculty']=='User'? document['department']:document['faculty'],
                                      textcolor: Colors.black,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: document['forword'] ? 5 : 0,
                                ),
                                document['forword']
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: 'Forword To: ',
                                            fontWeight: FontWeight.w500,
                                            textcolor: Colors.black,
                                          ),
                                          TextWidget(
                                            text: '${document['forwordTo']}',
                                            textcolor: Colors.black,
                                          ),
                                        ],
                                      )
                                    : Container(
                                        width: 0,
                                      ),
                                SizedBox(
                                  height: document['assign'] ? 5 : 0,
                                ),
                                document['assign']
                                    ? Row(
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
                                                '${document['authority']}',
                                            textcolor: Colors.black,
                                          ),
                                        ],
                                      )
                                    : Container(
                                        width: 0,
                                      ),
                                SizedBox(
                                  height: document['final'] ? 5 : 0,
                                ),
                                document['final']
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: 'Remark: ',
                                            fontWeight: FontWeight.w500,
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
                                        dividerColor: Colors.transparent),
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
                                          alignment: Alignment.centerLeft,
                                          child:
                                              Text(document['complaintDetail']),
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
                              data: ThemeData(dividerColor: Colors.transparent),
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
                                  document['attachment'].isEmpty
                                      ? Center(child: Text("No images found"))
                                      : Container(
                                          width: double.maxFinite,
                                          height: 160.h,
                                          child: GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              mainAxisSpacing: 8,
                                            ),
                                            itemCount:
                                                document['attachment'].length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              final imageUrl =
                                                  document['attachment'][index];
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PhotoView(
                                                        imageProvider:
                                                            NetworkImage(
                                                                imageUrl),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Image.network(
                                                  imageUrl,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
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
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Center(
                                                      child: Icon(Icons.error),
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
                            Container(
                                  margin: EdgeInsets.only(left: 5, right: 5),
                                  color: Colors.white,
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  child: Theme(
                                    data: ThemeData(
                                        dividerColor: Colors.transparent),
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
                                           height:snapshot.data!.docs.isEmpty? 60: 200,
                                                child: StreamBuilder(
                                                  stream: _firestore
                                                      .collection('feedback')
                                                      .where('complaintId',
                                                          isEqualTo:
                                                              document['id'])
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      return snapshot.data!.docs
                                                              .isEmpty
                                                          ? Container(
                                                              height: 0,
                                                            )
                                                          : ListView.builder(
                                                              itemCount:
                                                                  snapshot
                                                                      .data!
                                                                      .docs
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                var item2 = snapshot
                                                                        .data!
                                                                        .docs[
                                                                    index];
                                                                if (item2[
                                                                        'complaintId'] ==
                                                                    document[
                                                                        'id']) {
                                                                  return Container(
                                                                    margin: EdgeInsets.only(top: 15),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.all(3),
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: MyColors.lightblue),
                                                                          height:
                                                                              35,
                                                                              width: 50,
                                                                              alignment: Alignment.center,
                                                                          child: TextWidget(text:'${item2['name']}' == username
                                                                              ? 'you'
                                                                              : '${item2['name']}',size: 12,),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Column(
                                                                         
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width - 135,
                                                                              child: Text( '${item2['feedback']}'
                                                                                ),
                                                                            ),
                                                                            SizedBox(height: 5,),
                                                                            Container(
                                                                              alignment: Alignment.bottomRight,
                                                                              child: TextWidget(
                                                                                text: '${item2['date']}',textcolor: MyColors.blue,size: 12,
                                                                                
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
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
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text('Remark'),
                                                          content: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .all(
                                                                        8.0)
                                                                    .w,
                                                            child:
                                                                SingleChildScrollView(
                                                              child:
                                                                  TextFormField(
                                                                maxLines: 3,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .text,
                                                                controller:
                                                                    remarkController,

                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      'Remark details...',
                                                                  hintStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            2,
                                                                            64,
                                                                            114),
                                                                  ),
                                                                  filled: true,
                                                                  isDense: true,
                                                                  border: OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                      borderRadius:
                                                                          BorderRadius.circular(15)
                                                                              .w),
                                                                  fillColor:
                                                                      Colors.grey[
                                                                          300],
                                                                ),
                                                                // validator: _validateComplaintDetails,
                                                                //  maxLength: 6,
                                                              ),

                                                              // textAlign: TextAlign.left,
                                                            ),
                                                          ),
                                                          actions: [
                                                             TextButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty
                                                                .all(Colors
                                                                    .red)),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: TextWidget(
                                                      text: 'Cancle',
                                                      textcolor: Colors.white,
                                                    ),
                                                  ),
                                                  TextButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty
                                                                .all(Colors
                                                                    .amber)),
                                                    onPressed: () async {
                                                      // getuserList(  docId,
                                                      //   document['subject'],
                                                      //   document[
                                                      //       'complaintDetail']);

                                                    
                                                          
                                                      addFeedback(document['id'], index);
                                                        Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: TextWidget(
                                                      text: 'Send',
                                                      textcolor: Colors.white,
                                                    ),
                                                  ),
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: Container(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width: 90,
                                                    color: MyColors.blue,
                                                    child: TextWidget(
                                                      text: 'Add Remark',
                                                      textcolor: MyColors.grey,
                                                   
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
                );
              },
            );
          },
        ));
  }
}