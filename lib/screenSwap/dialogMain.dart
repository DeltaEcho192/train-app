import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart' as validator;
import 'package:firebase_storage/firebase_storage.dart';
import '../authToken.dart';
import '../model.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_udid/flutter_udid.dart';
import '../checkbox/data.dart';
import 'package:toast/toast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login/loginKey.dart';
import '../checkbox/location.dart';
import 'dialogScreen.dart';
import '../screenSwap/dialog.dart';
import '../bauData.dart';

class CheckboxWidget extends StatefulWidget {
  final BauData baudata;
  CheckboxWidget({Key key, @required this.baudata}) : super(key: key);
  @override
  CheckboxWidgetState createState() => new CheckboxWidgetState();
}

class CheckboxWidgetState extends State<CheckboxWidget> {
  bool exec = false;
  File _imageFile;
  File _imageFile2;
  String locWorking;
  Model model = Model();
  Data data = Data();
  Map<String, String> names = {};
  Map<String, String> errors = {};
  Map<String, String> comments = {};
  Map<String, String> audio = {};
  Map<String, int> priority = {};
  Map<String, int> status = {};
  Map<String, Map> statusText = {};
  Map<String, int> emptyStatus = {};
  Map<String, Map> workComEmpty = {};
  List<String> toDelete = [];
  String dateFinal = "Schicht:";
  String _udid = 'Unknown';
  int photoAmt = 0;
  int iteration = 0;
  Image cameraIcon = Image.asset("assets/cameraIcon.png");
  Image cameraIcon2 = Image.asset("assets/cameraIcon.png");
  Image logo = Image.asset(
    "assets/Vanoli-logo.png",
    width: 75,
  );
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
  String reportID;
  Uint8List imageBytes;
  String errorMsg;
  String finalDocID;
  Icon statusLeading = Icon(Icons.check);
  Icon statusEmpty = Icon(Icons.airline_seat_flat);
  var sortedKeys = ['Lade Daten...'];
  DialogData dialogData = DialogData();
  var referenceDate = DateTime.now();

  //

