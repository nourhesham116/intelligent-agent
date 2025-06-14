import 'package:flutter/foundation.dart';

class DataProvider with ChangeNotifier {
  String _email = "";
  String _id = "";
  String _name = "";
  bool _admin = false;

  String get Email => _email;
  String get ID => _id;
  String get Name => _name;
  bool get Admin => _admin;

  void setEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  void setID(String newID) {
    _id = newID;
    notifyListeners();
  }

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void setAdmin(bool newAdmin) {
    _admin = newAdmin;
    notifyListeners();
  }

  void logout() {
    _email = "";
    _id = "";
    _name = "";
    _admin = false;
    notifyListeners();
  }
}
