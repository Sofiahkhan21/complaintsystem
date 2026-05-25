import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllComplaints extends StatefulWidget {
  final String type;
  final department;
  final indexx;
  const AllComplaints({super.key, required this.type, this.department,this.indexx});

  @override
  State<AllComplaints> createState() => _AllComplaintsState();
}

class _AllComplaintsState extends State<AllComplaints> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selected;
  String? selectedhint;
  String? adminrole;
  String? policestation;
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
    policestation = await getPrefs.getString('station');
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    getuser();
    selectedhint = widget.type;
    callComplaint();
  }

  // getuser() async {
  //   authoList = [];

  //   final collectionReference = FirebaseFirestore.instance
  //       .collection('credentials')
  //       .where('role', isEqualTo: 'Authority');

  //   QuerySnapshot personsSnapshot = await collectionReference.get();

  //   for (var personDocument in personsSnapshot.docs) {
  //     Map<String, dynamic> personData =
  //         personDocument.data() as Map<String, dynamic>;
  //     authoList.add(personData['username']);
  //   }

  //   print(authoList);
  // }
  getuser() async {
    authoList = [];
    print('hellooooooooooooooooooooooooooooooooo');
    FirebaseFirestore.instance
        .collection("Offices")
        .snapshots()
        .listen((event) {
      print(event.docs.length);
      var doc = event.docs;

      for (int i = 0; i < event.docs.length; i++) {
        print(doc[i]['name']);
        // if (doc[i]['role'] == 'Admin' && doc[i]['station'] == Pstation) {
        authoList.add(doc[i]['name']);
        // }
      }
      setState(() {});
    });
    print(authoList);
    setState(() {});
  }

  List authoList = [];
  String selectval = '';
  List tempList = [];
  getComplaint(priority) async {
    tempList = [];

    final collectionReference = FirebaseFirestore.instance
        .collection('complaint')
        .where('status', isEqualTo: widget.type)
        .where('department', isEqualTo: widget.department)
        .where('priority', isEqualTo: priority);

    QuerySnapshot personsSnapshot = await collectionReference.get();

    for (var personDocument in personsSnapshot.docs) {
      Map<String, dynamic> personData =
          personDocument.data() as Map<String, dynamic>;
      personData['docId'] = personDocument.id;
      tempList.add(personData);
      print(tempList[0]['docId']);
    }
    return tempList;
  }

  callComplaint() async {
    highList = await getComplaint('High') ?? [];
    mediumList = await getComplaint('Medium') ?? [];
    lowList = await getComplaint('Low') ?? [];

    mainList = await [...highList, ...mediumList, ...lowList];
    setState(() {});
  }

  List highList = [];
  List mediumList = [];
  List lowList = [];
  List mainList = [];

  Future<void> reportComplaint(title, deatail) async {
    String response = "Sending.....";
    await Provider.of<ComplaintProvider>(context, listen: false)
        .reportComplaint(
            body: deatail, id: 'admin', title: '$title', userList: userList);

    setState(() {});
  }

  List userList = [];
  getuserList(id, title, detail) async {
    userList = [];
    FirebaseFirestore.instance
        .collection("complaint_token")
        .where('role', isEqualTo: "Authority")
        .where('authority', isEqualTo: selectval)
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
        .update({'assign': true, 'assignto': selectval});
    setState(() {});
    reportComplaint(title, detail);
    
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ComplaintProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          title: GestureDetector(
              onTap: () {
                callComplaint();
              },
              child: Text('Complaints')),
          centerTitle: true,
        ),
        body:
            StreamBuilder<QuerySnapshot>(
              stream:
                   FirebaseFirestore.instance
                      .collection('complaint').orderBy('priorityValue', descending: true)
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
                } if(snapshot.hasData){

                }
                // if(snapshot.hasData){
                //   // for (var i = 0; i < snapshot.data!.docs.length; i++) {
                //   //   if(snapshot.data!.docs[i]['priority']=='High'){
                //   //     highList.add(snapshot.data!.docs[i]);
                //   //   }else if(snapshot.data!.docs[i]['priority']=='Medium'){
                //   //     mediumList.add(snapshot.data!.docs[i]);
                //   //   }else if(snapshot.data!.docs[i]['priority']=='Low'){
                //   //     lowList.add(snapshot.data!.docs[i]);
                //   //   }
                    
                //   // }
                // }

                return
      
                 ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot id = snapshot.data!.docs[index];
                String docId = id.id;
                DocumentSnapshot document = snapshot.data!.docs[index];
                var mainVal;
                if(widget.indexx==1){
                  mainVal=document["department"];

                }if(widget.indexx==2){
                  mainVal=document["faculty"];

                }

                      // Use the document data to populate your ListView items
                      
                      return
                       document["status"]== widget.type && mainVal== widget.department? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextWidget(
                                      text: 'Status: ',
                                      size: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Container(
                                      height: 20,
                                      child: DropdownButton<String>(
                                        hint: Text(
                                         document["status"],
                                          style: TextStyle(
                                              color: selectedhint.toString() ==
                                                      'Open'
                                                  ? Colors.green
                                                  : selectedhint.toString() ==
                                                          'In Process'
                                                      ? Colors.orange
                                                      : Colors.red),
                                        ),
                                        // value: selected,
                                        onChanged: (String? newValue) async {
                                          setState(() {
                                            selected = newValue!;
                                          });

                                          await _firestore
                                              .collection('complaint')
                                              .doc(docId)
                                              .update({
                                            "id": document["id"],
                                            "subject": document['subject'],
                                            "category": document['category'],
                                            "complaintDetail":
                                                document['complaintDetail'],
                                            "attachment":
                                                document['attachment'],
                                            "contact": document['contact'],
                                            "date": document['date'],
                                            "name": document['name'],
                                            "address": document['address'],
                                            "status": selected,
                                          });
                                           setState(() {
                                          
                                          });
                                          mainList.remove(document);
                                       
                                        },
                                        items: Statuses.map<
                                                DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        icon: SizedBox.shrink(),
                                        underline: Container(),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Row(
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
                                    // Container(
                                    //   width: 100,
                                    //   //  margin: EdgeInsets.all(8),
                                    //   padding: const EdgeInsets.only(
                                    //       left: 10, right: 10),
                                    //   decoration: BoxDecoration(
                                    //     color: Colors.grey[200],
                                    //     borderRadius: BorderRadius.circular(8),
                                    //   ),
                                    //   child: document['assign']
                                    //       ? TextWidget(
                                    //           text: 'Assigned',
                                    //         )
                                    //       : DropdownButtonHideUnderline(
                                    //           child: DropdownButtonFormField(
                                    //               menuMaxHeight: 300,

                                    //               // underline: const SizedBox(),
                                    //               decoration:
                                    //                   const InputDecoration(
                                    //                 alignLabelWithHint: true,
                                    //                 border: InputBorder.none,
                                    //                 errorBorder:
                                    //                     UnderlineInputBorder(
                                    //                   borderSide: BorderSide(
                                    //                       color: Colors
                                    //                           .transparent),
                                    //                 ),
                                    //               ),
                                    //               hint: Text("Assign"),
                                    //               isExpanded: true,
                                    //               items: authoList.map((map) {
                                    //                 return DropdownMenuItem<
                                    //                         String>(
                                    //                     value: map,
                                    //                     child: Text(map));
                                    //               }).toList(),
                                    //               onChanged: (val) async {
                                    //                 selectval = val.toString();
                                    //                 print(selectval);

                                    //                 setState(() {});

                                    //                 getuserList(
                                    //                     docId,
                                    //                     document['subject'],
                                    //                     document[
                                    //                         'complaintDetail']);
                                    //               }),
                                    //         ),
                                    // ),
                                    // TextButton(
                                    //     onPressed: () {
                                    //       showDialog(
                                    //           context: context,
                                    //           builder: (BuildContext context) {
                                    //             return AlertDialog(
                                    //               // title: Text('Compalint Detail'),
                                    //               // content: Text(
                                    //               //     document['complaintDetail']),
                                    //               // actions: [
                                    //               //   TextButton(
                                    //               //     onPressed: () {
                                    //               //       Navigator.of(context).pop();
                                    //               //     },
                                    //               //     child: Text('Close'),
                                    //               //   ),
                                    //              // ],
                                    //             );
                                    //           });
                                    //     },
                                    //     child: TextWidget(
                                    //       text: 'Assign',
                                    //       textcolor: Colors.blue,
                                    //     ))
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
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
                                  padding: const EdgeInsets.only(left: 7),
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
                                        text: 'Contact: ${document['contact']}',
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
                                            text:widget.indexx==1? 'Department: ':'Faculty: ',
                                            fontWeight: FontWeight.w500,
                                            textcolor: Colors.black,
                                          ),
                                          TextWidget(
                                            text:widget.indexx==1? document['department']:document['faculty'],
                                            textcolor: Colors.black,
                                          ),
                                        ],
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
                                                      '${document['assignto']}(Authority)',
                                                  textcolor: Colors.black,
                                                ),
                                              ],
                                            )
                                          : Container(
                                              width: 0,
                                            ),
                                                  SizedBox(
                                  height: document['forword'] ? 5 : 0,
                                ),
                                document['forword']
                                    ?
                                     Row(
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
                                                child: Text(document[
                                                    'complaintDetail']),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      //     SizedBox(
                                      //   height: 5,
                                      // ),
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.start,
                                      //   children: [
                                      //     TextWidget(
                                      //       text: 'Office: ',
                                      //       fontWeight: FontWeight.w500,
                                      //       textcolor: Colors.black,
                                      //     ),
                                      //     TextWidget(
                                      //       text: document['office'],
                                      //       textcolor: Colors.black,
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
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
                                        children: [
                                          Icon(Icons.attachment),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          TextWidget(
                                            text: 'View Attachment',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ],
                                      ),
                                      children: [
                                        document['attachment'].isEmpty
                                            ? Center(
                                                child: Text("No images found"))
                                            : Container(
                                                width: double.maxFinite,
                                                height: 160,
                                                child: GridView.builder(
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    mainAxisSpacing: 8,
                                                  ),
                                                  itemCount:
                                                      (document['attachment'] as List)
                                                          .length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    final imageUrl =
                                                        document['attachment']
                                                            [index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
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
                                                      child: Image.network(
                                                        imageUrl,
                                                        loadingBuilder:
                                                            (BuildContext
                                                                    context,
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
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Center(
                                                            child: Icon(
                                                                Icons.error),
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

                                // Container(
                                //   child: Theme(
                                //     data: ThemeData(dividerColor: Colors.transparent),
                                //     child: ExpansionTile(
                                //       tilePadding: EdgeInsets.zero,
                                //       childrenPadding: EdgeInsets.zero,
                                //       title: Row(
                                //         children: [
                                //           Icon(Icons.attachment),
                                //           SizedBox(
                                //             width: 5,
                                //           ),
                                //           TextWidget(
                                //             text: 'View Attachment',
                                //             fontWeight: FontWeight.bold,
                                //           ),
                                //         ],
                                //       ),
                                //       children: [
                                //         Container(
                                //           width: double.maxFinite,
                                //           height: 200,
                                //           child: GridView.builder(
                                //             gridDelegate:
                                //                 SliverGridDelegateWithFixedCrossAxisCount(
                                //               crossAxisCount: 3,
                                //               mainAxisSpacing: 8,
                                //             ),
                                //             itemCount: document['attachment'].length,
                                //             itemBuilder:
                                //                 (BuildContext context, int index) {
                                //               return Image.network(
                                //                   document['attachment'][index]);
                                //             },
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ):Container();
                    },
                  );
      
        },
        )
        );
  }
}
