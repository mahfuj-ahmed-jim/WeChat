import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:wechat/common/enums/message_enum.dart';
import 'package:wechat/common/utils/colors.dart';
import 'package:wechat/features/chat/widgets/display_message.dart';

class SenderMessageCard extends StatelessWidget {
  const SenderMessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.type,
    required this.repliedText,
    required this.repliedTo,
    required this.repliedMessageType,
    required this.previousMessage,
    required this.onRightSwipe,
    required this.nextMessage,
  }) : super(key: key);
  final String message;
  final String date;
  final MessageEnum type;
  final VoidCallback onRightSwipe;
  final String repliedText;
  final String repliedTo;
  final MessageEnum repliedMessageType;
  final bool previousMessage;
  final bool nextMessage;

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isReplying) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15, top: 5),
                  child: Text(
                    repliedTo == FirebaseAuth.instance.currentUser!.uid
                        ? '← They replied to you'
                        : '← They replied to them',
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
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 0, top: 5),
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
            ),
          ],
          SwipeTo(
            onRightSwipe: onRightSwipe,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: type != MessageEnum.text
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
                    color: senderMessageColor,
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
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 13,
                              color: type == MessageEnum.text ||
                                      type == MessageEnum.audio
                                  ? Colors.white60
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                type == MessageEnum.text
                    ? Container()
                    : IconButton(
                        onPressed: (() {}),
                        icon: const Icon(Icons.share),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
