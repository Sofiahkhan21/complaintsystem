import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final name;
  final image;
  final uid;

  ChatScreen({
    Key? key,
    this.name,
    this.image,
    this.uid,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  final _fieldController = TextEditingController();
  Map<String, dynamic> msg = {};
  int myId = 1;
  int otherPersonId = 2;
   String getChannel() {
   
      return '${email}-${widget.uid}';
    
  }

  @override
  void initState() {
    super.initState();
    print('////////////////////////////////////////////');

    getUid();
  }

  String? username;
  String? email;
  String? role;
  

  getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    email = prefs.getString('email');
    role = prefs.getString('role');


    setState(() {});
    // print(getChannel());
  }

  getread() {}
  DateTime date = DateTime.now();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('${widget.image}'),
            ),
            SizedBox(
              width: 5,
            ),
            Text("${widget.name}"),
          ],
        ),
        leadingWidth: 30,
        actions: [],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timeStamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                print("..............");
                if (snapshot.hasData) {
                  print("..............");

                  print(snapshot.data!.size);
                  print("..............");
                  return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        //       FirebaseFirestore.instance.collection('messages')
                        // .doc(username).update({'read': true});
                        var item = snapshot.data!.docs[index].data();
                        print("????/");
                        print(item['sender']);
                        print(item['receiver']);
                        print(widget.uid);
                        print(email);

                        print("????/");

                        if (item['sender'] == email &&
                                item['receiver'] == widget.uid ||
                            item['sender'] == widget.uid &&
                                item['receiver'] == email) {
                          if (email == item['sender']) {
                            return cardcont(width, '${item['data']}',
                                "${widget.image}", '${item['time']}',
                                icon: item['read'] == true
                                    ? Icons.check
                                    : Icons.rectangle_outlined,
                                iconcolor: item['read'] == true
                                    ? Colors.green
                                    : Colors.grey,
                                onLongPress: () {});
                          } else {
                            FirebaseFirestore.instance
                                .collection('messages')
                                .doc('${item['timeStamp']}')
                                .update({'read': true});
                            return receivercard(width, '${item['data']}',
                                "${widget.image}", '${item['time']}',
                                onLongPress: () {});
                          }
                        }
                        return null;
                      });
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )),
            Container(
                margin:
                    EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 3),
                // decoration:
                //     BoxDecoration(border: Border.all(color: Colors.green)),
                child: Card(
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        width: width - 90,
                        child: TextField(
                          controller: _fieldController,
                          decoration: InputDecoration(
                            hintText: "Type a message",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                            icon: Icon(Icons.send),
                            onPressed: () {
                               String channel = getChannel();
                              String timeStamp = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              FirebaseFirestore.instance
                                  .collection('messages')
                                  // .doc("$username")
                                  // .collection("$username")
                                  .doc(timeStamp)
                                  .set({
                                'sender': email,
                                'receiver': widget.uid,
                                'data': '${_fieldController.text}',
                                'time': '${CusDateFormat.todaytime(date)}',
                                'image':
                                    'https://i.pinimg.com/736x/93/f4/0e/93f40ec756290812571be534e12bcfe7.jpg',
                                'timeStamp': timeStamp,
                                'read': false,
                              });
                              if(role!='admin'){
                                  FirebaseFirestore.instance
                                  .collection('msgsList')
                                  .doc(timeStamp).collection(channel).doc(channel)
                                  
                                  .set({
                                        'sender': email,
                                'receiver': widget.uid,
                                'sub': '${_fieldController.text}',
                                'time': '${CusDateFormat.todaytime(date)}',
                                'image':
                                    'https://i.pinimg.com/736x/93/f4/0e/93f40ec756290812571be534e12bcfe7.jpg',
                                'timeStamp': timeStamp,
                                'read': false,
                                'username':username,
                               
     
    
     
    
                                  });

                              }

                            
                                    setState(() {
                                _fieldController.clear();
                              });
                            }),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  cardcont(double width, String data, String image, String time,
      {Function? onLongPress, Color? iconcolor, IconData? icon}) {
    return InkWell(
        onLongPress: () => onLongPress!(),
        child: Container(
          margin: EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10, right: 10, left: 25),
                padding: EdgeInsets.all(15),
                // width: width,
                constraints: BoxConstraints(maxWidth: width - 130),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(7),
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    )),
                child: Column(
                  children: [
                    Text('$data'),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage("$image"),
                    ),
                    Row(
                      children: [
                        Container(
                          child: TextWidget(
                            text: '$time',
                            size: 10,
                          ),
                        ),
                        Icon(
                          icon,
                          size: 12,
                          color: iconcolor,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  receivercard(double width, String data, String image, String time,
      {Function? onLongPress}) {
    return InkWell(
        onLongPress: () {
          // FirebaseFirestore.instance
          //     .collection('messages')
          //     .doc(getChannel())
          //     .collection(getChannel())
          //     .doc(item['timeStamp'])
          //     .delete();
        },
        child: Container(
          margin: EdgeInsets.only(left: 10),
          child: Row(
            children: <Widget>[
              Container(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(image),
                ),
              ),
              Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                  margin: EdgeInsets.only(top: 10, right: 25, left: 10),
                  // width: width,
                  constraints: BoxConstraints(maxWidth: width - 130),
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(25),
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data,
                        style: TextStyle(color: Colors.black),
                      ),
                      Container(
                        // alignment: Alignment.topRight,
                        child: TextWidget(
                          text: time,
                          size: 10,
                        ),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }

  functnList() {}
}
