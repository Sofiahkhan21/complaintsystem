import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class TextLocation extends StatefulWidget {
  TextLocation({Key? key}) : super(key: key);

  @override
  State<TextLocation> createState() => _TextLocationState();
}

class _TextLocationState extends State<TextLocation> {
   List adminLocList = [];
   var doc;
      double minDistance = double.infinity;

  getadminLocList() {
    adminLocList.clear();
    var location;
    FirebaseFirestore.instance
        .collection("admin_location")
        .snapshots()
        .listen((event) {
     // print(event.docs.length);
       doc = event.docs;
      for (int j = 0; j < 3; j++) {
        for (int i = 0; i < doc.length; i++) {
          double distance = calculateDistance(34.0017808, 71.5005202,
              double.parse(doc[i]['lat']), double.parse(doc[i]['long']));
          //print(distance);
         // print(doc[i]['name']);
          // print(minDistance);
          if (adminLocList.contains(minDistance)) {
            doc.remove(doc[i]);

            //print('Call Back');
          }
           if (distance < minDistance) {
            minDistance = distance;
            location = doc[i];
            adminLocList.add(minDistance);
            setState(() {});
         print('minDistance $minDistance');
          }
        }
         

        //  print('start');

        //   print(adminLocList.length);
        //   print(minDistance);

         // print(adminLocList[j]['name']);
          // print(adminLocList[j]['lat']);
          // print(adminLocList[j]['long']);
       //  print('end');

   }

      setState(() {});
    });
  }

  double calculateDistance(
      double userLat, double userLong, double targetLat, double targetLong) {
    const int earthRadius = 6371; // Earth's radius in kilometers

    double lat1Rad = userLat * (3.141592653589793 / 180);
    double lon1Rad = userLong * (3.141592653589793 / 180);
    double lat2Rad = targetLat * (3.141592653589793 / 180);
    double lon2Rad = targetLong * (3.141592653589793 / 180);

    double latDiff = lat2Rad - lat1Rad;
    double lonDiff = lon2Rad - lon1Rad;

    double a = pow(sin(latDiff / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(lonDiff / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
   print('distance'); // Distance in kilometers
   
   print(distance); // Distance in kilometers
    return distance;
  }
  @override
  void initState() {
    super.initState();
    getadminLocList() ;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:adminLocList.isEmpty?Container(): Container(
        child: ListView.builder(
          itemCount: adminLocList.length,
          itemBuilder: (BuildContext context, int index) {
            var item=adminLocList[index];
            return Column(
              children: [
                Text('${item}'),
                Text('${item}'),
                Text('${item}'),
                

                


              ],
            );
          },
        ),
      ),

    );
  }
}