import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/auth/controller/auth_controller.dart';
import 'package:wechat/features/chat/widgets/bottom_chat_field.dart';
import 'package:wechat/features/chat/widgets/chat_list.dart';
import 'package:wechat/models/user_model.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
  }) : super(key: key);

  void makeCall(WidgetRef ref, BuildContext context) {
    /*ref.read(callControllerProvider).makeCall(
          context,
          name,
          uid,
          profilePic,
          isGroupChat,
        );*/
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          onPressed: (() {
            Navigator.pop(context);
          }),
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 0,
        title: isGroupChat
            ? Text(name)
            : StreamBuilder<UserModel>(
                stream: ref.read(authControllerProvider).userDataById(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          profilePic,
                        ),
                        radius: 20,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            snapshot.data!.isOnline
                                ? 'online'
                                : 'last seen  at ${DateFormat('hh:mm a')
                                    .format(snapshot.data!.lastSeen)}',
                            style:
                                const TextStyle(color: greyColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
        centerTitle: false,
        actions: [
          IconButton(
            constraints: const BoxConstraints(),
            onPressed: () => makeCall(ref, context),
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            constraints: const BoxConstraints(),
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            constraints: const BoxConstraints(),
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatList(
              recieverUserId: uid,
              isGroupChat: isGroupChat,
            ),
          ),
          BottomChatField(
            recieverUserId: uid,
            isGroupChat: isGroupChat,
          ),
        ],
      ),
    );
  }
}
