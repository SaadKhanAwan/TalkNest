import 'package:flutter/material.dart';
import 'package:talknest/helper/baseviewmodel/baseviewmodel.dart';
import 'package:talknest/view/screens/homescreen/pages/callscreen.dart';
import 'package:talknest/view/screens/homescreen/pages/chatscreen/chat_screen.dart';
import 'package:talknest/view/screens/homescreen/pages/groups.dart';

class HomeController extends BaseViewModel {
  late TabController tabController;

  HomeController({required TickerProvider itsthis}) {
    _init(itsthis: itsthis);
  }

  _init({required TickerProvider itsthis}) {
    tabController = TabController(length: 3, vsync: itsthis);
  }

  final List<String> tabTitles = ["Chats", "Groups", "Calls"];

  final List<Widget> tabBody = const [
    ChatScreen(),
    GroupScreen(),
    Callscreen(),
  ];
}
