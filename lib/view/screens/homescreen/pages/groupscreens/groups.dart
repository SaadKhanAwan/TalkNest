import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/models/group.dart';
import 'package:talknest/utils/routes/export_file.dart';
import 'package:talknest/view/widgets/usercard.dart';
import 'package:talknest/viewmodel/controller/groups/group_controller.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GroupProvider(),
      child: Scaffold(
        body: Consumer<GroupProvider>(
          builder: (context, provider, child) {
            return StreamBuilder<List<Group>>(
              stream: provider.groupsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No groups found'),
                  );
                }

                final groups = snapshot.data!;

                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return Usercard(
                      time: "${group.members.length.toString()} members",
                      name: group.name,
                      subtitle: group.info,
                      // time: group.,
                      imagePath: group.groupPic!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: group.groupPic!,
                              placeholder: (context, url) => const CircleAvatar(
                                backgroundImage: AssetImage(MyImages.boyPic),
                              ),
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                backgroundImage: AssetImage(MyImages.boyPic),
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  CircleAvatar(
                                radius: 30,
                                backgroundImage: imageProvider,
                              ),
                            )
                          : Image.asset(MyImages.boyPic),
                      onTap: () {
                        Navigator.pushNamed(context, RouteNames.groupchatScreen,
                            arguments: group);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
