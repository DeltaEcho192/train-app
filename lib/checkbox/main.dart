import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'testScreen.dart';
import 'dart:io';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart' as validator;
import 'package:firebase_storage/firebase_storage.dart';
import '../model.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("Flutter Create Checkbox Dynamically"),
          ),
          body: SafeArea(
              child: Center(
            child: CheckboxWidget(),
          ))),
    );
  }
}

class CheckboxWidget extends StatefulWidget {
  @override
  CheckboxWidgetState createState() => new CheckboxWidgetState();
}

class CheckboxWidgetState extends State {
  bool exec = false;
  File _imageFile;
  String locWorking;
  Model model = Model();
  Data data = Data();
  String dateFinal = "Schicht:";
  String _udid = 'Unknown';
  StorageUploadTask _uploadTask;
  var txt = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    //Make sure network is connected!!!!
    //TODO Add pop up if there is no network

    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://train-app-287911.appspot.com');

    // ignore: unused_local_variable

    setState(() {
      _imageFile = selected;
      String fileName = 'images/${DateTime.now()}.png';
      model.picName = fileName;
      model.picCheck = true;
      _uploadTask = _storage.ref().child(model.picName).putFile(_imageFile);
    });
  }

  Future<void> getUDID() async {
    String udid;
    try {
      udid = await FlutterUdid.udid;
    } on PlatformException {
      udid = 'Failed to get UDID.';
    }

    if (!mounted) return;

    setState(() {
      print(udid);
      _udid = udid;
    });
  }

  Map<String, bool> numbers = {
    'One': false,
    'Two': false,
    'Three': false,
    'Four': false,
    'Five': false,
    'Six': false,
    'Test': false,
  };

  var holder_1 = [];

  getItems() {
    numbers.forEach((key, value) {
      if (value == true) {
        holder_1.add(key);
      }
    });

    // Printing all selected items on Terminal screen.
    print(holder_1);
    // Here you will get all your selected Checkbox items.

    // Clear array after use.
    holder_1.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Flexible(
                child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Baustelle'),
                ),
              ),
              FlatButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2020, 1, 1),
                      maxTime: DateTime(2099, 12, 31), onChanged: (date) {
                    print('change $date');
                  }, onConfirm: (date) {
                    print('confirm $date');
                    data.schicht = date;
                    setState(() {
                      String dayW = date.day.toString();
                      String monthW = date.month.toString();
                      String yearW = date.year.toString();
                      String working = dayW + '/' + monthW + '/' + yearW;
                      print(working);
                      dateFinal = working;
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.de);
                },
                child: Text(
                  dateFinal,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              FlatButton(
                onPressed: () {
                  getUDID();
                },
                child: Text("Get UDID"),
              ),
            ]),
        Expanded(
          child: ListView(
            children: numbers.keys.map((String key) {
              return new CheckboxListTile(
                title: new Text(key),
                value: numbers[key],
                activeColor: Colors.pink,
                checkColor: Colors.white,
                onChanged: (bool value) {
                  setState(() {
                    numbers[key] = value;
                    exec = true;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // return object of type Dialog
                        return AlertDialog(
                          title: new Text("Alert Dialog title"),
                          content: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Flexible(
                                child: new TextField(
                                  decoration: const InputDecoration(
                                      hintText: "Enter App ID"),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.photo_camera),
                                onPressed: () => _pickImage(ImageSource.camera),
                              ),
                              IconButton(
                                icon: Icon(Icons.mic),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            // usually buttons at the bottom of the dialog
                            new FlatButton(
                              child: new Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
