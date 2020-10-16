import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  var items = List<String>();
  var duplicateItems = List<String>();
  List<String> bauSugg = ["Default"];
  Future<void> getBaustelle() async {
    await GlobalConfiguration().loadFromAsset("app_settings");
    var host = GlobalConfiguration().getValue("host");
    var port = GlobalConfiguration().getValue("port");
    final response = await http.get("http://" + host + ":" + port + '/all/');

    if (response.statusCode == 200) {
      var bauApi = jsonDecode(response.body);
      bauSugg = await bauApi != null ? List.from(bauApi) : null;
      setState(() {
        items.addAll(bauSugg);
        duplicateItems.addAll(bauSugg);
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

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Baustelle Select"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${items[index]}'),
                    onTap: () {
                      print("${items[index]}");
                      var baustelle = items[index];
                      _writeBaustelle(baustelle);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => (CheckboxWidget())));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
