import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/common/utils/utils.dart';
import 'package:wechat/features/auth/controller/auth_controller.dart';
import 'package:wechat/features/chat/widgets/conversation_list.dart';
import 'package:wechat/features/group/screen/create_group_screen.dart';
import 'package:wechat/features/select_contact/screens/select_contacts_screen.dart';
import 'package:wechat/features/status/screens/confirm_status_screen.dart';
import 'package:wechat/features/status/screens/status_screen.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;
  int index = 0;
  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    ref.read(authControllerProvider).setUserState(true); // initially set online
    tabBarController.addListener(() {
      setState(() {
        index = tabBarController.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void statusPage() async {
    File? pickedImage = await pickImageFromGallery(context);
    if (pickedImage != null) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(
        context,
        ConfirmStatusScreen.routeName,
        arguments: pickedImage,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          centerTitle: false,
          title: const Text(
            'WeChat',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {},
            ),
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text(
                    'Create Group',
                  ),
                  onTap: () => Future(
                    () => Navigator.pushNamed(
                        context, CreateGroupScreen.routeName),
                  ),
                )
              ],
            ),
          ],
          bottom: TabBar(
            controller: tabBarController,
            indicatorColor: tabColor,
            indicatorWeight: 2.5,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(
                text: 'CHATS',
              ),
              Tab(
                text: 'STATUS',
              ),
              Tab(
                text: 'CALLS',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabBarController,
          children: const [
            ConversationList(),
            StatusScreen(),
            Text('Calls')
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (tabBarController.index == 0) {
              Navigator.pushNamed(context, SelectContactsScreen.routeName);
            } else {
              statusPage();
            }
          },
          backgroundColor: tabColor,
          child: Icon(
            index == 0
                ? Icons.comment
                : index == 1
                    ? Icons.camera_alt_rounded
                    : Icons.call,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
