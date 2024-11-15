import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/models/group.dart';
import 'package:talknest/viewmodel/controller/groups/group_controller.dart';

class GroupManagementScreen extends StatefulWidget {
  final Group group;
  final bool isAdmin; // Pass if user is admin or not

  const GroupManagementScreen(
      {super.key, required this.group, required this.isAdmin});

  @override
  _GroupManagementScreenState createState() => _GroupManagementScreenState();
}

class _GroupManagementScreenState extends State<GroupManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  bool fieldsEnabled = true;
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.info;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupProvider(),
      builder: (context, child) {
        final groupProvider = context.read<GroupProvider>();
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.group.name),
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black87,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display and edit group image
                Center(
                  child: GestureDetector(
                    onTap: widget.isAdmin ? _pickImage : null,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : CachedNetworkImageProvider(
                              widget.group.groupPic ?? ""),
                      child: widget.isAdmin
                          ? const Icon(Icons.camera_alt, color: Colors.white70)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Group Name and Description fields
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  enabled: widget.isAdmin && fieldsEnabled,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Group Description',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  enabled: widget.isAdmin && fieldsEnabled,
                ),
                const SizedBox(height: 20),
                // Button to Save Changes
                if (widget.isAdmin)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          fieldsEnabled = false;
                        });
                        await groupProvider.updateGroup(
                          groupId: widget.group.id,
                          name: _nameController.text.trim(),
                          description: _descriptionController.text.trim(),
                          groupImage: _selectedImage,
                        );
                        _showSuccessDialog();
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        // onPrimary: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Section to add or remove users
                if (widget.isAdmin)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Manage Group Members",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Open a modal or navigate to a screen to add new users to the group
                          // await _showAddUserModal(context);
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext modalContext) {
                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                color: Colors.black87,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Add Users to Group",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                    const SizedBox(height: 10),
                                    // List available users to add
                                    FutureBuilder<List<AppUser>>(
                                      future:
                                          groupProvider.getAllUsersNotInGroup(
                                              widget.group.id),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        }
                                        final users = snapshot.data!;
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: users.length,
                                          itemBuilder: (context, index) {
                                            final user = users[index];
                                            return ListTile(
                                              title: Text(
                                                user.name,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.add,
                                                    color: Colors.green),
                                                onPressed: () async {
                                                  // Access the provider here using the modalContext
                                                  await groupProvider
                                                      .addUserToGroup(
                                                          widget.group.id,
                                                          user.id);
                                                  Navigator.pop(
                                                      modalContext); // Close the modal after adding
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text("Add Users",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                // List of Current Group Members
                const Text("Group Members",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                const Divider(color: Colors.white54),
                Consumer<GroupProvider>(
                  builder: (context, provider, _) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.group.members.length,
                      itemBuilder: (context, index) {
                        final String memberId = widget.group
                            .members[index]; // memberId is a String (user ID)

                        return FutureBuilder<AppUser?>(
                          future: groupProvider.getUserById(memberId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const SizedBox(); // Return empty if user data is missing
                            }

                            final AppUser member = snapshot.data!;
                            final isAdmin = widget.group.createdBy == member.id;

                            return ListTile(
                              title: Text(
                                member.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                isAdmin ? "Admin" : "",
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: widget.isAdmin && !isAdmin
                                  ? IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.redAccent),
                                      onPressed: () async {
                                        await groupProvider.removeUserFromGroup(
                                            widget.group.id, member.id);
                                      },
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Group updated successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
