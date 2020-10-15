import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Future Builder Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseStorage storage = FirebaseStorage(
      app: Firestore.instance.app,
      storageBucket: 'gs://train-app-287911.appspot.com');

  Uint8List imageBytes;
  String errorMsg;

  Future<void> imageLoad(String fileName) async {
    storage
        .ref()
        .child(fileName)
        .getData(10000000)
        .then((data) => setState(() {
              imageBytes = data;
            }))
        .catchError((e) => setState(() {
              errorMsg = e.error;
            }));
  }

  @override
  Widget build(BuildContext context) {
    var img = imageBytes != null
        ? Image.memory(
            imageBytes,
            fit: BoxFit.cover,
          )
        : Icon(Icons.camera);

    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Testing"),
        ),
        body: Column(
          children: <Widget>[
            new FlatButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text("Img Testing"),
                            content: Column(
                              children: <Widget>[
                                IconButton(
                                  icon: img,
                                  onPressed: () {
                                    print("Get photo");
                                  },
                                ),
                                FlatButton(
                                  onPressed: () {
                                    imageLoad(
                                            'images/2020-10-14 14:44:58.748341.png')
                                        .then((value) => print("Done Getting"));
                                  },
                                  child: new Text("Load"),
                                )
                              ],
                            ));
                      });
                },
                child: Text("Img Test")),
          ],
        ));
  }
}
