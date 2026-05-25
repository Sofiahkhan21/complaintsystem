import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/screens/admin/send_notification.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AdminNotification extends StatefulWidget {
  const AdminNotification({super.key});

  @override
  State<AdminNotification> createState() => _AdminNotificationState();
}

class _AdminNotificationState extends State<AdminNotification> {
 String? username;

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
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.blue,
        
        onPressed: (){
            Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SendNotification()),
                );
        },child: Icon(Icons.add,color: Colors.white,),),
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 64, 114),
          title: Text(
            'Notifications',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('adminNotifications').orderBy('timeStamp',descending: true)
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
                // Use the document data to populate your ListView items
                return Container(
                  margin: EdgeInsets.only(left: 15,right: 15,top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: document['title'],
                                fontWeight: FontWeight.bold,
                                size: 17,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextWidget(
                                text: document['date'],
                                fontWeight: FontWeight.bold,
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
                                          text: document['notificationDetail'],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child:
                                            Text(document['notificationDetail']),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                               TextWidget(
                                          text: document['to'],
                                          fontWeight: FontWeight.bold,
                                        ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }
}