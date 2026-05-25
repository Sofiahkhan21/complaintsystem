// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MissingChild extends StatefulWidget {
  const MissingChild({Key? key}) : super(key: key);

  @override
  State<MissingChild> createState() => _MissingChildState();
}

class _MissingChildState extends State<MissingChild> {
  bool isLostSelected = true;
  List<Map<String, dynamic>> lostItems = [
    {
      'childName': 'Alina',
      'fatherName': 'Khanzada',
      'Age': '11',
      'Contact': '03035544214',
      'image': 'image_url_1',
    },
    {
      'childName': 'Sana ',
      'fatherName': 'Sikandar',
      'Age': '9',
      'Contact': '03035544214',
      'image': 'image_url_2',
    },
  ];

  List<Map<String, dynamic>> recoveredItems = [
    {
      'childName': 'Shabana',
      'fatherName': 'Jawad khan',
      'Age': '10',
      'Contact': '03035544214',
      'image': 'image_url_1',
    },
    {
      'childName': 'Sapna',
      'fatherName': 'Sayed Anwar',
      'Age': '8',
      'Contact': '03035544214',
      'image': 'image_url_2',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[400],
        centerTitle: true,
        title: Text(
          'Missing Child',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLostSelected = true;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 120,
                    color:
                        isLostSelected ? Colors.green[700] : Colors.green[300],
                    child: Center(
                      child: Text(
                        'Lost',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isLostSelected = false;
                    });
                  },
                  child: Container(
                    height: 50,
                    width: 120,
                    color:
                        !isLostSelected ? Colors.green[700] : Colors.green[300],
                    child: Center(
                      child: Text(
                        'Recovered',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            isLostSelected
                ? Expanded(
                    child: ListView.builder(
                      itemCount: lostItems.length,
                      itemBuilder: (context, index) {
                        final item = lostItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Card(
                            color: Colors.grey[100],
                            child: ListTile(
                              leading: Image.asset('assets/baby.jpg'),
                              title: Text(item['childName']),
                              subtitle: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Father: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: item['fatherName'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    TextSpan(
                                      text: '\nAge: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: item['age'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    TextSpan(
                                      text: '\nContact: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: item['contact'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: recoveredItems.length,
                      itemBuilder: (context, index) {
                        final item = recoveredItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Card(
                            color: Colors.grey[100],
                            child: ListTile(
                              leading: Image.asset(
                                'assets/baby2.jpeg',
                                width: 60,
                                height: 60,
                              ),
                              title: Text(item['childName']),
                              subtitle: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Father: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: item['fatherName'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    TextSpan(
                                      text: '\nAge:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: item['age'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                    TextSpan(
                                      text: '\nContact: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: item['contact'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
