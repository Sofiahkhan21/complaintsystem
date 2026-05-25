import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderNotification extends StatefulWidget {
  const ReminderNotification({super.key});

  @override
  State<ReminderNotification> createState() => _ReminderNotificationState();
}

class _ReminderNotificationState extends State<ReminderNotification> {
  String? username;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  getdata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');

    setState(() {});
    // print(getChannel());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 64, 114),
          title: Text(
            'Reminder ',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('reminder')
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
                _firestore.collection('reminder').doc(docId).update({
                  'read': true,
                });
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
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: Column(
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
                                      textcolor: document['status'] == 'Open'
                                          ? Colors.green
                                          : document['status'] == 'Is Process'
                                              ? Colors.orange
                                              : Colors.red,
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
                                    ],
                                  ),
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
                                                      document['attachment']
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
