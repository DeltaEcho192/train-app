import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../checkbox/data.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dialogScreen.dart';
import 'dialog.dart';
import 'size_helpers.dart';

class DialogScreen extends StatefulWidget {
  final DialogData dialogdata;
  DialogScreen({Key key, this.dialogdata}) : super(key: key);

  _DialogState createState() => new _DialogState();
}

class _DialogState extends State<DialogScreen> {
  bool exec = false;
  File _imageFile;
  File _imageFile2;
  String locWorking;
  DialogData data = DialogData();
  Model model = Model();
  Map<String, String> names = {};
  Map<String, String> errors = {};
  Map<String, String> comments = {};
  List<String> toDelete = [];
  String dateFinal = "Schicht:";
  String _udid = 'Unknown';
  int photoAmt = 0;
  int iteration = 0;
  Image cameraIcon = Image.asset("assets/cameraIcon.png");
  Image cameraIcon2 = Image.asset("assets/cameraIcon.png");
  StorageUploadTask _uploadTask;
  StorageUploadTask _uploadTask2;
  StorageUploadTask _deleteTask;
  var txt = TextEditingController();
  String baustelle;
  final bauController = TextEditingController(text: "Baustelle");
  var subtController = TextEditingController();
  String currentText = "";
  List<String> suggestions = ["Default"];
  FocusNode _focusNode;
  Icon checkboxIcon = new Icon(Icons.check_box);
  bool secondCheck = false;
  bool reportExist = false;
  String reportID;
  Uint8List imageBytes;
  Uint8List imageBytes2;
  String errorMsg;
  //
  //

  final FirebaseStorage storage = FirebaseStorage(
      app: Firestore.instance.app,
      storageBucket: 'gs://train-app-287911.appspot.com');
  Future<void> imageLoad(String fileName) async {
    storage
        .ref()
        .child(fileName)
        .getData(10000000)
        .then((data) => setState(() {
              imageBytes = data;
              cameraIcon = Image.memory(
                imageBytes,
                fit: BoxFit.cover,
              );
            }))
        .catchError((e) => setState(() {
              errorMsg = e.error;
            }));
  }

  Future<void> imageLoad2(String fileName) async {
    storage
        .ref()
        .child(fileName)
        .getData(10000000)
        .then((data) => setState(() {
              imageBytes2 = data;
              cameraIcon2 = Image.memory(
                imageBytes2,
                fit: BoxFit.cover,
              );
            }))
        .catchError((e) => setState(() {
              errorMsg = e.error;
            }));
  }

  //
  //

  Future<void> _pickImage(
    ImageSource source,
  ) async {
    File selected;
    final picker = ImagePicker();

    final pickedFile = await picker.getImage(source: source, imageQuality: 50);
    //Make sure network is connected!!!!
    //TODO Add pop up if there is no network

    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://train-app-287911.appspot.com');

    // ignore: unused_local_variable

    setState(() {
      _imageFile = File(pickedFile.path);
      String fileName = 'images/${DateTime.now()}.png';
      print("Counter" + photoAmt.toString());
      model.picName = fileName;
      model.picCheck = true;
      widget.dialogdata.image1 = fileName;
      cameraIcon = new Image.file(_imageFile);
      _uploadTask = _storage.ref().child(model.picName).putFile(_imageFile);

      //Adds all current photo names to an array
    });
    await _uploadTask.onComplete;
    print("Upload done");
    Toast.show("Bild ist auf Server gespeichert", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  Future<void> _pickImageSec(ImageSource source) async {
    File selected;
    final picker2 = ImagePicker();

    final pickedFile2 =
        await picker2.getImage(source: source, imageQuality: 50);
    //Make sure network is connected!!!!
    //TODO Add pop up if there is no network

    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://train-app-287911.appspot.com');

    // ignore: unused_local_variable

    setState(() {
      _imageFile2 = File(pickedFile2.path);
      String fileName = 'images/${DateTime.now()}.png';
      model.picName = fileName;
      model.picCheck = true;
      widget.dialogdata.image2 = fileName;
      cameraIcon2 = new Image.file(_imageFile2);
      _uploadTask2 = _storage.ref().child(fileName).putFile(_imageFile2);
    });
    await _uploadTask2.onComplete;
    print("Upload done on second");
    Toast.show("Bild ist auf Server gespeichert", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  //
  //

  void _imageCheck() {
    if (widget.dialogdata.image1 != null) {
      imageLoad(widget.dialogdata.image1);
    }
    if (widget.dialogdata.image2 != null) {
      imageLoad2(widget.dialogdata.image2);
    }
  }

  void _iconCheck() {
    print(widget.dialogdata.check);
    if (widget.dialogdata.check == false) {
      setState(() {
        checkboxIcon = Icon(Icons.check_box_outline_blank);
      });
    } else {
      setState() {
        checkboxIcon = Icon(Icons.check_box);
      }
    }
  }

  //
  //
  @override
  void initState() {
    super.initState();
    txt.text = widget.dialogdata.text;
    print(widget.dialogdata.image2);
    _iconCheck();
    _imageCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(232, 195, 30, 1),
        title: Text(widget.dialogdata.name),
        actions: [
          new IconButton(
            icon: new Icon(
              Icons.save,
              color: Colors.red[800],
            ),
            onPressed: () {
              widget.dialogdata.text = txt.text;
              Navigator.pop(context, widget.dialogdata);
            },
          )
        ],
      ),
      body: new Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: txt,
                  minLines: 5,
                  maxLines: 7,
                  onChanged: (String value) {
                    setState(() {
                      checkboxIcon = Icon(Icons.check_box_outline_blank);
                      secondCheck = false;
                      widget.dialogdata.check = false;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Problem Beschreibung",
                    contentPadding: const EdgeInsets.only(left: 10, right: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new SizedBox(
                height: 300,
                width: displayWidth(context) * 0.5,
                child: IconButton(
                  padding: new EdgeInsets.all(5.0),
                  icon: cameraIcon,
                  onPressed: () => (showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Selection"),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Select image from Image or Gallery'),
                            ],
                          ),
                        ),
                        actions: [
                          new FlatButton(
                              onPressed: () {
                                _pickImage(ImageSource.camera);
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.camera_alt)),
                          new FlatButton(
                              onPressed: () {
                                _pickImage(ImageSource.gallery);
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.collections))
                        ],
                      );
                    },
                  )),
                ),
              ),
              new SizedBox(
                width: displayWidth(context) * 0.5,
                height: 300,
                child: IconButton(
                  padding: new EdgeInsets.all(5.0),
                  icon: cameraIcon2,
                  onPressed: () => (showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Selection"),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Select image from Image or Gallery'),
                            ],
                          ),
                        ),
                        actions: [
                          new FlatButton(
                              onPressed: () {
                                _pickImageSec(ImageSource.camera);
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.camera_alt)),
                          new FlatButton(
                              onPressed: () {
                                _pickImageSec(ImageSource.gallery);
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.collections))
                        ],
                      );
                    },
                  )),
                ),
              )
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("Keine Probleme"),
              new IconButton(
                  icon: checkboxIcon,
                  onPressed: () {
                    if (widget.dialogdata.check == false) {
                      setState(() {
                        checkboxIcon = Icon(Icons.check_box);
                        secondCheck = true;
                        widget.dialogdata.check = true;
                      });
                    } else {
                      setState(() {
                        checkboxIcon = Icon(Icons.check_box_outline_blank);
                        secondCheck = false;
                        widget.dialogdata.check = false;
                      });
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
