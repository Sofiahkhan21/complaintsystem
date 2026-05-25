import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class MeetingsDetail extends StatefulWidget {
  const MeetingsDetail({super.key});

  @override
  State<MeetingsDetail> createState() => _MeetingsDetailState();
}

class _MeetingsDetailState extends State<MeetingsDetail> {
  String? authority;
  getdata() async {
    SharedPreferences getPrefs = await SharedPreferences.getInstance();

  
    authority = await getPrefs.getString('authority');
   

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
    return Scaffold(
        backgroundColor: Colors.white.withOpacity(0.9),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 64, 114),
          title: Text(
            'Meetings',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('meetings').orderBy('timeStamp',descending: true)
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
                var listdata=(document['collaborator'] as List);
                print(listdata);
                print(authority);
                // Use the document data to populate your ListView items
                return listdata.contains(authority)? Container(
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
                                text: 'TITLE: ${document['title']}',
                                
                                size: 17,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextWidget(
                                text: 'Date: ${document['meetingDate']}',
                                fontWeight: FontWeight.normal,
                              ),
                                  SizedBox(
                                height: 5,
                              ),
                              TextWidget(
                                text: 'Time: ${document['MeetingTime']}',
                                fontWeight: FontWeight.normal,
                              ),
                                SizedBox(
                                height: 5,
                              ),
                              TextWidget(
                                text: 'Detail: ${document['meetingDetail']}',
                                fontWeight: FontWeight.normal,
                              ),
                                SizedBox(
                                height: 10,
                              ),
                              TextWidget(
                                text: 'Collaborator',
                                fontWeight: FontWeight.bold,
                              ),
                              Container(
height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: (document['collaborator'] as List).length,
                                  itemBuilder: (BuildContext context, int index) {
                                    var item=document['collaborator'][index];
                                    var indexx=index+1;
                                    return Container(
                                      margin: EdgeInsets.only(top: 10,right: 15),
                                      child: TextWidget(text: '$indexx. ${item}',));
                                  },
                                ),
                              )
                           
                          
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ):Container();
              },
            );
          },
        ));
  }
}