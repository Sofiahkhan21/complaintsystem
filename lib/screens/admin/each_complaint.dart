import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Eachcomplaint extends StatefulWidget {
  final String usrname;
  const Eachcomplaint({super.key, required this.usrname});

  @override
  State<Eachcomplaint> createState() => _EachcomplaintState();
}

class _EachcomplaintState extends State<Eachcomplaint> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selected;
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
  }

  @override
  Widget build(BuildContext context) {
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
          stream: adminrole == 'Admin'
              ? FirebaseFirestore.instance
                  .collection('complaint')
                  .where('name', isEqualTo: widget.usrname)
                  //.where('policestation', isEqualTo: policestation)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('complaint')
                  .where('name', isEqualTo: widget.usrname)
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
                print(id);
                print(docId);


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
                            children: [
                              TextWidget(
                                text: 'Status: ',
                                size: 18,
                                fontWeight: FontWeight.bold,
                                textcolor: Colors.black,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 35.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20).w,
                                      color: Colors.grey[200],
                                    ),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5).w,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          document['status'].toString(),
                                          style: TextStyle(
                                            color:
                                                document['status'].toString() ==
                                                        'Open'
                                                    ? Color.fromARGB(
                                                        255, 2, 64, 114)
                                                    : document['status']
                                                                .toString() ==
                                                            'In Process'
                                                        ? Colors.green
                                                        : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        DropdownButton<String>(
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
                                           
                                              'department':document['department']

                                            });

                                            provider.getdata();
                                          },
                                          items: Statuses.map<
                                              DropdownMenuItem<String>>(
                                            (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            },
                                          ).toList(),
                                          icon: Icon(Icons.arrow_drop_down),
                                          underline: Container(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )

                              // Row(
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: [
                              //     Container(
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(20),
                              //         color: Colors.grey[200],
                              //       ),
                              //       height: 40,
                              //       child: Row(
                              //         children: [
                              //           Padding(
                              //             padding: const EdgeInsets.symmetric(
                              //                 horizontal: 5),
                              //             child: Text(
                              //               document['status'].toString(),
                              //               style: TextStyle(
                              //                 color: document['status']
                              //                             .toString() ==
                              //                         'Open'
                              //                     ? Color.fromARGB(
                              //                         255, 2, 64, 114)
                              //                     : document['status']
                              //                                 .toString() ==
                              //                             'In Process'
                              //                         ? Colors.green
                              //                         : Colors.red,
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ),
                              //           DropdownButton<String>(
                              //             onChanged: (String? newValue) async {
                              //               setState(() {
                              //                 selected = newValue!;
                              //               });

                              //               await _firestore
                              //                   .collection('complaint')
                              //                   .doc(docId)
                              //                   .update({
                              //                 "id": document["id"],
                              //                 "subject": document['subject'],
                              //                 "category": document['category'],
                              //                 "complaintDetail":
                              //                     document['complaintDetail'],
                              //                 "attachment":
                              //                     document['attachment'],
                              //                 "contact": document['contact'],
                              //                 "date": document['date'],
                              //                 "name": document['name'],
                              //                 "address": document['address'],
                              //                 "status": selected,
                              //               });

                              //               provider.getdata();
                              //             },
                              //             items: Statuses.map<
                              //                 DropdownMenuItem<String>>(
                              //               (String value) {
                              //                 return DropdownMenuItem<String>(
                              //                   value: value,
                              //                   child: Text(value),
                              //                 );
                              //               },
                              //             ).toList(),
                              //             icon: Icon(Icons.arrow_drop_down),
                              //             underline: Container(),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // )

                              // Row(
                              //   children: [
                              //     Container(
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(20),
                              //         color: Colors.grey[200],
                              //       ),
                              //       height: 40,
                              //       width: 220,
                              //       child: Row(
                              //         children: [
                              //           Expanded(
                              //             child: Padding(
                              //               padding: const EdgeInsets.symmetric(
                              //                   horizontal: 15),
                              //               child: Text(
                              //                 document['status'].toString(),
                              //                 style: TextStyle(
                              //                   color: document['status']
                              //                               .toString() ==
                              //                           'Open'
                              //                       ? Color.fromARGB(
                              //                           255, 2, 64, 114)
                              //                       : document['status']
                              //                                   .toString() ==
                              //                               'In Process'
                              //                           ? Colors.green
                              //                           : Colors.red,
                              //                   fontWeight: FontWeight.bold,
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //           DropdownButton<String>(
                              //             onChanged: (String? newValue) async {
                              //               setState(() {
                              //                 selected = newValue!;
                              //               });

                              //               await _firestore
                              //                   .collection('complaint')
                              //                   .doc(docId)
                              //                   .update({
                              //                 "id": document["id"],
                              //                 "subject": document['subject'],
                              //                 "category": document['category'],
                              //                 "complaintDetail":
                              //                     document['complaintDetail'],
                              //                 "attachment":
                              //                     document['attachment'],
                              //                 "contact": document['contact'],
                              //                 "date": document['date'],
                              //                 "name": document['name'],
                              //                 "address": document['address'],
                              //                 "status": selected,
                              //               });

                              //               provider.getdata();
                              //             },
                              //             items: Statuses.map<
                              //                 DropdownMenuItem<String>>(
                              //               (String value) {
                              //                 return DropdownMenuItem<String>(
                              //                   value: value,
                              //                   child: Text(value),
                              //                 );
                              //               },
                              //             ).toList(),
                              //             icon: Icon(Icons.arrow_drop_down),
                              //             underline: Container(),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // )

                              // Row(
                              //   children: [
                              //     Container(
                              //       decoration: BoxDecoration(
                              //           borderRadius: BorderRadius.circular(20),
                              //           color: Colors.white),
                              //       height: 30,
                              //       width: 120,
                              //       child: DropdownButton<String>(
                              //         hint: Padding(
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 15),
                              //           child: Text(
                              //             document['status'].toString(),
                              //             style: TextStyle(
                              //                 color: document['status']
                              //                             .toString() ==
                              //                         'Open'
                              //                     ? Color.fromARGB(
                              //                         255, 2, 64, 114)
                              //                     : document['status']
                              //                                 .toString() ==
                              //                             'In Process'
                              //                         ? Colors.orange
                              //                         : Colors.red),
                              //           ),
                              //         ),
                              //         // value: selected,
                              //         onChanged: (String? newValue) async {
                              //           setState(() {
                              //             selected = newValue!;
                              //           });

                              //           await _firestore
                              //               .collection('complaint')
                              //               .doc(docId)
                              //               .update({
                              //             "id": document["id"],
                              //             "subject": document['subject'],
                              //             "category": document['category'],
                              //             "complaintDetail":
                              //                 document['complaintDetail'],
                              //             "attachment": document['attachment'],
                              //             "contact": document['contact'],
                              //             "date": document['date'],
                              //             "name": document['name'],
                              //             "address": document['address'],
                              //             "status": selected,
                              //           });

                              //           provider.getdata();
                              //         },
                              //         items: Statuses.map<
                              //                 DropdownMenuItem<String>>(
                              //             (String value) {
                              //           return DropdownMenuItem<String>(
                              //             value: value,
                              //             child: Text(value),
                              //           );
                              //         }).toList(),
                              //         icon: SizedBox.shrink(),
                              //         underline: Container(),
                              //       ),
                              //     ),
                              //   ],
                              // ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWidget(
                                text: document['subject'],
                                fontWeight: FontWeight.bold,
                                size: 17,
                                textcolor: Colors.black,
                              ),
                              TextButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Compalint Detail'),
                                            content: Text(
                                                document['complaintDetail']),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Close'),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  child: TextWidget(
                                    text: 'see detail',
                                    textcolor: Colors.blue,
                                  ))
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
                                      text: 'Department: ',
                                      fontWeight: FontWeight.w500,
                                      textcolor: Colors.black,
                                    ),
                                    TextWidget(
                                      text: document['department'],
                                      textcolor: Colors.black,
                                    ),
                                  ],
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
                          // Container(
                          //   color: Colors.white,
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
                          // GestureDetector(
                          //   onTap: () {
                          //     showDialog(
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         return AlertDialog(
                          //           title: Text('Image List'),
                          //           content: Container(
                          //             width: double.maxFinite,
                          //             height: 200,
                          //             child: GridView.builder(
                          //               gridDelegate:
                          //                   SliverGridDelegateWithFixedCrossAxisCount(
                          //                       crossAxisCount: 3,
                          //                       mainAxisSpacing: 8),
                          //               itemCount:
                          //                   document['attachment'].length,
                          //               itemBuilder:
                          //                   (BuildContext context, int index) {
                          //                 return Image.network(
                          //                     document['attachment'][index]);
                          //               },
                          //             ),
                          //           ),
                          //           actions: [
                          //             TextButton(
                          //               onPressed: () {
                          //                 Navigator.of(context).pop();
                          //               },
                          //               child: Text('Close'),
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     );
                          //   },
                          //   child: Container(
                          //     child: Row(
                          //       children: [
                          //         Icon(
                          //           Icons.attachment,
                          //           color: Colors.white,
                          //         ),
                          //         SizedBox(
                          //           width: 5,
                          //         ),
                          //         TextWidget(
                          //           text: 'View Attachment',
                          //           fontWeight: FontWeight.bold,
                          //           textcolor: Colors.white,
                          //         )
                          //       ],
                          //     ),
                          //   ),
                          // )
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
