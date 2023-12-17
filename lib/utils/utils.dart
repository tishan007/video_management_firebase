import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {

  static void successToast(String successMsg) {
    Fluttertoast.showToast(msg: successMsg, backgroundColor: Colors.green, gravity: ToastGravity.BOTTOM,);
  }

  static void errorToast(String errorMsg) {
    Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.redAccent, gravity: ToastGravity.BOTTOM,);
  }

  static void warningToast(String warningMsg) {
    Fluttertoast.showToast(msg: warningMsg, backgroundColor: Colors.amber, gravity: ToastGravity.BOTTOM,);
  }

}