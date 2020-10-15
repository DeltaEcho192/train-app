import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../checkbox/data.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String error;
  Data data = Data();

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("StackoverFlow"),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _dialogCall(context);
        },
      ),
    );
  }

  Future<void> _dialogCall(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return MyDialog();
        });
  }
}

class MyDialog extends StatefulWidget {
  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  String imagePath;
  Image image = Image.asset("assets/cameraIcon.png");
  TextEditingController txt;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Img Testing"),
        content: Column(
          children: <Widget>[
            new TextField(
              controller: txt,
              minLines: 5,
              maxLines: 7,
              decoration: const InputDecoration(
                hintText: "Enter Problem",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            IconButton(
              icon: image,
              onPressed: () {
                print("Get photo");
              },
            ),
            FlatButton(
              onPressed: () {
                imageLoad('images/2020-10-14 14:44:58.748341.png')
                    .then((value) => {setState(() {})});
              },
              child: new Text("Load"),
            ),
            FlatButton(
              onPressed: () {
                // = txt.text;
              },
            )
          ],
        ));
  }

  Future imageLoad(String fileName) async {
    final FirebaseStorage storage = FirebaseStorage(
        app: Firestore.instance.app,
        storageBucket: 'gs://train-app-287911.appspot.com');

    var ref = storage.ref().child(fileName);
    var url = await ref.getDownloadURL();
    image = Image.network(url);
  }
}
