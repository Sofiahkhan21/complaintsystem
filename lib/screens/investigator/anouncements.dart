import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/CusDateFormat.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class Anouncements extends StatefulWidget {
  const Anouncements({super.key});

  @override
  State<Anouncements> createState() => _AnouncementsState();
}

class _AnouncementsState extends State<Anouncements> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var detailcontroller = TextEditingController();
  var typecontroller = TextEditingController();
  var titlecontroller = TextEditingController();

  
  addCat() async {
    await _firestore.collection('announcement').doc().set({
      "detail": detailcontroller.text,
      "type": typecontroller.text,
      "title": titlecontroller.text,
       "date": "${CusDateFormat.getDate(DateTime.now())}",

    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MyColors.blue,
        onPressed: (){
          setState(() {
                detailcontroller.clear();
                titlecontroller.clear();
                typecontroller.clear();
              });
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Announcements'),
                      content: Padding(
                        padding: const EdgeInsets.all(5.0).w,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                               TextFormField(
                                // maxLines: 3,
                                keyboardType: TextInputType.text,
                                controller: typecontroller,
                              
                                decoration: InputDecoration(
                                  hintText: 'Type',
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: Color.fromARGB(255, 2, 64, 114),
                                  ),
                                  filled: true,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(15).w),
                                  fillColor: Colors.grey[300],
                                ),
                                // validator: _validateComplaintDetails,
                                //  maxLength: 6,
                              ),
                              SizedBox(height: 5,),
                               TextFormField(
                                // maxLines: 3,
                                keyboardType: TextInputType.text,
                                controller: titlecontroller,
                              
                                decoration: InputDecoration(
                                  hintText: 'Title',
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: Color.fromARGB(255, 2, 64, 114),
                                  ),
                                  filled: true,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(15).w),
                                  fillColor: Colors.grey[300],
                                ),
                                // validator: _validateComplaintDetails,
                                //  maxLength: 6,
                              ),SizedBox(height: 5,),
                              TextFormField(
                               maxLines: 3,
                                keyboardType: TextInputType.text,
                                controller: detailcontroller,
                              
                                decoration: InputDecoration(
                                  hintText: 'Detail',
                                  hintStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: Color.fromARGB(255, 2, 64, 114),
                                  ),
                                  filled: true,
                                  isDense: true,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(15).w),
                                  fillColor: Colors.grey[300],
                                ),
                                // validator: _validateComplaintDetails,
                                //  maxLength: 6,
                              ),
                            ],
                          ),

                          // textAlign: TextAlign.left,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close'),
                        ),
                        TextButton(
                          onPressed: () {
                            addCat();
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  });
      }, child: Container(
                alignment: Alignment.center,
                // color: Colors.red,
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                )),),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 64, 114),
        title: Text(
          'Announcements',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 40,
          child: StreamBuilder(
            stream: _firestore.collection('announcement').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var item2 = snapshot.data!.docs[index];
                      DocumentSnapshot id = snapshot.data!.docs[index];
                      String docId = id.id;

                      return Container(
                       margin: EdgeInsets.only(left: 15,right: 15,top:5),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all( 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  
                                  SizedBox(height: 10,),
                                  TextWidget(text:'${item2['type']}',size: 16,),
                                  SizedBox(height: 10,),
                                  TextWidget(text:'${item2['title']}',size: 16,),SizedBox(height: 10,),
                                  TextWidget(text:'${item2['detail']}',size: 16,),
                            
                                  ],
                                ),
                              
                            
                                 
                                      IconButton(
                                          onPressed: () async {
                                            await _firestore
                                                .collection('announcement')
                                                .doc(docId)
                                                .delete();
                                           // Navigator.of(context).pop();
                                          },
                                          icon: Icon(Icons.close,color: Colors.red,)),
                                
                              
                              ],
                            ),
                          ),
                        ),
                      );
                      //  }else{
                      //    return Container(height: 0,);
                      //  }
                    });
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}