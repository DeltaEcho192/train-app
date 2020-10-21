import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:train_app/login/loginKey.dart';
import '../screenSwap/dialogMain.dart';

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
  TextEditingController editingController = TextEditingController();
  List<String> mainDataList = [];
  List<String> newDataList = [];

  List<String> bauSugg = ["Default"];
  Future<void> getBaustelle() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    final response = await http.get("http://" + host + ":" + port + '/all/');

    if (response.statusCode == 200) {
      var bauApi = jsonDecode(response.body);
      bauSugg = await bauApi != null ? List.from(bauApi) : null;
      mainDataList.clear();
      newDataList.clear();
      setState(() {
        mainDataList.addAll(bauSugg);
        newDataList.addAll(bauSugg);
      });

      print(bauApi[0]);
    } else {
      throw Exception("Failed to get Baustelle");
    }
  }

  _writeBaustelle(String baustelle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('baustellePref', baustelle);
    });
  }

  @override
  void initState() {
    getBaustelle();
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Baustelle Select"),
          backgroundColor: Colors.yellow[700],
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
                      labelText: "Search",
                      hintText: "Search",
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
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => (CheckboxWidget())));
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellow[700],
          onPressed: () {
            _logout();
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => (LoginKey())));
          },
          child: Icon(Icons.exit_to_app),
        ));
  }
}
