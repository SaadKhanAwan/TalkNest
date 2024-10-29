import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talknest/helper/baseviewmodel/baseviewmodel.dart';
import 'package:talknest/helper/dateFormate.dart/dateformate.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/utils/dilogues.dart';
import 'package:talknest/utils/routes/route_name.dart';
import 'package:talknest/viewmodel/services/firebaseservices/firebase_apis.dart';

class ProfileController extends BaseViewModel {
  final FirebaseApi _services = FirebaseApi();

  TextEditingController nameController =
      TextEditingController(text: "John Doe");
  TextEditingController emailController =
      TextEditingController(text: "john.doe@example.com");
  TextEditingController aboutController =
      TextEditingController(text: "Hi, I am Saad");

  bool isEditable = false;
  String memberSince = 'Not clear';

  String _firebaseimage = '';
  String? get firebaseimage => _firebaseimage;

  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  ProfileController() {
    _init();
  }

  _init() async {
    await fetchUserData();
  }

  // Correcting the toggleEditable logic
  void toggleEditable({required BuildContext context}) {
    if (isEditable == false) {
      // Enable editing
      isEditable = true;
    } else {
      // If editing is true, save the changes and disable editing
      isEditable = false;
      updateProfile(context: context); // Call the profile update function
    }
    notifyListeners();
  }

  Future<void> pickImage(
      {required ImageSource source, required BuildContext context}) async {
    setstate(ViewState.loading);
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        String? downloadUrl = await _services.uploadImageToFirebase(
          imageFile: File(_selectedImage!.path),
          folderName: 'profile_images',
        );

        if (downloadUrl != null) {
          // Update Firestore with the new image URL
          await _services.updateImage(image: downloadUrl);
        }
        Dilogues.showSnackbar(context, message: "Picture updated successfully");
        setstate(ViewState.success);
        notifyListeners();
      }
    } catch (e) {
      log("Error updating user image data: $e");
      setstate(ViewState.fail);
      Dilogues.showSnackbar(context, message: "Picture update failed");
    }
  }

  Future<void> fetchUserData() async {
    setstate(ViewState.loading);
    try {
      AppUser? user = await _services.getUserData();

      if (user != null) {
        nameController.text = user.name;
        emailController.text = user.email;
        aboutController.text = user.about;
        memberSince = Dateformate.timeAgo(user.createdAt);
        _firebaseimage = user.profileImage;
        setstate(ViewState.success);
        notifyListeners();
      }
    } catch (e) {
      setstate(ViewState.fail);
      log("Error fetching user data: $e");
    }
  }

  Future<void> updateProfile({required BuildContext context}) async {
    try {
      setstate(ViewState.loading);
      await _services.updateProfile(
          about: aboutController.text, name: nameController.text);
      Dilogues.showSnackbar(context, message: "Profile updated successfully");
      setstate(ViewState.success);
    } catch (e) {
      log("Error updating profile: $e");
      setstate(ViewState.fail);
      Dilogues.showSnackbar(context, message: "Profile update failed");
    }
  }

  Future<void> logout({required BuildContext context}) async {
    await _services.signOut().then((value) {
      if (value == "successfully") {
        Dilogues.showSnackbar(context, message: "Logout successfully.");
        Navigator.pushReplacementNamed(context, RouteNames.auth);
      }
    });
  }
}
