import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Model {
  String firstName;
  String lastName;
  String email;
  String location;
  bool checkBox;
  String picName;
  Model(
      {this.firstName,
      this.lastName,
      this.email,
      this.location,
      this.checkBox,
      this.picName});
}
