import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/provider/message_reply_provider.dart';
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

  void onMessageSwipe(String message, bool isMe, MessageEnum type) {
    ref
        .read(messageReplyProvider.state)
        .update((state) => MessageReply(message, isMe, type));
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

          return Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              reverse: true,
              shrinkWrap: true,
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
                        repliedTo: messageList[index].repliedTo,
                        isSeen: messageList[index].isSeen,
                        previousMessage: index != (snapshot.data!.length) - 1 &&
                                messageList[index + 1].senderId ==
                                    FirebaseAuth.instance.currentUser!.uid
                            ? true
                            : false,
                        nextMessage: index != 0 &&
                                messageList[index - 1].senderId ==
                                    FirebaseAuth.instance.currentUser!.uid
                            ? true
                            : false,
                        repliedText: messageList[index].repliedMessage,
                        repliedMessageType:
                            messageList[index].repliedMessageType,
                        onLeftSwipe: (() => onMessageSwipe(
                            messageList[index].text,
                            true,
                            messageList[index].type))),
                  );
                }
                return Padding(
                  padding: index == (snapshot.data!.length) - 1
                      ? const EdgeInsets.only(top: 10)
                      : EdgeInsets.zero,
                  child: SenderMessageCard(
                    message: messageList[index].text,
                    date: timeSent,
                    type: messageList[index].type,
                    repliedTo: messageList[index].repliedTo,
                    repliedMessageType: messageList[index].repliedMessageType,
                    repliedText: messageList[index].repliedMessage,
                    previousMessage: index != (snapshot.data!.length) - 1 &&
                                messageList[index + 1].senderId !=
                                    FirebaseAuth.instance.currentUser!.uid
                            ? true
                            : false,
                        nextMessage: index != 0 &&
                                messageList[index - 1].senderId !=
                                    FirebaseAuth.instance.currentUser!.uid
                            ? true
                            : false,
                    onRightSwipe: (() => onMessageSwipe(messageList[index].text,
                        false, messageList[index].type)),
                  ),
                );
              },
            ),
          );
        });
  }
}