  _navigateAndDisplaySelection(BuildContext context, String keyVar) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DialogScreen(dialogdata: dialogData)),
    );

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    print(result.text);
    print(keyVar);
    setState(() {
      if (result.check == true) {
        comments[keyVar] = result.text;
        if (result.text.length > 30) {
          subtitles[keyVar] =
              result.text.replaceRange(30, result.text.length, "...");
        } else {
          subtitles[keyVar] = result.text;
        }

        if (errors.containsKey(keyVar)) {
          errors.remove(keyVar);
        }
      } else {
        errors[keyVar] = result.text;
        if (result.text.length > 30) {
          subtitles[keyVar] =
              result.text.replaceRange(30, result.text.length, "...");
        } else {
          subtitles[keyVar] = result.text;
        }
        if (comments.containsKey(keyVar)) {
          comments.remove(keyVar);
        }
      }
      numbers[keyVar] = result.check;
      names[keyVar] = result.image1;
      names[(keyVar + "Sec")] = result.image2;
      audio[keyVar] = result.audio;
      priority[keyVar] = result.priority;

      data.errors = Map<String, String>.from(errors);
      data.comments = Map<String, String>.from(comments);
      data.images = Map<String, String>.from(names);
      data.audio = Map<String, String>.from(audio);
      data.index = Map<String, bool>.from(numbers);
      data.priority = Map<String, int>.from(priority);
      data.status = Map<String, int>.from(emptyStatus);
      data.workCom = Map<String, Map>.from(workComEmpty);

      if (reportExist == true) {
        updateData(data);
      } else {
        uploadData(data);
      }
    });
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
    'Lade Daten...': true,
  };
  Map<String, String> subtitles = {'Lade Daten...': ' '};

  //Dynamically gets Checklist from NODE JS based on which Baustelle is selected.
  Future<void> fetchChecklist(var baustelle, var bauID) async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    var tokenAuth = await AuthToken().getAccessToken();
    var check = AuthToken().expiryCheck(tokenAuth);
    if (check == true) {
      await AuthToken().refreshToken();
      tokenAuth = await AuthToken().getAccessToken();
    }
    print(tokenAuth);
    final response = await http.get(
        "https://" + host + ":" + port + '/getChecklist/' + bauID.toString(),
        headers: {"Authorization": "Bearer " + tokenAuth});

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
        _sortList();
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('0004 - Failed to load Checklist');
    }
  }

  //
  //

  Future<void> getBaustelle() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    var tokenAuth = await AuthToken().getAccessToken();
    var check = AuthToken().expiryCheck(tokenAuth);
    if (check == true) {
      await AuthToken().refreshToken();
      tokenAuth = await AuthToken().getAccessToken();
    }
    print(tokenAuth);
    final response = await http.get("https://" + host + ":" + port + '/all/',
        headers: {"Authorization": "Bearer " + tokenAuth});

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
  Future<void> changeAlert(var docId) async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    var tokenAuth = await AuthToken().getAccessToken();
    var check = AuthToken().expiryCheck(tokenAuth);
    if (check == true) {
      await AuthToken().refreshToken();
      tokenAuth = await AuthToken().getAccessToken();
    }
    print(tokenAuth);
    final response = await http.get(
        "https://" + host + ":" + port + '/change/' + docId,
        headers: {"Authorization": "Bearer " + tokenAuth});
    if (response.statusCode == 200) {
      print("Success");
    } else {
      print("0005 - Failure");
    }
  }

  Future<void> uploadData(Data dataFinal) async {
    final firestoreInstance = Firestore.instance;
    var docId;

    firestoreInstance.collection("issues").add({
      "user": dataFinal.user,
      "baustelle": dataFinal.baustelle,
      "bauID": dataFinal.bauID,
      "schicht": dataFinal.schicht,
      "udid": dataFinal.udid,
      "errors": dataFinal.errors,
      "comments": dataFinal.comments,
      "images": dataFinal.images,
      "audio": dataFinal.audio,
      "priority": dataFinal.priority,
      "checklist": dataFinal.index,
      "status": dataFinal.status,
      "workCom": dataFinal.workCom,
    }).then((value) => {
          docId = value.documentID,
          finalDocID = docId,
          reportID = docId,
          reportExist = true,
          Toast.show("Report ist auf Server gespeichert", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM),
        });
  }

  Future<void> uploadEmptyData(Data dataFinal) async {
    final firestoreInstance = Firestore.instance;
    var docId;

    firestoreInstance.collection("issues").add({
      "user": dataFinal.user,
      "baustelle": dataFinal.baustelle,
      "bauID": dataFinal.bauID,
      "schicht": dataFinal.schicht,
      "udid": dataFinal.udid,
      "errors": dataFinal.errors,
      "comments": dataFinal.comments,
      "images": dataFinal.images,
      "audio": dataFinal.audio,
      "priority": dataFinal.priority,
      "checklist": dataFinal.index,
      "status": dataFinal.status,
      "workCom": dataFinal.workCom,
    }).then((value) => {
          docId = value.documentID,
          finalDocID = docId,
          reportID = docId,
          changeAlert(reportID),
          reportExist = true,
          Toast.show("Report ist auf Server gespeichert", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM),
        });
  }
  //
  //

  Future<void> updateData(Data dataFinal) async {
    final firestoreInstance = Firestore.instance;
    firestoreInstance.collection("issues").document(reportID).updateData({
      "errors": dataFinal.errors,
      "comments": dataFinal.comments,
      "checklist": dataFinal.index,
      "images": dataFinal.images,
      "audio": dataFinal.audio,
      "priority": dataFinal.priority,
    }).then((value) => {
          print("Successfully updated data"),
          Toast.show("Die Reportänderungen sind gespeichert", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM),
        });
  }

  subtitleCut(key) {
    var subtitleWorking;
    if (subtitles[key].length != 0) {
      setState(() {
        subtitleWorking =
            subtitles[key].replaceRange(10, subtitles[key].length, "...");
      });
    } else {
      setState(() {
        subtitleWorking = " ";
      });
    }
    return subtitleWorking;
  }

  //
  //

  var pullReport;

  Future<void> getReport(String baustelle, DateTime start, DateTime end) async {
    final firestoreInstance = Firestore.instance;
    final startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse(start.toString()).millisecondsSinceEpoch);
    final endAtTimeStamp = Timestamp.fromMillisecondsSinceEpoch(
        DateTime.parse(end.toString()).millisecondsSinceEpoch);
    firestoreInstance
        .collection("issues")
        .where("bauID", isEqualTo: baustelle)
        .where("user", isEqualTo: data.user)
        .where("schicht", isGreaterThanOrEqualTo: startAtTimestamp)
        .where("schicht", isLessThan: endAtTimeStamp)
        .orderBy("schicht")
        .limit(1)
        .getDocuments()
        .then((value) => {
              value.documents.forEach((element) {
                print(element.documentID);
                reportID = element.documentID;
                pullReport = element.data;

                var errorsLoc = pullReport["errors"];
                var commentsLoc = pullReport["comments"];
                var checklist = pullReport["checklist"];
                var imagesLoc = pullReport["images"];
                var audioLoc = pullReport["audio"];
                var priorityLoc = pullReport["priority"];
                var statusLoc = pullReport["status"];
                var statusTextLoc = pullReport["workCom"];
                print("Checklist $checklist");
                print("image test $imagesLoc");
                setState(() {
                  subtitles.clear();
                  numbers = Map<String, bool>.from(checklist);
                  comments = Map<String, String>.from(commentsLoc);
                  errors = Map<String, String>.from(errorsLoc);
                  audio = Map<String, String>.from(audioLoc);
                  priority = Map<String, int>.from(priorityLoc);
                  status = Map<String, int>.from(statusLoc);
                  statusText = Map<String, Map>.from(statusTextLoc);
                  subtitles = {...errors, ...comments};
                  print(subtitles);
                  numbers.forEach((key, value) {
                    if (subtitles.containsKey(key)) {
                      print("In array");
                      print(subtitles[key]);
                      var subWork = subtitles[key];
                      print(subWork);
                      if (subWork == null) {
                        subtitles[key] = " ";
                      } else {
                        if (subWork.length > 30) {
                          subtitles[key] =
                              subWork.replaceRange(30, subWork.length, "...");
                        } else {
                          subtitles[key] = subWork;
                        }
                      }
                    } else {
                      subtitles[key] = " ";
                    }
                  });
                  print("Subtitiles $subtitles");
                  names = Map<String, String>.from(imagesLoc);
                  _sortList();
                  (context as Element).reassemble();
                });
              })
            });
  }

  //
  //

  Future<void> reportCheck(
      bool dateCheck, String newStart, String newEnd) async {
    final firestoreInstance = Firestore.instance;
    var startAtTimestamp;
    var endAtTimeStamp;
    DateTime dateEnd;
    DateTime dateStart;

    numbers = {
      'Lade Daten...': true,
    };
    sortedKeys = ['Lade Daten...'];
    subtitles = {'Lade Daten...': ' '};

    DateTime now = new DateTime.now();

    if (dateCheck == true) {
      startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.parse(newStart).millisecondsSinceEpoch);
      endAtTimeStamp = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.parse(newEnd).millisecondsSinceEpoch);

      dateStart = DateTime.parse(newStart);
      setState(() {
        referenceDate = dateStart;
        String dayW = referenceDate.day.toString();
        String monthW = referenceDate.month.toString();
        String yearW = referenceDate.year.toString();
        String working = dayW + '/' + monthW + '/' + yearW;
        print(working);
        dateFinal = working;
      });

      dateEnd = DateTime.parse(newEnd);
    } else {
      _intialDate();
      dateStart = new DateTime(now.year, now.month, now.day);
      dateEnd = new DateTime(now.year, now.month, now.day + 1);

      startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.parse(dateStart.toString()).millisecondsSinceEpoch);
      endAtTimeStamp = Timestamp.fromMillisecondsSinceEpoch(
          DateTime.parse(dateEnd.toString()).millisecondsSinceEpoch);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var baustelle = widget.baudata.bauName;
    var bauID = widget.baudata.bauID;
    data.baustelle = baustelle;
    data.bauID = bauID;
    bauController.text = baustelle;
    var userid = prefs.getString('user');
    data.user = userid;

    firestoreInstance
        .collection("issues")
        .where("bauID", isEqualTo: bauID)
        .where("user", isEqualTo: userid)
        .where("schicht", isGreaterThan: startAtTimestamp)
        .where("schicht", isLessThan: endAtTimeStamp)
        .getDocuments()
        .then((value) => {
              if (value.documents.length > 0)
                {reportExist = true, getReport(bauID, dateStart, dateEnd)}
              else
                {reportExist = false, fetchChecklist(baustelle, bauID)}
            });
  }

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
            }))
        .catchError((e) => setState(() {
              errorMsg = e.error;
            }));
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

  _sortList() async {
    setState(() {
      sortedKeys = numbers.keys.toList();
      sortedKeys.sort((a, b) => (a).compareTo(b));
    });
  }

  //
  //

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        bauController.clear();
      } else {
        bauController.text = data.baustelle;
      }
    });
    //getBaustelle();
    //Parse Info from WIP baustelle screen
    _loadUser();
    reportCheck(
        widget.baudata.check, widget.baudata.beginDate, widget.baudata.endDate);
    getUDID();

    _sortList();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(232, 195, 30, 1),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => (Location())),
              );
            }),
        title: logo,
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
                data.schicht = date.add(new Duration(hours: 12));
                print(data.schicht);
                var hour = 0;
                var min = 0;
                var seconds = 0;
                var milli = 0;
                setState(() {
                  String dayW = date.day.toString();
                  String monthW = date.month.toString();
                  String yearW = date.year.toString();
                  String working = dayW + '/' + monthW + '/' + yearW;
                  var reportWorking = date.toLocal();
                  String reportStart = DateTime(
                          reportWorking.year,
                          reportWorking.month,
                          reportWorking.day,
                          hour,
                          min,
                          seconds,
                          milli)
                      .toString();
                  print(reportStart);
                  String reportEnd = DateTime(
                          reportWorking.year,
                          reportWorking.month,
                          reportWorking.day + 1,
                          hour,
                          min,
                          seconds,
                          milli)
                      .toString();
                  print(reportEnd);
                  print(working);
                  dateFinal = working;
                  errors.clear();
                  comments.clear();
                  names.clear();
                  audio.clear();
                  numbers.clear();
                  priority.clear();
                  statusText.clear();
                  status.clear();
                  reportCheck(true, reportStart, reportEnd);
                });
              }, currentTime: referenceDate, locale: LocaleType.de);
            },
            child: Text(
              dateFinal,
              style: TextStyle(color: Colors.white),
            ),
          ),
          new IconButton(
              icon: new Icon(
                Icons.notifications_active,
                color: Colors.red[800],
              ),
              onPressed: () {
                if (data.user == null ||
                    data.udid == null ||
                    data.schicht == null) {
                  Toast.show("Es sind nicht alle Eingaben korrekt", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                } else {
                  data.errors = Map<String, String>.from(errors);
                  if (data.errors.isEmpty) {
                    //Possible error double upload
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text("Bitte bestätigen"),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text('Es wurden keine Änderungen gemacht!'),
                                  Text('Ist das wirklich korrekt?'),
                                ],
                              ),
                            ),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  data.errors =
                                      Map<String, String>.from(errors);
                                  data.comments =
                                      Map<String, String>.from(comments);
                                  data.images = Map<String, String>.from(names);
                                  data.audio = Map<String, String>.from(audio);
                                  data.index = Map<String, bool>.from(numbers);
                                  data.status =
                                      Map<String, int>.from(emptyStatus);
                                  data.workCom =
                                      Map<String, Map>.from(workComEmpty);
                                  data.priority =
                                      Map<String, int>.from(priority);
                                  uploadEmptyData(data);
                                  deleteCanceledFiles(toDelete);
                                  toDelete.clear();
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => (Location())),
                                  );
                                },
                                child: Text("Ja"),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Nein"),
                              )
                            ],
                          );
                        });
                  } else {
                    if (reportExist == true) {
                      changeAlert(reportID);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => (Location())),
                      );
                    } else {
                      changeAlert(finalDocID);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => (Location())),
                      );
                    }

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
                                //fetchChecklist(baustelle, bauID);
                              }
                            }))),
              ]),
          Expanded(
            //Creates the checklist dynamically based on API
            child: ListView(
              children: sortedKeys.map((String key) {
                var statusColor = Colors.black;
                //var statusIcon;
                if (status[key] == 1) {
                  statusColor = Colors.green;
                  //statusIcon = statusLeading;
                } else {
                  //statusIcon = Text("");
                }
                return new CheckboxListTile(
                  title: new Text(
                    key,
                    style: TextStyle(
                      color: statusColor,
                    ),
                  ),
                  subtitle: new Text(
                    subtitles[key],
                    style: TextStyle(
                      color: statusColor,
                    ),
                    maxLines: 1,
                  ),
                  //secondary: statusIcon,
                  value: numbers[key],
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  onChanged: (bool value) {
                    setState(() {
                      value = secondCheck;
                      print(errors[key]);
                      print(errors);
                      if (numbers[key] == true) {
                        dialogData.text = comments[key];
                      } else {
                        dialogData.text = errors[key];
                      }
                      exec = true;
                      print(numbers[key]);
                      dialogData.name = key;
                      dialogData.check = numbers[key];
                      dialogData.image1 = names[key];
                      dialogData.image2 = names[(key + "Sec")];
                      dialogData.audio = audio[key];
                      dialogData.priority = priority[key];
                      if (statusText.isNotEmpty) {
                        if (statusText[key] != null) {
                          var check = statusText[key]['text'];
                          var statusInv = statusText[key]['text'];
                          var statusUser = statusText[key]['user'];
                          var statusTime = statusText[key]['time'];
                          if (check.length == 0) {
                            statusInv = " ";
                          }
                          dialogData.statusText = statusInv;
                          dialogData.statusUser = statusUser;
                          dialogData.statusTime =
                              DateTime.fromMillisecondsSinceEpoch(statusTime);
                        } else {
                          dialogData.statusText = "";
                          dialogData.statusUser = "";
                          dialogData.statusTime =
                              DateTime.fromMillisecondsSinceEpoch(1608120399);
                        }
                      } else {
                        var statusInv = "";
                        dialogData.statusText = statusInv;
                      }

                      _navigateAndDisplaySelection(context, key);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
