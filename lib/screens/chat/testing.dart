import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class DrawingArea extends StatefulWidget {
  @override
  _DrawingAreaState createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<DrawingArea> {
  List<Offset> points = [];
  String area="";

   File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
@override
void initState() {
  super.initState();
  _pickImage();
  
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
 appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(area)
       
        ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: FileImage(_image!),fit: BoxFit.fill)
        ),
        child: GestureDetector(
          onPanStart: (details) {
            points.clear();
          },
          onPanUpdate: (details) {
        
            setState(() {
              points.add(details.localPosition);
            });
          },
          onPanEnd: (details) {
            double areaInSquarePixels = calculatePolygonArea(points);
            double areaInSquareCm =
                convertPixelsToCmSquared(areaInSquarePixels, context);
            print("Area of the drawn shape: $areaInSquareCm");
             setState(() {
              area="${areaInSquareCm.toStringAsFixed(2)} cm²";
            });
            // if(area.isNotEmpty){
            //   showAboutDialog(context: context);
            // }
            // points.clear();
          },
          child: CustomPaint(
            painter: ShapePainter(points),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  double calculatePolygonArea(List<Offset> points) {
    double area = 0.0;
    int n = points.length;
    if (n < 3) return 0.0;
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      area += points[i].dx * points[j].dy;
      area -= points[j].dx * points[i].dy;
    }
    area = area.abs() / 2.0;
    return area;
  }

  double convertPixelsToCmSquared(double areaInPixels, BuildContext context) {
    double pixelDensity = MediaQuery.of(context).devicePixelRatio;
    double cmPerPixel = 2.54 / (pixelDensity * 160.0);
    return areaInPixels * (cmPerPixel * cmPerPixel);
  }
}

class ShapePainter extends CustomPainter {
  final List<Offset> points;
  ShapePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
      //close shape line color
       Paint paint2 = Paint()
      ..color = Colors.blue.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
Paint fillPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5) 
      ..style = PaintingStyle.fill;

    if (points.isNotEmpty) {
      Path path = Path();
      path.addPolygon(points, true);
      canvas.drawPath(path, fillPaint);
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i], points[i + 1], paint);
        }
      }
      // Close the shape
      if (points.length > 2) {
        canvas.drawLine(points.last, points.first, paint2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
