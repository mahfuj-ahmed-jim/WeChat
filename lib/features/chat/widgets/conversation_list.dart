import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/chat/controller/chat_controller.dart';
import 'package:wechat/features/chat/screens/mobile_chat_screen.dart';
import 'package:wechat/models/chat_contact_model.dart';

class ConversationList extends ConsumerWidget {
  const ConversationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          StreamBuilder<List<ChatContact>>(
              stream: ref.watch(chatControllerProvider).chatContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }

                return ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var chatContactData = snapshot.data![index];

                    return Padding(
                      padding: index == snapshot.data!.length - 1
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
                                  'name': chatContactData.name,
                                  'uid': chatContactData.contactId,
                                  'isGroupChat': false,
                                  'profilePic': chatContactData.profilePic,
                                },
                              );
                            },
                            child: ListTile(
                              title: Text(
                                chatContactData.name,
                                maxLines: 1,
                                style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 18,
                                    fontWeight:
                                        chatContactData.unseenMessages == 0
                                            ? FontWeight.normal
                                            : FontWeight.bold),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  maxLines: 1,
                                  chatContactData.lastMessage,
                                  style: TextStyle(
                                      color: chatContactData.unseenMessages == 0
                                          ? Colors.grey
                                          : Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      fontWeight:
                                          chatContactData.unseenMessages == 0
                                              ? FontWeight.normal
                                              : FontWeight.bold),
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  chatContactData.profilePic,
                                ),
                                radius: 30,
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('hh:mm a')
                                        .format(chatContactData.timeSent),
                                    style: TextStyle(
                                      color: chatContactData.unseenMessages == 0
                                          ? Colors.grey
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight:
                                          chatContactData.unseenMessages == 0
                                              ? FontWeight.normal
                                              : FontWeight.bold
                                    ),
                                  ),
                                  Padding(
                                    padding: chatContactData.unseenMessages == 0
                                        ? const EdgeInsets.only(top: 0.0)
                                        : const EdgeInsets.only(top: 5.0),
                                    child: CircleAvatar(
                                      radius:
                                          chatContactData.unseenMessages == 0
                                              ? 0
                                              : 10.5,
                                      backgroundColor: tabColor,
                                      child: Text(
                                        '${chatContactData.unseenMessages}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const Divider(color: dividerColor, indent: 85),
                        ],
                      ),
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}
