import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:talknest/helper/baseviewmodel/baseviewmodel.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class ContactProvider extends BaseViewModel {
  final FirebaseApi _services = FirebaseApi();
  TextEditingController searchController = TextEditingController();
  List<AppUser> selectedUsers = [];

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

  void toggleUserSelection(AppUser user) {
    if (selectedUsers.contains(user)) {
      selectedUsers.remove(user);
    } else {
      selectedUsers.add(user);
    }
    notifyListeners();
  }

  Future<bool> createGroup({
    required String groupName,
    String? groupPic,
    String? info,
  }) async {
    try {
      // Fetch the current user (creator) as an AppUser
      AppUser? creator = await _services.fetchCurrentUser();
      if (creator == null) throw Exception("Creator could not be fetched");

      // Ensure creator is first in the member list
      selectedUsers
          .removeWhere((user) => user.id == creator.id); // Avoid duplicates
      selectedUsers.insert(0, creator); // Add creator to the beginning

      // Call Firebase API to create the group
      await _services.createGroup(
        name: groupName,
        members: selectedUsers,
        groupPic: groupPic,
        info: info,
      );

      log("Group created successfully");
      clearSelection();
      return true; // Indicate success
    } catch (e) {
      log("Error creating group: $e");
      return false; // Indicate failure
    }
  }

  void clearSelection() {
    selectedUsers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
