import 'package:flutter/material.dart';

class MoreInfo extends StatelessWidget {
  MoreInfo();

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(title: Text('Test Check')),
      body: Container(
        child: Column(
          children: <Widget>[Text("Big Test")],
        ),
      ),
    ));
  }
}
