import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/loginKey.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: SafeArea(
              child: Center(
        child: CheckboxWidget(),
      ))),
    );
  }
}

class CheckboxWidget extends StatefulWidget {
  CheckboxWidget({Key key}) : super(key: key);
  @override
  CheckboxWidgetState createState() => new CheckboxWidgetState();
}

class CheckboxWidgetState extends State {
  bool exec = false;
  File _imageFile;
  File _imageFile2;
  String locWorking;
  Model model = Model();
  Data data = Data();
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
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  SimpleAutoCompleteTextField textField;
  FocusNode _focusNode;
  Icon checkboxIcon = new Icon(Icons.check_box);
  bool secondCheck = false;
  bool reportExist = false;
  DateTime timeStart;
  DateTime timeEnd;

  //
  //

  //Takes a picture from camera and then uploads its to Firebase Storage
  Future<void> _pickImage(
    ImageSource source,
    String key,
  ) async {
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
      cameraIcon = new Image.file(_imageFile);
      _uploadTask = _storage.ref().child(model.picName).putFile(_imageFile);
      //Adds all current photo names to an array
      names[key] = fileName;
    });
    await _uploadTask.onComplete;
    print("Upload done");
    Toast.show("Upload Complete", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  //
  //

  Future<void> deleteCanceledFiles(List deletion) {
    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://train-app-287911.appspot.com');
    for (int i = 0; i < deletion.length; i++) {
      _storage.ref().child(deletion[i]).delete();
    }
  }

  //
  //

  Future<void> _pickImageSec(ImageSource source, String key) async {
    File selected2 = await ImagePicker.pickImage(source: source);
    //Make sure network is connected!!!!
    //TODO Add pop up if there is no network

    final FirebaseStorage _storage =
        FirebaseStorage(storageBucket: 'gs://train-app-287911.appspot.com');

    // ignore: unused_local_variable

    setState(() {
      _imageFile2 = selected2;
      String fileName = 'images/${DateTime.now()}.png';
      print("Counter" + photoAmt.toString());
      model.picName = fileName;
      model.picCheck = true;
      String newKey = key + "Sec";
      names[newKey] = fileName;
      cameraIcon2 = new Image.file(_imageFile2);
      _uploadTask2 = _storage.ref().child(model.picName).putFile(_imageFile);
    });
    await _uploadTask2.onComplete;
    print("Upload done on second");
    Toast.show("Upload Complete", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  //
  //

  //Gets device UDID for database upload
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
      data.udid = udid;
    });
  }

  //
  //

  Map<String, bool> numbers = {
    'Loading': true,
  };
  Map<String, String> subtitles = {'Loading': 'Busy Loading'};

  //Dynamically gets Checklist from NODE JS based on which Baustelle is selected.
  Future<void> fetchChecklist(var baustelle) async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    final response = await http
        .get("http://" + host + ":" + port + '/test/' + baustelle.toString());

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
      List<String> emptyIte = [];

      for (int i = 0; i < tags.length; i++) {
        print("Iterate");
        boolIte.add(true);
        emptyIte.add("");
      }
      var testing = Map.fromIterables(tags, boolIte);
      var subWorking = Map.fromIterables(tags, emptyIte);
      print(tags);
      print(numbers);
      setState(() {
        numbers = testing;
        subtitles = subWorking;
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  //
  //

  Future<void> getBaustelle() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    final response = await http.get("http://" + host + ":" + port + '/all/');

    if (response.statusCode == 200) {
      var bauApi = jsonDecode(response.body);
      List<String> bauSugg = bauApi != null ? List.from(bauApi) : null;
      print(bauApi[0]);
      suggestions = await bauSugg;
      textField.updateSuggestions(suggestions);
      print(suggestions);
    } else {
      throw Exception("Failed to get Baustelle");
    }
  }

  //
  //

  Future<void> uploadData(Data dataFinal) async {
    final firestoreInstance = Firestore.instance;

    firestoreInstance.collection("issues").add({
      "user": dataFinal.user,
      "baustelle": dataFinal.baustelle,
      "schicht": dataFinal.schicht,
      "udid": dataFinal.udid,
      "errors": dataFinal.errors,
      "comments": dataFinal.comments,
      "images": dataFinal.images,
      "checklist": dataFinal.index,
    }).then((value) => {
          print(value.documentID),
          Toast.show("All Data is uploaded", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.CENTER)
        });
  }

  //
  //

  var pullReport;

  Future<void> getReport(String baustelle, String date) async {
    final firestoreInstance = Firestore.instance;
    final startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse('2020-10-13 00:00:00.000').millisecondsSinceEpoch);
    final endAtTimeStamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse('2020-10-14 00:00:00.000').millisecondsSinceEpoch);
    firestoreInstance
        .collection("issues")
        .where("baustelle", isEqualTo: baustelle)
        .where("user", isEqualTo: "ad")
        .where("schicht", isGreaterThan: startAtTimestamp)
        .where("schicht", isLessThan: endAtTimeStamp)
        .orderBy("schicht")
        .limit(1)
        .getDocuments()
        .then((value) => {
              value.documents.forEach((element) {
                print(element.data);
                pullReport = element.data;

                var test = pullReport["errors"];
                var checklist = pullReport["checklist"];
                print("Checklist $checklist");
                print("Error test $test");
                setState(() {
                  numbers = Map<String, bool>.from(checklist);
                  errors = Map<String, String>.from(test);
                  (context as Element).reassemble();
                });

                print(errors["One"]);
              })
            });
  }

  //
  //

  Future<void> reportCheck(String baustelle) async {
    DateTime now = new DateTime.now();
    DateTime dateStart = new DateTime(now.year, now.month, now.day);
    DateTime dateEnd = new DateTime(now.year, now.month, now.day + 1);

    final firestoreInstance = Firestore.instance;
    final startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse('2020-10-07 00:00:00.000').millisecondsSinceEpoch);
    final endAtTimeStamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse('2020-10-08 00:00:00.000').millisecondsSinceEpoch);
    firestoreInstance
        .collection("issues")
        .where("baustelle", isEqualTo: "Zurich-9221")
        .where("user", isEqualTo: "ad")
        .where("schicht", isGreaterThan: startAtTimestamp)
        .where("schicht", isLessThan: endAtTimeStamp)
        .getDocuments()
        .then((value) => {
              if (value.documents.length > 0)
                {getReport(baustelle, "test")}
              else
                {fetchChecklist(baustelle)}
            });
  }

  //
  //

  _checkNumber() {
    print(numbers);
    print(errors);
    print(comments);
  }

  _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Loading User");
    print(prefs.getString('user') ?? "empty");
    setState(() {
      data.user = (prefs.getString('user') ?? "empty");
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('user', 'empty');
      prefs.setBool('loged', false);
    });
  }

  //
  //

  _intialDate() async {
    var date = DateTime.now();
    data.schicht = date;
    setState(() {
      String dayW = date.day.toString();
      String monthW = date.month.toString();
      String yearW = date.year.toString();
      String working = dayW + '/' + monthW + '/' + yearW;
      print(working);
      dateFinal = working;
    });
  }

  //
  //

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) bauController.clear();
    });
    getBaustelle();

    reportCheck("Zürich-9221");
    print(reportExist);

    getUDID();
    _loadUser();
    _intialDate();
    _checkNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report App"),
        actions: [
          FlatButton(
            padding: EdgeInsets.only(right: 75),
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
              style: TextStyle(color: Colors.white),
            ),
          ),
          new IconButton(
              icon: new Icon(Icons.check),
              onPressed: () {
                data.errors = Map<String, String>.from(errors);
                data.comments = Map<String, String>.from(comments);
                data.images = Map<String, String>.from(names);
                data.index = Map<String, bool>.from(numbers);
                data.user = "ad";
                if (data.user == null ||
                    data.udid == null ||
                    data.schicht == null) {
                  Toast.show("Form is not Complete", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                } else {
                  if (data.errors.isEmpty) {
                    //Possible error double upload
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Confirm"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('Everything has been marked okay'),
                                  Text('Is that correct?'),
                                ],
                              ),
                            ),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  uploadData(data);
                                  deleteCanceledFiles(toDelete);
                                  toDelete.clear();
                                  Navigator.of(context).pop();
                                },
                                child: Text("Yes"),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("No"),
                              )
                            ],
                          );
                        });
                  } else {
                    uploadData(data);
                    deleteCanceledFiles(toDelete);
                    toDelete.clear();
                  }
                }
              })
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Flexible(
                    child: textField = SimpleAutoCompleteTextField(
                        key: key,
                        controller: bauController,
                        focusNode: _focusNode,
                        suggestions: suggestions,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        textChanged: (text) => currentText = text,
                        clearOnSubmit: false,
                        textSubmitted: (text) => setState(() {
                              if (text != "") {
                                baustelle = text;
                                data.baustelle = text;
                                fetchChecklist(baustelle);
                              }
                            }))),
              ]),
          Expanded(
            //Creates the checklist dynamically based on API
            child: ListView(
              children: numbers.keys.map((String key) {
                return new CheckboxListTile(
                  title: new Text(key),
                  //subtitle: new Text(subtitles[key]),
                  value: numbers[key],
                  activeColor: Colors.pink,
                  checkColor: Colors.white,
                  onChanged: (bool value) {
                    setState(() {
                      //numbers[key] = value;
                      value = secondCheck;
                      print(errors[key]);
                      print(errors);
                      txt.text = errors[key];
                      if (numbers[key] == true) {
                        checkboxIcon = Icon(Icons.check_box);
                        txt.text = comments[key];
                      } else {
                        checkboxIcon = Icon(Icons.check_box_outline_blank);
                        print(errors[key]);
                        txt.text = errors[key];
                      }
                      exec = true;

                      //If Checkbox is false then a dialog will pop up so information can be filled in.
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: new Text(key),
                            insetPadding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            content: new Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    new Flexible(
                                      child: new TextField(
                                        controller: txt,
                                        minLines: 5,
                                        maxLines: 7,
                                        decoration: const InputDecoration(
                                          hintText: "Enter Problem",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    new SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: IconButton(
                                        padding: new EdgeInsets.all(10.0),
                                        icon: cameraIcon,
                                        onPressed: () =>
                                            (_pickImage(ImageSource.camera, key)
                                                .then(
                                          (value) =>
                                              (context as Element).reassemble(),
                                        )),
                                      ),
                                    ),
                                    new SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: IconButton(
                                        padding: new EdgeInsets.all(10.0),
                                        icon: cameraIcon2,
                                        onPressed: () => (_pickImageSec(
                                                ImageSource.camera, key)
                                            .then((value) =>
                                                (context as Element)
                                                    .reassemble())),
                                      ),
                                    )
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Text("Alles Okay "),
                                    new IconButton(
                                        icon: checkboxIcon,
                                        onPressed: () {
                                          if (numbers[key] == false) {
                                            setState(() {
                                              checkboxIcon =
                                                  Icon(Icons.check_box);
                                              secondCheck = true;
                                              value = true;
                                              numbers[key] = true;
                                              (context as Element).reassemble();
                                            });
                                          } else {
                                            setState(() {
                                              checkboxIcon = Icon(Icons
                                                  .check_box_outline_blank);
                                              secondCheck = false;
                                              value = false;
                                              numbers[key] = false;
                                              (context as Element).reassemble();
                                            });
                                          }
                                        }),
                                  ],
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              //TODO fix Delete function
                              new FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      errors.remove(key);
                                      if (names[key] != null) {
                                        toDelete.add(names[key]);
                                      }
                                      if (names[key + "Sec"] != null) {
                                        toDelete.add(names[key + "Sec"]);
                                      }
                                      names.remove(key);
                                      names.remove(key + "Sec");
                                      secondCheck = false;
                                      numbers[key] = true;
                                      txt.clear();
                                      Navigator.of(context).pop();
                                      (context as Element).reassemble();
                                    });
                                  },
                                  child: new Text("Löschen")),

                              new FlatButton(
                                child: new Text("Abbruch"),
                                onPressed: () {
                                  txt.clear();
                                  setState(() {
                                    value = numbers[key];
                                    (context as Element).reassemble();
                                  });

                                  cameraIcon =
                                      Image.asset("assets/cameraIcon.png");
                                  cameraIcon2 =
                                      Image.asset("assets/cameraIcon.png");
                                  Navigator.of(context).pop();
                                },
                              ),
                              new FlatButton(
                                onPressed: () {
                                  //errors.add(txt.text);
                                  print(txt.text);
                                  print(key);
                                  setState(() {
                                    //value = numbers[key];
                                    (context as Element).reassemble();
                                  });
                                  if (value == true) {
                                    comments[key] = txt.text;
                                    subtitles[key] = txt.text;
                                  } else {
                                    errors[key] = txt.text;
                                    subtitles[key] = txt.text;
                                  }

                                  txt.clear();
                                  cameraIcon =
                                      Image.asset("assets/cameraIcon.png");
                                  cameraIcon2 =
                                      Image.asset("assets/cameraIcon.png");
                                  Navigator.of(context).pop();
                                },
                                child: new Text("Speichern"),
                              )
                            ],
                          );
                        },
                      );
                    });
                  },
                  secondary: new Icon(Icons.edit),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => (LoginKey())),
          );
        },
        tooltip: 'Logout',
        child: Icon(Icons.exit_to_app),
      ),
    );
  }
}
