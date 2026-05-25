import 'package:flutter/material.dart';
class ChooseImage extends StatelessWidget {
  final String? imageFile;
  final Function? onTab;
final double? height;
final BorderRadiusGeometry? borderradius;
final BoxBorder? border;
final BoxBorder? border2;
  const ChooseImage({Key? key,this.imageFile,this.onTab,this.height,this.border,this.borderradius,this.border2}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
              padding: EdgeInsets.only(left: 20, right: 10),
      
                height: height,
                decoration: BoxDecoration(
                    borderRadius: borderradius,
                    border: border),
                child: Row(
                  children: [
                    Container(
                      height: 25,
                      padding: EdgeInsets.all(5),
                     // margin: EdgeInsets.only(right: 10, left: 10),
                      decoration: BoxDecoration(
                          border:border2,
                          borderRadius: BorderRadius.circular(1)),
                      child: InkWell(
                          onTap: ()=>onTab!(),
                          child: Text('Choose file',
                              style: TextStyle(fontSize: 11))),
                    ),
                    imageFile != null
                        ? Expanded(
                            child: Container(
                              height: 20,
                              child: Text(
                                imageFile!.split('/').last,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          )
                        : Text('No file choosen')
                  ],
                ),
              );
  }
}