import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:chat_app/screens/supplier_screen.dart';
import 'package:chat_app/services/http_requests.dart';

class LoadingScreen extends StatefulWidget {
  static const id = 'loading_screen';

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final httpRequestBack = HttpRequestBack();

  @override
  void initState() {
    getDataAndPushScreen();
    super.initState();
  }

  void getDataAndPushScreen() async {
    final response = await httpRequestBack.getSupplierScreenData();
    final responseJson = jsonDecode(response.body);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierScreen(
          data: responseJson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SpinKitDoubleBounce(
        color: Colors.blueAccent[700],
        size: 60.0,
      ),
    ));
  }
}
