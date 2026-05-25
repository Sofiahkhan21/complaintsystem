import 'package:complaintsystem/components/my_colors.dart';
import 'package:complaintsystem/components/text_widget.dart';
import 'package:flutter/material.dart';
class ViewAttach extends StatefulWidget {
  final attachList;
  const ViewAttach({super.key,this.attachList});

  @override
  State<ViewAttach> createState() => _ViewAttachState();
}

class _ViewAttachState extends State<ViewAttach> {
  List imageList=[];
  @override
  void initState() {
    super.initState();
    imageList=(widget.attachList as List);
    print(imageList.length);
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: MyColors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: TextWidget(text: 'Attach File',textcolor: Colors.white,)),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height-70,
            child: ListView.builder(
              itemCount: imageList.length,
              itemBuilder: (BuildContext context, int index) {
                return  Center(
              child: Container(
               
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Image.network(
                  '${imageList[index]}',
                  fit: BoxFit.contain,
                ),
              ),
            );
              },
            ),
          ),
        ),
      
    );
  }
}