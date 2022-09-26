import 'package:flutter/material.dart';
import '../models/user.dart';
import '../methods/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  User? _allUser;
  final AuthMethods _authMethods = AuthMethods();

  User? get getUser => _user;
  User? get getAllUser => _allUser;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

  Future<void> refreshAllUser(String uid) async {
    User alluser = await _authMethods.getAllUserDetails(uid);
    _allUser = alluser;
    notifyListeners();
  }

  Future<void> logoutUser() async {
    _user = null;
    notifyListeners();
  }
}
