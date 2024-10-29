import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:talknest/helper/baseviewmodel/baseviewmodel.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class ContactProvider extends BaseViewModel {
  final FirebaseApi _services = FirebaseApi();
  TextEditingController searchController = TextEditingController();

  ContactProvider() {
    _init();
  }

  _init() async {
    await getAllusers();
  }

  bool _isSearching = false;
  String _searchText = '';

  bool get isSearching => _isSearching;
  String get searchText => _searchText;

  List<AppUser> userList = [];
  List<AppUser> filteredUserList = [];

  void toggleSearch() {
    _isSearching = !_isSearching;
    notifyListeners();
  }

  void updateSearchText(String newText) {
    _searchText = newText;

    if (_searchText.isEmpty) {
      filteredUserList = userList;
    } else {
      filteredUserList = userList
          .where((user) =>
              user.name.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  Future<void> getAllusers() async {
    setstate(ViewState.loading);
    try {
      userList = await _services.getAllUser() ?? [];
      filteredUserList = userList;
      setstate(ViewState.success);
    } catch (e) {
      setstate(ViewState.fail);
      log("Error fetching user data: $e");
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
