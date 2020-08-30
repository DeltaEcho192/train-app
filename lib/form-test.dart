import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart' as validator;
import 'package:firebase_storage/firebase_storage.dart';
import 'model.dart';
import 'result.dart';
import 'database.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Form Demo'),
        ),
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

    setState(() {
      _imageFile = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
    model.checkBox = false;
    return Scaffold(
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
              onSaved: (String value) {
                model.email = value;
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
                  print(model.checkBox.toString() +
                      model.email +
                      model.firstName +
                      model.picName +
                      model.location);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DataAdder(model: this.model)));
                }
              },
              child: Text(
                'Upload_all',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            RaisedButton(
              color: Colors.blueAccent,
              onPressed: () {
                String fileName = 'images/${DateTime.now()}.png';
                model.picName = fileName;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Uploader(
                              file: _imageFile,
                              fileName: fileName,
                            )));
              },
              child: Text(
                'Upload_photo',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
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

            return Scaffold(
              body: Container(
                child: Center(
                    child: Column(
                  children: [
                    // TODO Change so that it brings back the main page
                    if (_uploadTask.isComplete) Text('🎉🎉🎉'),

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
                    LinearProgressIndicator(value: progressPercent),
                    Text('${(progressPercent * 100).toStringAsFixed(2)} % '),
                  ],
                )),
              ),
            );
          });
    } else {
      // Allows user to decide when to start the upload
      return Scaffold(
          body: Container(
              child: Center(
        child: FlatButton.icon(
          label: Text('Upload to Image'),
          icon: Icon(Icons.cloud_upload),
          onPressed: _startUpload,
        ),
      )));
    }
  }
}
