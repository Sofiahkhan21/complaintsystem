import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:complaintsystem/screens/chat/ChatScreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Messages extends StatefulWidget {
  Messages({Key? key}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  String? username;
  String? phone;
  String? email;

  String? role;
  String admin = 'Users';
  String users = 'admin';

  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> list = [
    {
      'name': 'Rohan Raj',
      'sub': 'Lorem Ipsum is simply text of the printing ...',
      'image':
          'https://images.unsplash.com/photo-1541647376583-8934aaf3448a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80',
      'date': '9 mins ago',
      'read': true
    },
  ];

  getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    phone = prefs.getString('phone');
    email = prefs.getString('email');
    print(role);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUid();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: TextWidget(
          text: "Chats",
        ),
      ),
      body: Container(
        height: height,
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('${role == 'admin' ? admin : users}')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: CircularProgressIndicator());
              }

              final data = snapshot.data!.docs.length;
              print(data);
              // print(widget.body);

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  print(snapshot.data!.docs.length);

                  var document = snapshot.data!.docs[index];
                  var eml = document.get('email');
                  print(eml);
                  if (eml == email) {
                    return Container();
                  } else {
                    return Container(
                      child: ListTile(
                        onTap: () {
                          var route = MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  name: document.get('username'),
                                  image: '${list[0]['image']}',
                                  uid: eml));
                          Navigator.push(context, route);
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(document['image']),
                        ),
                        title: Text(document.get('phone')),
                        // subtitle: Column(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     Text(document.id),
                        //     Text(document.get('email')),
                        //   ],
                        //),
                      ),
                    );
                  }
                },
              );
            }),
        // child: StreamBuilder(
        //   stream: users.snapshots(),
        //   builder: (BuildContext context, AsyncSnapshot snapshot) {
        //     if (snapshot.hasData) {
        //       return ListView.separated(
        //           separatorBuilder: (context, index) => Divider(),
        //           itemCount: 5,
        //           itemBuilder: (context, index) {
        //             var item = snapshot.data.docs[index];
        //             if (globals.uid == item['id']) {
        //               return Container();
        //             } else {
        //               return Container(
        //                 child: ListTile(
        //                   onTap: () {
        //                             var route = MaterialPageRoute(
        //                                 builder: (context) => ChatScreen(
        //                                     name: '${list[0]['name']}',
        //                                     image: '${list[0]['image']}',
        //                                     uid: '${item['id']}'));
        //                             Navigator.push(context, route);
        //                           },
        //                   leading: CircleAvatar(
        //                     backgroundImage:
        //                         NetworkImage('${list[0]['image']}'),
        //                   ),
        //                   title: Text('${list[0]['name']}'),
        //                   subtitle: Text('${item['id']}'),

        //                 ),
        //               );
        //             }
        //           });
        //     } else {
        //       return Center(child: CircularProgressIndicator());
        //     }
        //   },
        // ),
        // child: ListView.separated(
        //     separatorBuilder: (context, index) => Divider(),
        //     itemCount: list.length,
        //     itemBuilder: (context, index) {
        //       return Container(
        //         child: ListTile(
        //           onTap: () => navigator.push(context, ChatScreen(name: list[index]['name'],)),
        //           leading: CircleAvatar(
        //             backgroundImage: NetworkImage('${list[index]['image']}'),
        //           ),
        //           title: Text('${list[index]['name']}'),
        //           subtitle: Text('${list[index]['sub']}'),
        //           trailing: Text('${list[index]['date']}'),
        //         ),
        //       );
        //     }),
      ),
    );
  }
}
