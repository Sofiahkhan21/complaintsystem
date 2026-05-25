import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:googleapis_auth/auth_io.dart';


class ComplaintProvider extends ChangeNotifier {
  String? opencom = '0';
  String? process = '0';
  String? closed = '0';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void getdata() async {
    await _firestore
        .collection('complaint')
        .where('status', isEqualTo: 'Open')
        .get()
        .then((value) => {
              opencom = value.docs.length.toString(),
            });

    await _firestore
        .collection('complaint')
        .where('status', isEqualTo: 'In Process')
        .get()
        .then((value) => {
              process = value.docs.length.toString(),
            });
    await _firestore
        .collection('complaint')
        .where('status', isEqualTo: 'Closed')
        .get()
        .then((value) => {
              closed = value.docs.length.toString(),
            });
    notifyListeners();
  }



  

  bool isLoading=false;
    Future<String> getAccessToken() async {
    print('Strt');
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "compalintsystem",
          "private_key_id": "fbc5cd461175034fafd7fe361ec6db61a99cd735",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDiK4TU21CgVt6J\nUClBymRGeEqqEWbi8DoiBa1nPc+Y9z/MM7rzdKaI3pZAV3V6bdu3vuiwLzHi7Fdv\nM2zLtEGmGSUXAF9tL/+nQabB2t/kxqDhsim4Ku3kwRyXQ3krAhCwj9VCRL/4uITs\n2iMvXmlk/KWqVIAnGJE+JKUvrwUcdgMngnVb8TnzTktueeUVpVMevDyb4tYTyNi+\n3Cxeh3w2LIDhD+bKz1UPpXn2KWDXKYAgmOIAqH22Vk++WSJU5dyYucyt/qYnTYbT\nEsiD0tmIFuorT7/0YwS0j9m7o2udqTbCVgxqrZnplzxLFv2e5DvdO6LCjULRuPz1\n4WFcNlRbAgMBAAECggEAb/cTXzzjgT0AFgI1KnjDg49xhxfuU1KRtN4SphWXfCaK\n0tCZMIUDHKb0ww2I/v770s8T6oSysaBG+KoApieqiEvSbLymgStN6MM7hqSQSnV6\nl8DXnnDCLIjdWpTwmzX+hSnvbUsTrlHKnGaxHHYkvvXEHbqPZstmu9jwXdbLNPbZ\nAeNiUrWN5i9asqXu8pgZQPfg6MlnJcVz5PA/Qz+BjCsfdB5ByDAtmULMSHW4SE9c\nNdVsI3C/IHqAZpCOKpJ7N8Qox5pNYAwjm0fLnChYktWiLwPNwnRMLXB16ZGnKnn9\nid+01umEBcwN1LBYK7ty6bYqjy41mydce5piqQHjgQKBgQDxqe3Im2vWCVRAEBw0\n9wRJKkwXxsVI/u7Bckk455EyFewaHEdCS60gqXn64NMPdH3ZPK/+lRAdCT8OFGmx\nukkueboduSOiTsS9K1NHQ6A/WtGsRyra+Vl6466NP2rWLcQqflWw8boQZODWJfdC\nLTvPNW/h22J9NMna23LUyAWc6wKBgQDvlkpwa5661oZMn4lji78meoE8V0pu0edt\nupEWWEMK0KWPlZ3UU09bHUo5x2UFHY1pTaE6FTwBuk1xD8dRlddO8ZX6TAmHoWo9\nBOyNf0pk8CYdD79KPtkR3civer20711k3If1SQ2VlJ6CazTG/r5Owctneh0xq7ql\n+k+BeUuKUQKBgQC5gfwqNkR9NQQbeUJt1gDQOUvYJJllA207ygMzT29Bx1pKYNLC\nrVzk6bPdRaA/COliTRe8kaig4Wwp3rmT2LA8oOyhzHDyMw0LOarf1aW5fHnfiXH4\nTdjGYOipPLlCWDdxdzFIdwahdw6w1MwNXLPAyABum/3qpw8clcB8Xl8QqQKBgC2t\nus2KRz4aDornU9tt1mjwrFkjz2YnkPcjvevDsiyKsTYZ8Xh81cFqaS9w67q48rAk\nA9w+Fi3CJmeq+XZ9mgpMFysceiioxseRe8RSg42RF8MssGzoZJx6a3vBbA/mHylO\nvoEuh2+AYWQ+KlbSVNhRLIWzC4Pf2PsyKRxnUtaxAoGACN7OSyuk+qX2ddt9CXXR\nUtak0pPlGBnxM80I6VzY/2FeCFx0yJAH0AbR5PN76LX+oVX/1numWgKaAfhWxpw0\nF5DwdLVTykx9V1I1rbHOWcKvPY1Hso2GsvHGtjtuvfTkZc3NpVDeODF0Vzak8K6Z\n3bmJjr/ljLdsLUWxMtke7CE=\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-pjf6m@compalintsystem.iam.gserviceaccount.com",
          "client_id": "105894384221462923758",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-pjf6m%40compalintsystem.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        scopes);
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
String? accessToken;
 reportComplaint({userList,bodyMap,title,body,id}) async {
  print(userList);
    accessToken = await getAccessToken();
  
    print(accessToken);
  //   isLoading = true;
  // notifyListeners();
  
    print('hello');
  
    String response = "Sending.....";
    try {
      print('start');
      if(id=='new'){
        await _firestore.collection('complaint').doc().set(bodyMap);

      }

   
      response = 'Submit Successfully';
      

      for (int i = 0; i < (userList as List).length; i++) {
        final Map<String, dynamic> message = {
          "message": {
            "token": userList[i],
            "notification": {
              "title": "$title",
              "body": body
            },
            "android": {"priority": "HIGH"},
            "apns": {
              "headers": {"apns-priority": "10"},
            },
            'data': {'name': 'complaint', 'id': id}
          },
        };

        final response = await http.post(
          Uri.parse(
              'https://fcm.googleapis.com/v1/projects/compalintsystem/messages:send'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: json.encode(message),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully!');
        } else {
          print(
              'Failed to send notification: ${response.statusCode} ${response.body}');
        }
      }
    } catch (err) {
      response = 'error';
    }
    notifyListeners();
  }
}
