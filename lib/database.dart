import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'main.dart';

class DataAdder extends StatefulWidget {
  Model model;
  TestForm testForm;

  DataAdder({Key key, this.model}) : super(key: key);
  createState() => _DataState();
}

class _DataState extends State<DataAdder> {
  final firestoreInstance = Firestore.instance;

  /// Starts an upload task
  void _uploadData() {
    firestoreInstance.collection("issues").add({
      "check": widget.model.checkBox,
      "description": widget.model.description,
      "location": widget.model.location,
      "name": widget.model.firstName,
      "photo_id": widget.model.picName
    }).then((value) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: new Text("Data Has Been added"),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("Close"))
          ],
        ),
      );
      print(value.documentID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      label: Text('Upload Information'),
      icon: Icon(Icons.cloud_upload),
      onPressed: _uploadData,
    );
  }
}
