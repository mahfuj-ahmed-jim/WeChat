import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/common/widgets/error.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/chat/screens/mobile_chat_screen.dart';
import 'package:wechat/features/select_contact/controller/select_contacts_controller.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const String routeName = '/select-contact';
  const SelectContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: ref.watch(getSelectContactProvider).when(
            data: (contactList) => ListView.builder(
              shrinkWrap: true,
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: index == 0
                      ? const EdgeInsets.only(top: 10)
                      : EdgeInsets.zero,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                          context,
                          MobileChatScreen.routeName,
                          arguments: {
                            'name': contactList[index].name,
                            'uid': contactList[index].uid,
                            'isGroupChat': false,
                            'profilePic': contactList[index].profilePic,
                          },
                        );
                        },
                        child: ListTile(
                          title: Text(
                            contactList[index].name,
                            maxLines: 1,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis, fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              maxLines: 1,
                              contactList[index].status,
                              style: const TextStyle(
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 14),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              contactList[index].profilePic,
                            ),
                            radius: 30,
                          ),
                        ),
                      ),
                      const Divider(color: dividerColor, indent: 85)
                    ],
                  ),
                );
              },
            ),
            error: (err, trace) => ErrorScreen(error: err.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
