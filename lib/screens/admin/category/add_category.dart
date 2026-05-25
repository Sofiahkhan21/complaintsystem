import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({super.key});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  var feedbackcontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  addCat() async {
    await _firestore.collection('category').doc(feedbackcontroller.text).set({
      "categoryName": feedbackcontroller.text,
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
          'Category',
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
                      title: Text('Add Category'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0).w,
                        child: SingleChildScrollView(
                          child: TextFormField(
                            // maxLines: 3,
                            keyboardType: TextInputType.text,
                            controller: feedbackcontroller,

                            decoration: InputDecoration(
                              hintText: 'Category Name',
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
            stream: _firestore.collection('category').snapshots(),
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
                            padding: EdgeInsets.only(left: 10,right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                     Icon(
                                    Icons.circle,
                                    size: 18,
                                    color: MyColors.blue,
                                  ),
                                  SizedBox(width: 10,),
                                  TextWidget(text:'${item2['categoryName']}',size: 16,),
                            
                                  ],
                                ),
                              
                               Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              feedbackcontroller.text =
                                                  '${item2['categoryName']}';
                                            });
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text('Update Category'),
                                                    content: Padding(
                                                      padding:
                                                          const EdgeInsets.all(8.0).w,
                                                      child: SingleChildScrollView(
                                                        child: TextFormField(
                                                          // maxLines: 3,
                                                          keyboardType:
                                                              TextInputType.text,
                                                          controller:
                                                              feedbackcontroller,
                                
                                                          decoration: InputDecoration(
                                                            hintText:
                                                                '${item2['categoryName']}',
                                                            hintStyle: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: Color.fromARGB(
                                                                  255, 2, 64, 114),
                                                            ),
                                                            filled: true,
                                                            isDense: true,
                                                            border: OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide.none,
                                                                borderRadius:
                                                                    BorderRadius
                                                                            .circular(
                                                                                15)
                                                                        .w),
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
                                                        onPressed: () async {
                                                          await _firestore
                                                              .collection('category')
                                                              .doc(docId)
                                                              .update({
                                                            'categoryName':
                                                                feedbackcontroller.text
                                                          });
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Text('Update'),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          icon: Icon(Icons.edit)),
                                      IconButton(
                                          onPressed: () async {
                                            await _firestore
                                                .collection('category')
                                                .doc(docId)
                                                .delete();
                                           // Navigator.of(context).pop();
                                          },
                                          icon: Icon(Icons.delete_outline)),
                                    ],
                                  ),
                              
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
  buttonCont(){
    return GestureDetector(
      child: Container(
        child: TextWidget(),
      ),
    );
  }
}
