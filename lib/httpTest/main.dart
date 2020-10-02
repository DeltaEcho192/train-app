import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<String>> fetchAlbum() async {
  final response =
      await http.get('http://192.168.202.107:3000/test/Zurich-9221');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    //print(json.decode(response.body));
    String arrayText = '{"tags": ["dart", "flutter", "json"]}';

    var tagsJson = jsonDecode(response.body);
    List<String> tags = tagsJson != null ? List.from(tagsJson) : null;

    print(tags);
    return tags;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<String>> futureList;

  @override
  void initState() {
    super.initState();
    futureList = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<String>>(
            future: futureList,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data[0]);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
