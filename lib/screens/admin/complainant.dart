// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/screens/admin/each_complaint.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Complainant extends StatefulWidget {
  const Complainant({
    super.key,
  });

  @override
  State<Complainant> createState() => _ComplainantState();
}

class _ComplainantState extends State<Complainant> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selected;
  String? selectedhint;
  String? adminrole;
  String? policestation;
  List<QueryDocumentSnapshot<Object?>>? filteredDocuments;
  getdata() async {
    SharedPreferences getPrefs = await SharedPreferences.getInstance();

    adminrole = await getPrefs.getString('adminrole');
    policestation = await getPrefs.getString('station');
    setState(() {});
  }

  @override
  void initState() {
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
            'Users Complaint',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: adminrole == 'Admin'
              ? FirebaseFirestore.instance
                  .collection('complaint')
                  .where('policestation', isEqualTo: policestation)
                  .snapshots()
              : FirebaseFirestore.instance.collection('complaint').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot<Object?>> documents =
                  snapshot.data!.docs;

              // Create a set to store unique field values
              Set<dynamic> uniqueFieldValues = Set<dynamic>();

              // Filter out duplicate documents based on the field value
              filteredDocuments = documents.where((doc) {
                dynamic fieldValue = doc['name'];
                if (uniqueFieldValues.contains(fieldValue)) {
                  return false; // Skip duplicate document
                } else {
                  uniqueFieldValues.add(fieldValue);
                  return true; // Include unique document
                }
              }).toList();
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
              itemCount: filteredDocuments!.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot id = snapshot.data!.docs[index];
                String docId = id.id;
                DocumentSnapshot document = snapshot.data!.docs[index];
                // Use the document data to populate your ListView items
                return Padding(
                  padding: const EdgeInsets.all(8.0).w,
                  child: Card(
                    color: Color.fromARGB(220, 2, 64, 114),
                    child: Container(
                      decoration: BoxDecoration(
                          // color: Colors.white,
                          borderRadius: BorderRadius.circular(10).w),
                      padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10)
                          .w,
                      child: ListTile(
                        onTap: () {
                          MyNavigation.push(
                              context,
                              Eachcomplaint(
                                  usrname: filteredDocuments![index]['name']));
                        },
                        leading: document['image'] != null
                            ? CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                    filteredDocuments![index]['image']),
                              )
                            : CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    AssetImage('assets/profile_picture.png'),
                              ),
                        title: TextWidget(
                          text: filteredDocuments![index]['name'],
                          fontWeight: FontWeight.bold,
                          textcolor: Colors.white,
                        ),
                        subtitle: TextWidget(
                          text: document['category'],
                          fontWeight: FontWeight.bold,
                          textcolor: Colors.white,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),

                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Row(
                      //       children: [
                      //         CircleAvatar(
                      //           radius: 25,
                      //         ),
                      //         SizedBox(
                      //           width: 10,
                      //         ),
                      //         Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             TextWidget(
                      //               text: document['name'],
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //             TextWidget(
                      //               text: document['category'],
                      //             )
                      //           ],
                      //         )
                      //       ],
                      //     )
                      //   ],
                      // ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
