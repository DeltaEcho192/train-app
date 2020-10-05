import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './successKey.dart';

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

class LoginKey extends StatefulWidget {
  LoginKey({Key key}) : super(key: key);

  @override
  _LoginKeyState createState() => _LoginKeyState();
}

class _LoginKeyState extends State<LoginKey> {
  String _user = "";
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
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
                if (_user != 'empty') {
                  Navigator.push(
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
          _writeUser(newUser);
          _loadUser();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
