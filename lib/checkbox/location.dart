import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:train_app/login/loginKey.dart';
import '../screenSwap/dialogMain.dart';
import '../PushNotificationManager.dart';
import '../bauData.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Location(title: 'Baustelle Select'),
    );
  }
}

class Location extends StatefulWidget {
  Location({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LocationState createState() => new _LocationState();
}

class _LocationState extends State<Location> {
  PushNotificationsManager notificationInit = new PushNotificationsManager();
  TextEditingController editingController = TextEditingController();
  List<String> mainDataList = [];
  List<String> newDataList = [];
  BauData bauData = BauData();
  var usr = "";

  List<String> bauSugg = ["Default"];
  var bauIDS = {};
  Future<void> getBaustelle() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    final response =
        await http.get("https://" + host + ":" + port + '/all/' + usr);

    if (response.statusCode == 200) {
      Map<String, dynamic> bauApi = jsonDecode(response.body);
      print(bauApi['names']);
      var bauApiList = bauApi['names'];
      bauSugg = await bauApi != null ? List.from(bauApi['names']) : null;
      bauIDS = bauApi['id'];
      mainDataList.clear();
      newDataList.clear();
      setState(() {
        mainDataList.addAll(bauSugg);
        newDataList.addAll(bauSugg);
      });

      print(bauApi['names'][0]);
    } else {
      throw Exception("0003 - Failed to get Baustelle");
    }
  }

  _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("Loading User");
    print(prefs.getString('user') ?? "empty");
    setState(() {
      usr = (prefs.getString('user') ?? "empty");
      getBaustelle();
    });
  }

  _writeBaustelle(String baustelle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('baustellePref', baustelle);
      prefs.setString('bauID', bauIDS[baustelle]);
    });
  }

  @override
  void initState() {
    _loadUser();
    _tokenInit();
    super.initState();
  }

  onItemChanged(String value) {
    setState(() {
      newDataList = mainDataList
          .where((string) => string.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('user', 'empty');
      prefs.setBool('loged', false);
    });
  }

  Future<void> _tokenInit() async {
    var token = await notificationInit.init();
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("token", token);
      print(token);
    } else {
      print("There has been a issue gettting notification token");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      token = prefs.getString("token");
      print(token);
    }
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    var urlLocal = "https://" + host + ":" + port + '/updateToken/';
    print(urlLocal);
    print(jsonEncode({"userid": usr, "token": token}));
    if (token == "null") {
      print("Token can not be null");
    } else {
      final check = await http.post(urlLocal,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"userid": usr, "token": token}));

      if (check.statusCode == 201) {
        print("User token updated");
      } else {
        throw Exception('Failed to update user token');
      }
    }
  }

  Future<void> _tokenLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = (prefs.getString("token") ?? "null");
    if (token != "null") {
      print(token);
      await GlobalConfiguration().loadFromAsset("app_settings");
      var host = GlobalConfiguration().getValue("host");
      var port = GlobalConfiguration().getValue("port");
      var urlLocal = "https://" + host + ":" + port + '/tokenLogout/';
      print(urlLocal);
      print(jsonEncode({"userid": usr, "token": token}));
      if (token == null) {
        print("Token can not be null");
      } else {
        final check = await http.post(urlLocal,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({"userid": usr, "token": token}));

        if (check.statusCode == 201) {
          print("User token Logged out");
        } else {
          throw Exception('Failed to logout user token');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          titleSpacing: 0.0,
          title: new Text(
            "Baustelle auswählen:",
          ),
          backgroundColor: Color.fromRGBO(232, 195, 30, 1),
          actions: [
            IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  getBaustelle();
                })
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: onItemChanged,
                  controller: editingController,
                  decoration: InputDecoration(
                      labelText: "Baustellensuche",
                      hintText: "Baustellensuche",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(12.0),
                  children: newDataList.map((data) {
                    return ListTile(
                      title: Text(data),
                      onTap: () {
                        var baustelle = data;
                        _writeBaustelle(baustelle);
                        bauData.bauName = baustelle;
                        bauData.bauID = bauIDS[baustelle];
                        bauData.check = false;
                        bauData.beginDate = null;
                        bauData.endDate = null;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => (CheckboxWidget(
                                      baudata: bauData,
                                    ))));
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(232, 195, 30, 1),
          onPressed: () {
            _tokenLogout();
            _logout();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => (LoginKey())));
          },
          child: Icon(Icons.exit_to_app),
        ));
  }
}
