import 'dart:io';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:validators/validators.dart' as validator;
import 'package:firebase_storage/firebase_storage.dart';
import 'model.dart';
// ignore: unused_import
import 'result.dart';
import 'database.dart';
import 'package:flutter/widgets.dart';
// ignore: unused_import
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter/foundation.dart';

void main() => runApp(
      Phoenix(
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: TestForm(),
      ),
    );
  }
}

class TestForm extends StatefulWidget {
  @override
  _TestFormState createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  final _formKey = GlobalKey<FormState>();
  File _imageFile;
  String locWorking;
  Model model = Model();
  StorageUploadTask _uploadTask;

  Future<void> _getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position.toString());
    setState(() {
      model.location = position.toString();
    });
  }

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

  @override
  Widget build(BuildContext context) {
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
    model.checkBox = false;
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Demo"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    width: halfMediaWidth,
                    child: MyTextFormField(
                      hintText: 'Name',
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Enter your first name';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        model.firstName = value;
                      },
                    ),
                  ),
                  Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: RaisedButton(
                          color: Colors.blueAccent,
                          onPressed: () {
                            _getLocation();
                          },
                          child: Text("Get Location")))
                ],
              ),
            ),
            MyTextFormField(
              hintText: 'Description',
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Please Enter Description';
                }
                return null;
              },
              onSaved: (String value) {
                model.description = value;
              },
            ),
            StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                title: Text("Need urgent repair"),
                value: model.checkBox,
                onChanged: (bool newValue) {
                  setState(() {
                    model.checkBox = newValue;
                  });
                },
                controlAffinity:
                    ListTileControlAffinity.leading, //  <-- leading Checkbox
              ),
            ),
            RaisedButton(
              color: Colors.blueAccent,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  print(locWorking);
                  _formKey.currentState.save();
                  if (model.location == null) {
                    print("No location");

                    setState(() {
                      model.dataCheck = false;
                    });
                    print(model.dataCheck);
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: new Text("Error"),
                              content:
                                  new Text("No location has been picked up"),
                              actions: <Widget>[
                                new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: new Text("Close"))
                              ],
                            ));
                  } else {
                    print("All checks passed...");
                    setState(() {
                      model.dataCheck = true;
                    });

                    print(model.dataCheck);
                  }
                  if (model.picCheck == false || model.picCheck == null) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: new Text("Notice"),
                              content: new Text("No picture has been added..."),
                              actions: <Widget>[
                                new FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        model.picCheck = true;
                                        model.picName = "Null";
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: new Text("No Picture Needed")),
                                new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: new Text("Close"))
                              ],
                            ));
                  }
                }
              },
              child: Text(
                'Check Data',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            RaisedButton(
              onPressed: () {
                Phoenix.rebirth(context);
              },
              child: Text("Clear"),
            ),
            if (_imageFile != null) ...[
              Uploader(
                file: _imageFile,
                fileName: model.picName,
              ),
            ],
            if (model.dataCheck == true && model.picCheck == true) ...[
              DataAdder(model: this.model),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final Function validator;
  final Function onSaved;
  final bool isPassword;
  final bool isEmail;
  MyTextFormField({
    this.hintText,
    this.validator,
    this.onSaved,
    this.isPassword = false,
    this.isEmail = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        obscureText: isPassword ? true : false,
        validator: validator,
        onSaved: onSaved,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;
  final String fileName;

  Uploader({Key key, this.file, this.fileName}) : super(key: key);
  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://train-app-287911.appspot.com');

  StorageUploadTask _uploadTask;

  /// Starts an upload task
  void _startUpload() {
    /// Unique file name for the file

    setState(() {
      _uploadTask = _storage.ref().child(widget.fileName).putFile(widget.file);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      /// Manage the task state and event subscription with a StreamBuilder
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (_, snapshot) {
            var event = snapshot?.data?.snapshot;

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            return Column(
              children: [
                if (_uploadTask.isComplete) Text('Upload Complete...'),

                if (_uploadTask.isPaused)
                  FlatButton(
                    child: Icon(Icons.play_arrow),
                    onPressed: _uploadTask.resume,
                  ),

                if (_uploadTask.isInProgress)
                  FlatButton(
                    child: Icon(Icons.pause),
                    onPressed: _uploadTask.pause,
                  ),

                // Progress bar
                CircularProgressIndicator(value: progressPercent),
                Text('${(progressPercent * 100).toStringAsFixed(2)} % '),
              ],
            );
          });
    } else {
      // Allows user to decide when to start the upload
      return FlatButton.icon(
        label: Text('Upload Image'),
        icon: Icon(Icons.cloud_upload),
        onPressed: _startUpload,
      );
    }
  }
}
