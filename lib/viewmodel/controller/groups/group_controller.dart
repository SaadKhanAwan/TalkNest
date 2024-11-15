import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/models/group.dart';
import 'package:talknest/models/group_message.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class GroupProvider with ChangeNotifier {
  final FirebaseApi _firebaseApi = FirebaseApi();
  Stream<List<Group>>? _groupsStream;
  final ImagePicker _picker = ImagePicker();
  String? uploadedImageUrl;
  File? selectedMediaFile;
  bool isLoading = false;

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  Stream<List<Group>> get groupsStream => _groupsStream ?? Stream.empty();

  GroupProvider() {
    fetchUserGroups();
  }

  /// Fetches the groups the user belongs to
  void fetchUserGroups() {
    _groupsStream = _firebaseApi.getUserGroups();
    notifyListeners();
  }

  /// Initializes the message stream for a specific group chat
  Stream<List<GroupMessage>> getGroupMessagesStream(String groupId) {
    return _firebaseApi.getGroupMessagesStream(groupId);
  }

  /// Sends a text or image message to a group
  Future<void> sendGroupMessage({
    required String groupId,
    String? messageText,
    String? imageUrl,
  }) async {
    if ((messageText != null && messageText.isNotEmpty) || imageUrl != null) {
      try {
        await _firebaseApi.sendGroupMessage(
          groupId: groupId,
          messageText: messageText ?? '',
          imageUrl: imageUrl,
        );
        clearSelectedMedia(); // Clear any selected media after sending
      } catch (e) {
        log("Error sending group message: $e");
      }
    }
  }

  /// Picks an image from the gallery and uploads it
  Future<void> pickMedia() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedMediaFile = File(pickedFile.path);
      notifyListeners(); // Show loading while uploading

      try {
        uploadedImageUrl = await _firebaseApi.uploadImage(selectedMediaFile!);
      } catch (e) {
        log("Error uploading image: $e");
      } finally {
        notifyListeners(); // Update UI after upload completes
      }
    }
  }

  Future<List<AppUser>> getAllUsersNotInGroup(String groupId) async {
    try {
      final allUsers = await _firebaseApi.getAllUsers();
      final group = await _firebaseApi.getGroupById(groupId);
      if (group != null) {
        return allUsers
            .where((user) => !group.members.contains(user.id))
            .toList();
      }
      return [];
    } catch (e) {
      log("Error fetching users not in group: $e");
      return [];
    }
  }

  /// Adds a user to the specified group
  Future<void> addUserToGroup(String groupId, String userId) async {
    try {
      await _firebaseApi.addUserToGroup(groupId, userId);
      notifyListeners(); // Notify UI of changes
    } catch (e) {
      log("Error adding user to group: $e");
    }
  }

  /// Removes a user from the specified group
  Future<void> removeUserFromGroup(String groupId, String userId) async {
    try {
      await _firebaseApi.removeUserFromGroup(groupId, userId);
      notifyListeners(); // Notify UI of changes
    } catch (e) {
      log("Error removing user from group: $e");
    }
  }

  /// Updates group information, including name, description, and image
  Future<void> updateGroup({
    required String groupId,
    required String name,
    required String description,
    File? groupImage,
  }) async {
    setLoading(true);
    try {
      String? imageUrl;
      if (groupImage != null) {
        imageUrl = await _firebaseApi.uploadImage(groupImage);
      }
      await _firebaseApi.updateGroupDetails(
          groupId, name, description, imageUrl);
      setLoading(false);
      notifyListeners();
    } catch (e) {
      log("Error updating group: $e");
      setLoading(false);
    }
  }

  Future<AppUser?> getUserById(String userId) async {
    return await _firebaseApi.getUserById(userId);
  }

  /// Clears the selected media file after it's sent or dismissed
  void clearSelectedMedia() {
    selectedMediaFile = null;
    uploadedImageUrl = null;
    notifyListeners();
  }
}
