import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './successKey.dart';
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
  print("Function UDID " + udid);
  final response = await http.get(
      'http://192.168.202.107:3000/check/' + userid.toString() + "/" + udid);

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
      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => SuccessKey()));
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
              'This is your Current logged in User',
            ),
            TextField(
              controller: myController,
            ),
            Text(
              '$_user',
              style: Theme.of(context).textTheme.headline4,
            ),
            RaisedButton(
              onPressed: () {
                _logout();
              },
              child: Text("Logout"),
            ),
            RaisedButton(
              onPressed: () {
                _loadUser();

                print(_user.compareTo('empty'));
                int check = _user.compareTo('empty');
                print(check);
                if (check == -1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => (SuccessKey())),
                  );
                }
              },
              child: Text("Load User"),
            )
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
                      MaterialPageRoute(builder: (context) => (SuccessKey())),
                    ),
                  }
                else
                  {print("Login failed"), _setLogState(false)}
              });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
