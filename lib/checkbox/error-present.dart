import 'package:flutter/material.dart';

void main() => runApp(ErrorInfo());

class ErrorInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error Testing',
      home: ErrorTest(),
    );
  }
}

class ErrorTest extends StatelessWidget {
  ErrorTest();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Check')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: TextField(
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Enter a search term'),
            ),
          ),
          Container(
            child: Text("Test2"),
          ),
          Container(
            child: Text("Test3"),
          ),
          Container(
            child: Text("Test4"),
          ),
        ],
      ),
    );
  }
}
