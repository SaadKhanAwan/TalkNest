import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/helper/baseviewmodel/baseviewmodel.dart';
import 'package:talknest/models/appuser.dart';
import 'package:talknest/responsiveness/sizes.dart';
import 'package:talknest/utils/routes/export_file.dart';
import 'package:talknest/view/widgets/usercard.dart';
import 'package:talknest/view/widgets/usercontainershimmer.dart';
import 'package:talknest/viewmodel/controller/contact_controller/cotact_controller.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContactProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contact Screen'),
          actions: [
            Consumer<ContactProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  icon: Icon(provider.isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    provider.toggleSearch();
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<ContactProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.isSearching)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: provider.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          provider.updateSearchText(value);
                        },
                      ),
                    ),
                  Column(
                    children: [
                      ResponsiveSizes.verticalSizebox(context, .01),
                      buildRow(icon: Icons.person_add, name: 'New Contact'),
                      ResponsiveSizes.verticalSizebox(context, .01),
                      buildRow(icon: Icons.group, name: 'Create Group'),
                    ],
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 6),
                    child: Text(
                      "Contact on TalkNest",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins"),
                    ),
                  ),
                  provider.state == ViewState.loading
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 7,
                          itemBuilder: (context, index) {
                            return buildShimmer(context);
                          },
                        )
                      : provider.filteredUserList.isEmpty
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: ResponsiveSizes.height(context, .2)),
                              child: Center(
                                child: Text(
                                  'No user available',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.filteredUserList.length,
                              itemBuilder: (context, index) {
                                AppUser user = provider.filteredUserList[index];
                                return Usercard(
                                    name: user.name,
                                    subtitle: user.about,
                                    time: "",
                                    imagePath: user.profileImage.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 30,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    user.profileImage),
                                          )
                                        : Image.asset(MyImages.boyPic),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, RouteNames.userChatScreen,
                                          arguments: user);
                                    });
                              },
                            ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  buildRow({icon, name}) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: ResponsiveSizes.width(context, .04), vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveSizes.width(context, .01), vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(
              icon,
              color: Colors.white,
            )),
        title: Text(name,
            style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins")),
      ),
    );
  }
}
