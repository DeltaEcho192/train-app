import 'package:flutter/material.dart';

void main() {
  runApp(new SuccessV1());
}

class SuccessV1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
        ),
        body: Center(
          child: Text('Hello World You are logged in'),
        ),
      ),
    );
  }
}
