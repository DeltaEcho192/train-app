import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'success.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<Map<String, dynamic>> fetchUser(var userid) async {
  final response =
      await http.get('http://192.168.202.107:3000/check/' + userid.toString());

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //print(json.decode(response.body));

    Map<String, dynamic> logIn = jsonDecode(response.body);
    return logIn;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class UserStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user.txt');
  }

  Future<String> readUser() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return 'error';
    }
  }

  Future<File> writeUser(String userid) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$userid');
  }
}

void main() => runApp(
      MaterialApp(
          title: "Login In testing", home: MyApp(storage: UserStorage())),
    );

class MyApp extends StatefulWidget {
  final UserStorage storage;
  MyApp({Key key, @required this.storage}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map<String, dynamic>> logStatus;
  String _user;

  @override
  void initState() {
    super.initState();
    widget.storage.readUser().then((value) => {
          print(value),
          setState(() {
            _user = value;
          })
        });
    logStatus = fetchUser('ad');
  }

  Future<File> _writeUser(String userid) {
    setState(() {
      _user = userid;
    });

    return widget.storage.writeUser(userid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              child: RaisedButton(
                onPressed: () {
                  fetchUser('ad').then((value) => {
                        print(value['userid']),
                        if (value['status'] == true)
                          {
                            print("Login was successful"),
                            _writeUser(value['userid']),
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HelloWorld()),
                            )
                          }
                        else
                          {print("Login was unsuccessful")}
                      });
                },
                child: new Text("Execute"),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: RaisedButton(
                onPressed: () {
                  widget.storage.readUser().then((value) => {
                        print(value),
                      });
                },
                child: new Text("Read"),
              ),
            ),
          ],
        ));
  }
}
