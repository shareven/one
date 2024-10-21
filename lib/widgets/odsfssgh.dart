import 'package:flutter/material.dart';
import 'package:one/utils/utils.dart';

class Odsfssgh extends StatefulWidget {
  const Odsfssgh({super.key});

  @override
  State<Odsfssgh> createState() => _OdsfssghState();
}

class _OdsfssghState extends State<Odsfssgh> {
  List<String>? list;
  bool isSfff = false;
  String valdk = "6173736574732F66696C65732F475F32303234313031395F313931333538";

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    List resList = await getloisjd(valdk);
    setState(() {
      list = resList[0];
      isSfff = resList[1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return isSfff
        ? GestureDetector(
            onTap: () => awdfadfadf(context, valdk, list, getData),
            child: Image.asset(hexToString(valdk)))
        : Text("");
  }
}
