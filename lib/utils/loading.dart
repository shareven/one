import 'package:flutter/material.dart';

class Loading {
  static hideLoading(context){
    Navigator.pop(context);
  }


  static showLoading(context,{text}) {
    // Navigator.of(context).push(Builder: () {});
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
               child: CircularProgressIndicator(),
          );
        });
  }
}
