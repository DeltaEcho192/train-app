import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import './successKey.dart';
import '../checkbox/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared preferences demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginKey(),
    );
  }
}

Future<Map<String, dynamic>> fetchUser(var userid, String udid) async {
  await GlobalConfiguration().loadFromAsset("app_settings");
  var host = GlobalConfiguration().getValue("host");
  var port = GlobalConfiguration().getValue("port");
  print("Function UDID " + udid);
  final response = await http.get("http://" +
      host +
      ":" +
      port +
      '/check/' +
      userid.toString() +
      "/" +
      udid);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //print(json.decode(response.body));

    Map<String, dynamic> logIn = jsonDecode(response.body);
    return logIn;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load user');
  }
}

class LoginKey extends StatefulWidget {
  LoginKey({Key key}) : super(key: key);

  @override
  _LoginKeyState createState() => _LoginKeyState();
}

class _LoginKeyState extends State<LoginKey> {
  String _user = "";
  String _udid = "";
  final myController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    getUDID();
    _loadUser();
    checkLogin();
  }

  void checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool usercheck = (prefs.getBool('loged') ?? false);

    if (usercheck == true) {
      Navigator.pushReplacement(context,
          new MaterialPageRoute(builder: (context) => CheckboxWidget()));
    }
  }

  //Loading counter value on start
  _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('user') ?? "empty");
    setState(() {
      _user = (prefs.getString('user') ?? "empty");
    });
  }

  //Incrementing counter after click
  _writeUser(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('user', userId);
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('user', null);
    });
  }

  _setLogState(bool logState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('loged', logState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shared Preference Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Please Enter your user key.',
            ),
            TextField(
              controller: myController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String newUser = myController.text;
          print("User Input " + newUser);
          print("UDID" + _udid);
          getUDID();
          fetchUser(newUser, _udid).then((value) => {
                print("Server User" + value['userid']),
                print("Server Check" + value['status'].toString()),
                if (value['status'] == true)
                  {
                    _setLogState(true),
                    _writeUser(value['userid']),
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => (CheckboxWidget())),
                    ),
                  }
                else
                  {
                    print("Login failed"),
                    Toast.show("Login Unsuccessful", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER),
                    _setLogState(false)
                  }
              });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
