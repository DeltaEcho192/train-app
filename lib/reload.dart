import 'package:flutter/cupertino.dart';
import 'main.dart';

class Reload extends StatefulWidget {
  createState() => _ReloadState();
}

class _ReloadState() extends State<Reload> {
  void rebuilder() {
    setState(() {
      TestForm();});
  }
}