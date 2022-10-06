import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wechat/common/widgets/loader.dart';
import 'package:wechat/features/chat/controller/chat_controller.dart';
import 'package:wechat/features/chat/widgets/my_message_card.dart';
import 'package:wechat/models/message_model.dart';

import 'sender_message_card.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;
  const ChatList({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Message> messageList;
    return StreamBuilder<List<Message>>(
        stream:
            ref.read(chatControllerProvider).chatStream(widget.recieverUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loader();
          }

          SchedulerBinding.instance.addPostFrameCallback((_) {
            messageController.jumpTo(0);
          });

          return ListView.builder(
            reverse: true,
            controller: messageController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              messageList = snapshot.data!.reversed.toList();
              var timeSent =
                  DateFormat('hh:mm a').format(messageList[index].timeSent);

              if (!messageList[index].isSeen &&
                  messageList[index].recieverid ==
                      FirebaseAuth.instance.currentUser!.uid) {
                ref.read(chatControllerProvider).setChatMessageSeen(
                      context,
                      widget.recieverUserId,
                      messageList[index].messageId,
                    );
              }
              if (messageList[index].senderId ==
                  FirebaseAuth.instance.currentUser!.uid) {
                return Padding(
                  padding: index == (snapshot.data!.length) - 1
                      ? const EdgeInsets.only(top: 10)
                      : EdgeInsets.zero,
                  child: MyMessageCard(
                    message: messageList[index].text,
                    date: timeSent,
                    type: messageList[index].type,
                    username: messageList[index].repliedTo,
                    isSeen: messageList[index].isSeen,
                    previousMessage: index != 0 &&
                            messageList[index - 1].senderId ==
                                FirebaseAuth.instance.currentUser!.uid
                        ? true
                        : index == 0 &&
                                messageList[index + 1].senderId ==
                                    FirebaseAuth.instance.currentUser!.uid
                            ? true
                            : false,
                  ),
                );
              }
              return SenderMessageCard(
                message: messageList[index].text,
                date: timeSent,
                type: messageList[index].type,
                username: messageList[index].repliedTo,
                repliedMessageType: messageList[index].repliedMessageType,
                repliedText: '',
                previousMessage: index != 0 &&
                            messageList[index - 1].senderId !=
                                FirebaseAuth.instance.currentUser!.uid
                        ? true
                        : index == 0 &&
                                messageList[index + 1].senderId !=
                                    FirebaseAuth.instance.currentUser!.uid
                            ? true
                            : false,
              );
            },
          );
        });
  }
}
