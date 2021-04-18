import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../checkbox/location.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'dart:convert';
import '../navKey.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final navigatorKey = SfcKeys.navKey;
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginKey(),
    );
  }
}

Future<Map<String, dynamic>> fetchUser(
    var userid, var pswd, String udid) async {
  await GlobalConfiguration().loadFromAsset("app_settings");
  var host = GlobalConfiguration().getValue("host");
  var port = GlobalConfiguration().getValue("authPort");
  print("Function UDID " + udid);
  var urlLocal = "https://" + host + ":" + port + '/login/';
  print(urlLocal);
  final response = await http.post(urlLocal,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"userId": userid, "pswd": pswd, "web": false}));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //print(json.decode(response.body));
    print("Succesful request");
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
  String titleVar = "Anmeldung: ()";
  final myController = TextEditingController();
  final pswdController = TextEditingController();
  Image loginIcon = Image.asset("assets/2x/engIcon.png");

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
    getVersion();
    getUDID();
    _loadUser();
    checkLogin();
  }

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    titleVar = "Anmeldung: (" + version + ")";
  }

  void checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool usercheck = (prefs.getBool('loged') ?? false);

    if (usercheck == true) {
      Navigator.pushReplacement(
          context, new MaterialPageRoute(builder: (context) => Location()));
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

  _writeAccessToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('accessToken', accessToken);
    });
  }

  _writeRefreshToken(String refreshToken) async {
    final storage = new FlutterSecureStorage();
    await storage.write(key: "refreshToken", value: refreshToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleVar),
        backgroundColor: Color.fromRGBO(232, 195, 30, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 73,
                  ),
                  child: TextField(
                    controller: myController,
                    decoration: InputDecoration(
                      hintText: 'Bitte Benutzer ID eingeben',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                )),
              ],
            ),
            new Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 25,
                      top: 5,
                      right: 25,
                    ),
                    child: TextField(
                      controller: pswdController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Bitte Passwort eingeben',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: loginIcon,
                    onPressed: () {
                      String newUser = myController.text.toLowerCase();
                      String pswd = pswdController.text;
                      print("User Input " + newUser);
                      print("Password is" + pswd);
                      print("UDID" + _udid);
                      getUDID();
                      fetchUser(newUser, pswd, _udid).then((value) => {
                            print("Server User" + value['userid']),
                            print("Server Check" + value['status'].toString()),
                            if (value['status'] == true)
                              {
                                _writeAccessToken(value["accessToken"]),
                                _writeRefreshToken(value["refreshToken"]),
                                _setLogState(true),
                                _writeUser(value['userid']),
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => (Location())),
                                ),
                              }
                            else
                              {
                                print("0002 - Login failed"),
                                Toast.show(
                                    "Anmeldung nicht erfolgreich", context,
                                    duration: Toast.LENGTH_LONG,
                                    gravity: Toast.BOTTOM),
                                _setLogState(false)
                              }
                          });
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
