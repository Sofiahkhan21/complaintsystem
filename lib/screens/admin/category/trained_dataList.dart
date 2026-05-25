import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class TrainedDatalist extends StatefulWidget {
  const TrainedDatalist({super.key});

  @override
  State<TrainedDatalist> createState() => _TrainedDatalistState();
}

class _TrainedDatalistState extends State<TrainedDatalist> {
  var feedbackcontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  addCat() async {
    String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _firestore.collection('AIData').doc(feedbackcontroller.text).set({
      "name": feedbackcontroller.text,
      'timeStamp':timeStamp
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 64, 114),
        title: Text(
          'AI Data',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                feedbackcontroller.clear();
              });
              
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Add Data'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0).w,
                        child: SingleChildScrollView(
                          child: TextFormField(
                            // maxLines: 3,
                            keyboardType: TextInputType.text,
                            controller: feedbackcontroller,

                            decoration: InputDecoration(
                              hintText: 'Data .....',
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
            },
            child: Container(
                alignment: Alignment.center,
                // color: Colors.red,
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                )),
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 40,
          child: StreamBuilder(
            stream: _firestore.collection('AIData').orderBy('timeStamp',descending: true) .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
             
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,childAspectRatio: 2.3
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                     var item2 = snapshot.data!.docs[index];
                      DocumentSnapshot id = snapshot.data!.docs[index];
                      String docId = id.id;

                      return Container(
                      // margin: EdgeInsets.only(left: 15,right: 15,top:5),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              //    Icon(
                              //   Icons.circle,
                              //   size: 18,
                              //   color: MyColors.blue,
                              // ),
                            
                              Container(
                                width: 70,
                                child: TextWidget(text:'${item2['name']}',size: 16,textoverflow: TextOverflow.ellipsis,)),
                               IconButton(
                                      onPressed: () async {
                                        await _firestore
                                            .collection('AIData')
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
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
  buttonCont(){
    return GestureDetector(
      child: Container(
        child: TextWidget(),
      ),
    );
  }
}
