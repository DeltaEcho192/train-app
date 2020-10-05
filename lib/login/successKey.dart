import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './loginKey.dart';

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
      home: SuccessKey(),
    );
  }
}

class SuccessKey extends StatefulWidget {
  SuccessKey({Key key}) : super(key: key);

  @override
  _SuccessKeyState createState() => _SuccessKeyState();
}

class _SuccessKeyState extends State<SuccessKey> {
  String _user = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  //Loading counter value on start
  _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Loading User");
    print(prefs.getString('user') ?? "empty");
    setState(() {
      _user = (prefs.getString('user') ?? "empty");
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('user', null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Success"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This is your Current logged in User',
            ),
            Text('$_user'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _logout();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => (LoginKey())),
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
