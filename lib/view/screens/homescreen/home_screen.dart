import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:talknest/config/images.dart';
import 'package:talknest/responsiveness/sizes.dart';
import 'package:talknest/viewmodel/controller/homescreen/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(itsthis: this),
      builder: (context, child) {
        return SafeArea(
            child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                MyImages.appicon,
              ),
            ),
            title: Text(
              "TalkNest",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            actions: [
              const Icon(
                Icons.search,
                size: 30,
              ),
              ResponsiveSizes.horizentalSizebox(context, .03),
              InkWell(
                onTap: () async {
                  await context.read<HomeController>().logout(context: context);
                },
                child: const Icon(
                  Icons.more_vert,
                  size: 30,
                ),
              ),
              ResponsiveSizes.horizentalSizebox(context, .03)
            ],
            bottom: PreferredSize(
              preferredSize:
                  Size.fromHeight(ResponsiveSizes.height(context, .1)),
              child: TabBar(
                dividerColor: Theme.of(context).colorScheme.onPrimaryContainer,
                labelStyle: Theme.of(context).textTheme.bodyLarge,
                unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
                controller: context.read<HomeController>().tabController,
                tabs: context
                    .read<HomeController>()
                    .tabTitles
                    .map((title) => Tab(
                          text: title,
                        ))
                    .toList(),
              ),
            ),
          ),
          body: TabBarView(
              controller: context.read<HomeController>().tabController,
              children: context.read<HomeController>().tabBody),
        ));
      },
    );
  }
}
