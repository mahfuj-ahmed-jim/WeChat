import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/features/chat/widgets/display_message.dart';

class MyMessageCard extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onLeftSwipe;
  final String repliedText;
  final String repliedTo;
  final MessageEnum repliedMessageType;
  final bool isSeen;
  final bool previousMessage;
  final bool nextMessage;

  const MyMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.repliedTo,
    required this.isSeen,
    required this.previousMessage,
    required this.onLeftSwipe,
    required this.repliedText,
    required this.repliedMessageType,
    required this.nextMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isReplying) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 5),
                  child: Text(
                    repliedTo == FirebaseAuth.instance.currentUser!.uid
                        ? '← You replied to yourself'
                        : '← You replied to them',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: 180, minWidth: 60, maxHeight: 120),
                    child: Card(
                      elevation: 1,
                      shape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8))),
                      color: blackColor,
                      margin:
                          const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 5),
                      child: Padding(
                        padding: repliedMessageType == MessageEnum.text
                            ? const EdgeInsets.all(10.0)
                            : const EdgeInsets.all(2),
                        child: Opacity(
                          opacity: 0.7,
                          child: DisplayMessage(
                            message: repliedText,
                            type: repliedMessageType,
                          ),
                        ),
                      ),
                    )),
              ],
            )
          ],
          SwipeTo(
            onLeftSwipe: onLeftSwipe,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                type == MessageEnum.text
                    ? Container()
                    : IconButton(
                        constraints: const BoxConstraints(),
                        onPressed: (() {}),
                        icon: const Icon(Icons.share),
                      ),
                ConstrainedBox(
                  constraints: type == MessageEnum.audio
                      ? BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 45,
                          minWidth: 180,
                        )
                      : type != MessageEnum.text
                          ? BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 70,
                              minWidth: 160,
                              maxHeight:
                                  (MediaQuery.of(context).size.height / 2) - 70)
                          : BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 45,
                              minWidth: 160,
                            ),
                  child: Card(
                    elevation: 1,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8))),
                    color: messageColor,
                    margin: EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: isReplying
                            ? 0
                            : previousMessage
                                ? 1.5
                                : 5,
                        bottom: nextMessage ? 1.5 : 5),
                    child: Stack(
                      children: [
                        Padding(
                          padding: type == MessageEnum.text
                              ? const EdgeInsets.only(
                                  left: 10.5,
                                  right: 10.5,
                                  top: 6,
                                  bottom: 25,
                                )
                              : const EdgeInsets.all(2),
                          child: DisplayMessage(
                            message: message,
                            type: type,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 10,
                          child: Row(
                            children: [
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: type == MessageEnum.text ||
                                          type == MessageEnum.audio
                                      ? Colors.white60
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.done_all,
                                size: 20,
                                color: type == MessageEnum.text ||
                                        type == MessageEnum.audio
                                    ? Colors.white60
                                    : Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
