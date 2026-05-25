import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:complaintsystem/screens/investigator/add_meeting.dart';
import 'package:flutter/material.dart';
class Meetings extends StatefulWidget {
  const Meetings({super.key});

  @override
  State<Meetings> createState() => _MeetingsState();
}

class _MeetingsState extends State<Meetings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  floatingActionButton: FloatingActionButton(
    //     backgroundColor: MyColors.blue,
        
    //     onPressed: (){
    //         Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                   builder: (context) => const AddMeeting()),
    //             );
    //     },child: Icon(Icons.add,color: Colors.white,),),
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
                // Use the document data to populate your ListView items
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 15,right: 15,top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Container(
                             width: MediaQuery.of(context).size.width,
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
                              Row(
                                children: [
                                  TextWidget(
                                    text: 'Date: ${document['meetingDate']}',
                                    fontWeight: FontWeight.normal,
                                  ),
                                     SizedBox(
                                width: 5,
                              ),
                              TextWidget(
                                text: '   ${document['MeetingTime']}',
                                fontWeight: FontWeight.normal,
                              ),
                                ],
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
                                text: '${document['date']}(Created Date)'.split('-').last,
                                fontWeight: FontWeight.normal,
                              ),
                                SizedBox(
                                height: 10,
                              ),
//                               TextWidget(
//                                 text: 'Collaborator',
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               Container(
// height: 60,
//                                 child: ListView.builder(
//                                   scrollDirection: Axis.horizontal,
//                                   itemCount: (document['collaborator'] as List).length,
//                                   itemBuilder: (BuildContext context, int index) {
//                                     var item=document['collaborator'][index];
//                                     var indexx=index+1;
//                                     return Container(
//                                       margin: EdgeInsets.only(top: 10,right: 15),
//                                       child: TextWidget(text: '$indexx. ${item}',));
//                                   },
//                                 ),
//                               )
                           
                          
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