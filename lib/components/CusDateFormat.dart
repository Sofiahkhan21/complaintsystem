import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CusDateFormat {
 

  static getDate(DateTime date) => DateFormat('hh.mm a - dd MMMM yyyy').format(date);
  static gettime(DateTime date) => DateFormat('MMdyyyyhhs').format(date);
 static todaytime(DateTime time) => DateFormat('hh:mm a').format(time);
  static getdday(DateTime today) => DateFormat('dd MMM yyyy').format(today);
  static reminderdate(DateTime today) => DateFormat('dd').format(today);
  static remindermonth(DateTime today) => DateFormat('MM').format(today);





}
