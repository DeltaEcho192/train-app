import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:toast/toast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  List<String> names = [];
  String dateFinal = "Schicht:";
  String _udid = 'Unknown';
  int photoAmt = 0;
  StorageUploadTask _uploadTask;
  var txt = TextEditingController();
  var baustelle = TextEditingController();
  //
  //

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
      print("Counter" + photoAmt.toString());
      model.picName = fileName;
      model.picCheck = true;
      _uploadTask = _storage.ref().child(model.picName).putFile(_imageFile);

      names.add(fileName);
    });
    await _uploadTask.onComplete;
    print("Upload done");
    Toast.show("Upload Complete", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  //
  //

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
      //print("First item of array" + names[1]);
      _udid = udid;
    });
  }

  //
  //

  Map<String, bool> numbers = {
    'One': true,
    'Two': true,
    'Three': true,
  };

  Future<void> fetchChecklist(var baustelle) async {
    final response = await http
        .get('http://192.168.202.107:3000/test/' + baustelle.toString());

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //print(json.decode(response.body));

      var tagsJson = jsonDecode(response.body);
      List<String> tags = tagsJson != null ? List.from(tagsJson) : null;
      var working = numbers.keys;
      print(working);
      //numbers.clear();
      List<bool> boolIte = [];

      for (int i = 0; i < tags.length; i++) {
        print("Iterate");
        boolIte.add(true);
      }
      var testing = Map.fromIterables(tags, boolIte);
      print(tags);
      print(numbers);
      setState(() {
        numbers = testing;
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  //
  //

  @override
  void initState() {
    super.initState();
    fetchChecklist("Zurich-9221");
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
                  controller: baustelle,
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
                  fetchChecklist("Zurich-9222");
                },
                child: Text("Get Checklist"),
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
                    if (value == false) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text("Alert Dialog"),
                            content: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Flexible(
                                  child: new TextField(
                                    controller: txt,
                                    decoration: const InputDecoration(
                                        hintText: "Enter Problem"),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.photo_camera),
                                  onPressed: () =>
                                      (_pickImage(ImageSource.camera)),
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
                                  txt.clear();
                                  Navigator.of(context).pop();
                                },
                              ),
                              new FlatButton(
                                onPressed: () {
                                  data.error = txt.text;
                                  print(txt.text);
                                  txt.clear();
                                  Navigator.of(context).pop();
                                },
                                child: new Text("Confirm"),
                              )
                            ],
                          );
                        },
                      );
                    } else {
                      print("Returned to true");
                    }
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
