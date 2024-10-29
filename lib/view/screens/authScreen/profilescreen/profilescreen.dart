import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/helper/baseviewmodel/baseviewmodel.dart';
import 'package:talknest/responsiveness/sizes.dart';
import 'package:talknest/view/widgets/button.dart';
import 'package:talknest/viewmodel/controller/profile/profile_controller.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            actions: [
              InkWell(
                onTap: () async {
                  await context
                      .read<ProfileController>()
                      .logout(context: context);
                },
                child: const Icon(
                  Icons.logout,
                  size: 30,
                  color: Colors.red,
                ),
              ),
              ResponsiveSizes.horizentalSizebox(context, .06)
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Consumer<ProfileController>(
                              builder: (context, profileProvider, _) =>
                                  Consumer<ProfileController>(
                                builder: (context, profileProvider, _) {
                                  if (profileProvider.state ==
                                      ViewState.loading) {
                                    return const CircleAvatar(
                                      radius: 50,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  }

                                  if (profileProvider.selectedImage != null) {
                                    return CircleAvatar(
                                      radius: 50,
                                      backgroundImage: FileImage(
                                          profileProvider.selectedImage!),
                                    );
                                  } else if (profileProvider.firebaseimage !=
                                          null &&
                                      profileProvider
                                          .firebaseimage!.isNotEmpty) {
                                    return CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        profileProvider.firebaseimage!,
                                      ),
                                    );
                                  } else {
                                    return const CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          AssetImage(MyImages.boyPic),
                                    );
                                  }
                                },
                              ),
                            ),
                            context.read<ProfileController>().selectedImage !=
                                    null
                                ? const SizedBox.shrink()
                                : Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: InkWell(
                                      onTap: () =>
                                          _showImagePickerDialog(context),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue,
                                        ),
                                        padding: const EdgeInsets.all(4.0),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        ResponsiveSizes.verticalSizebox(context, .02),
                        customRow(
                          context: context,
                          icon: Icons.person,
                          controller:
                              context.watch<ProfileController>().nameController,
                          labelText: "Full Name",
                        ),
                        ResponsiveSizes.verticalSizebox(context, .02),
                        customRow(
                          context: context,
                          icon: Icons.email,
                          controller: context
                              .watch<ProfileController>()
                              .emailController,
                          labelText: "Email",
                          isEditable: false,
                        ),
                        ResponsiveSizes.verticalSizebox(context, .02),
                        customRow(
                          context: context,
                          icon: Icons.error,
                          controller: context
                              .watch<ProfileController>()
                              .aboutController,
                          labelText: "About",
                        ),
                        ResponsiveSizes.verticalSizebox(context, .02),
                        Consumer<ProfileController>(
                            builder: (context, profileProvider, _) =>
                                CustomButton(
                                  icon: profileProvider.isEditable
                                      ? Icons.save
                                      : Icons.edit,
                                  label: profileProvider.isEditable
                                      ? "Save"
                                      : "Edit",
                                  onPressed: () {
                                    profileProvider.toggleEditable(
                                        context: context);
                                  },
                                )),
                      ],
                    ),
                  ),
                ),
                ResponsiveSizes.verticalSizebox(context, .15),
                Consumer<ProfileController>(
                    builder: (context, profileProvider, _) => Text(
                          "Member Since ${profileProvider.memberSince}",
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget customRow({
    required BuildContext context,
    required IconData icon,
    required TextEditingController controller,
    required String labelText,
    bool isEditable = true,
  }) {
    final provider = context.watch<ProfileController>();
    return TextFormField(
      maxLines: null,
      controller: controller,
      style: const TextStyle(
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: provider.isEditable,
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: 2.0,
          ),
        ),
        disabledBorder: InputBorder.none,
      ),
      enabled: isEditable && provider.isEditable,
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    final profileController = context.read<ProfileController>();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library, size: 40),
                      onPressed: () {
                        profileController.pickImage(
                            source: ImageSource.gallery, context: context);
                        Navigator.of(context).pop();
                      },
                    ),
                    const Text('Gallery'),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_camera, size: 40),
                      onPressed: () {
                        profileController.pickImage(
                            source: ImageSource.camera, context: context);
                        Navigator.of(context).pop();
                      },
                    ),
                    const Text('Camera'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
