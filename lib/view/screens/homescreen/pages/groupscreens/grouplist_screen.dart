import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/viewmodel/controller/contact_controller/cotact_controller.dart';

class GroupCreationScreen extends StatelessWidget {
  const GroupCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire screen in ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (_) => ContactProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Group'),
          actions: [
            Consumer<ContactProvider>(
              builder: (context, provider, child) {
                return IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      if (provider.selectedUsers.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            String groupName = '';
                            return AlertDialog(
                              title: const Text('Enter Group Name'),
                              content: TextField(
                                onChanged: (value) {
                                  groupName = value;
                                },
                                decoration: const InputDecoration(
                                    hintText: "Group Name"),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(
                                        context); // Close input dialog

                                    if (groupName.isNotEmpty) {
                                      // Call createGroup and handle result
                                      bool success = await provider.createGroup(
                                        groupName: groupName,
                                        groupPic:
                                            'path/to/group/pic', // Optional
                                        info: 'Group information', // Optional
                                      );

                                      // Show success or failure dialog
                                      if (success) {
                                        _showDialog(context, "Group Created",
                                            "The group has been created successfully!");

                                        // Close the dialog after 2 seconds and navigate back
                                        Future.delayed(
                                            const Duration(seconds: 2), () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop(); // Close success dialog
                                          Navigator.of(context)
                                              .pop(); // Navigate back
                                        });
                                      } else {
                                        _showDialog(context, "Creation Failed",
                                            "Failed to create the group. Please try again.");
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text("Please enter a group name"),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Create'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Select at least one user")),
                        );
                      }
                    });
              },
            ),
          ],
        ),
        body: Consumer<ContactProvider>(
          builder: (context, provider, child) {
            return ListView.builder(
              itemCount: provider.userList.length,
              itemBuilder: (context, index) {
                final user = provider.userList[index];
                final isSelected = provider.selectedUsers.contains(user);

                return ListTile(
                  leading: user.profileImage.isNotEmpty
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              CachedNetworkImageProvider(user.profileImage),
                        )
                      : Image.asset(MyImages.boyPic),
                  title: Text(user.name),
                  subtitle: Text(user.about),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.blue)
                      : const Icon(Icons.circle_outlined),
                  onTap: () => provider.toggleUserSelection(user),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
        );
      },
    );
  }
}
