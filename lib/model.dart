import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Model {
  String firstName;
  bool dataCheck;
  String email;
  String location;
  bool checkBox;
  String picName;
  bool picCheck;
  Model(
      {this.firstName,
      this.dataCheck,
      this.email,
      this.location,
      this.checkBox,
      this.picName,
      this.picCheck});
}
