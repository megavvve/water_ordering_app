import 'dart:io';
import 'package:flutter/material.dart';

class FormChangeNotifier extends ChangeNotifier {
  String _regCert = '';
  String _license = '';
  String _capacity = '';
  String _waterType = '';
  File? _carPhoto;
  File? _sorPhoto;
  File? _licensePhoto;

  String get regCert => _regCert;
  String get license => _license;
  String get capacity => _capacity;
  String get getWaterType => _waterType;
  File? get carPhoto => _carPhoto;
  File? get sorPhoto => _sorPhoto;
  File? get licensePhoto => _licensePhoto;

  set regCert(String value) {
    _regCert = value;
    notifyListeners();
  }

  set watertype(String value) {
    _waterType = value;
    notifyListeners();
  }

  set license(String value) {
    _license = value;
    notifyListeners();
  }

  set capacity(String value) {
    _capacity = value;
    notifyListeners();
  }

  set carPhoto(File? value) {
    _carPhoto = value;
    notifyListeners();
  }

  set sorPhoto(File? value) {
    _sorPhoto = value;
    notifyListeners();
  }

  set licensePhoto(File? value) {
    _licensePhoto = value;
    notifyListeners();
  }
}
